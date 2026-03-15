% ------------------------------------------------------------
% SCRIPT PRINCIPAL PRACTICA 2 Ejericio 2
% -------------------------------------------------------------------------
% ECUACIÓN DE ADVECCIÓN-DIFUSIÓN-REACCIÓN
% Método de Galerkin con elementos finitos lineales + Euler Implícito
%
% Ecuación:      c * u_t - k u_xx = f(x,t)       en (0,L)×(0,t_f]
% Condiciones:   (k u_x - \alpha u)(0,t) = - \alpha u_{left}(t)
%                (k u_x + \beta u)(L,t) = \beta u_{right}(t) 
%                u(x,0) = U_0(x)
%
% Solución exacta: u(x,t) = exp(2 - t - x^2)
%
% Se separa la fuente: f(x,t) = g(x)*h(t)
%
% Requiere las funciones: phi_k.m phi_prima_k.m
% -------------------------------------------------------------------------

clear; close all; clc

% =========================================================================
%% 1. DEFINICIÓN DE DATOS FÍSICOS Y FUNCIONES DEL PROBLEMA
% =========================================================================
L = 1;    % Longitud del intervalo espacial
k = 1;    % Coeficiente de difusión
c = 1;    % Coeficiente de capacidad térmica

% Condición inicial U_0(x)
U0 = @(x) exp(2 - x.^2);     % condición inicial

% Condiciones de borde generalizadas
u_left = @(t) exp(2 - t);    % condición en x = 0
u_right = @(t) exp(1 - t);   % condición en x = L

% Fuente: f(x,t) = g(x)*h(t)
g = @(x) (1 - 4*x.^2).*exp(-x.^2);
h = @(t) exp(2 - t);


% =========================================================================
%% 2. MALLADO ESPACIAL
% =========================================================================
N = 101;                          
x = linspace(0,L,N)';
ne = N - 1;

% Matriz T
T = [(1:ne)' (2:ne+1)'];

% =========================================================================
%% 3. ENSAMBLAJE DE MATRICES C, K y VECTOR Fg
% =========================================================================
C = zeros(N,N);   % Matriz de Masa
K = zeros(N,N);   % Matriz de Rigidez
Fg = zeros(N,1);  % Vector fuente espacial 

for e = 1:ne
    n1 = T(e,1);
    n2 = T(e,2);
    a = x(n1); b = x(n2);

    % Funciones base y sus derivadas
    phi1 = @(z) phi_k(z, x, n1);
    phi2 = @(z) phi_k(z, x, n2);
    phi1p = @(z) phi_prima_k(z, x, n1);
    phi2p = @(z) phi_prima_k(z, x, n2);

    % Matriz de masa C
    C(n1,n1) = C(n1,n1) + integral(@(z) c.*phi1(z).*phi1(z), a, b);
    C(n1,n2) = C(n1,n2) + integral(@(z) c.*phi1(z).*phi2(z), a, b);
    C(n2,n1) = C(n2,n1) + integral(@(z) c.*phi2(z).*phi1(z), a, b);
    C(n2,n2) = C(n2,n2) + integral(@(z) c.*phi2(z).*phi2(z), a, b);

    % Matriz de masa K
    K(n1,n1) = K(n1,n1) + integral(@(z) k.*phi1p(z).*phi1p(z), a, b);
    K(n1,n2) = K(n1,n2) + integral(@(z) k.*phi1p(z).*phi2p(z), a, b);
    K(n2,n1) = K(n2,n1) + integral(@(z) k.*phi2p(z).*phi1p(z), a, b);
    K(n2,n2) = K(n2,n2) + integral(@(z) k.*phi2p(z).*phi2p(z), a, b);

    % Vector Fg (solo depende de g(x)) parte espacial
    Fg(n1) = Fg(n1) + integral(@(z) g(z).*phi1(z), a, b);
    Fg(n2) = Fg(n2) + integral(@(z) g(z).*phi2(z), a, b);
end

% =========================================================================
%% 4. CONFIGURACIÓN TEMPORAL Y PARÁMETROS DE CASO
% =========================================================================
tf = 1;
dt = 0.01;
M = round(tf/dt);

% Solución exacta para la comparación
u_exact = @(x,t) exp(2 - t - x.^2);


% Casos de parámetros (alpha, beta) para condiciones generalizadas
param = [1 1;       % Caso 1: Robin estándar
         100 100;  % Caso 2: Aproximación a Dirichlet fuerte
         1000 0;    % Caso 3: Dirichlet en x=0, Neumann/Aislado en x=L
         0 1];      % CASO 4: 
     
% Matriz para guardar la solución final U(x, t_f) para cada caso
U_end = zeros(N,size(param, 1)); 

% =========================================================================
%% 5. BUCLE DE SIMULACIÓN Y GRÁFICOS 
% =========================================================================
for caso = 1:size(param, 1) 
    alpha = param(caso,1);  % Parámetro en el borde izquierdo (x=0)
    beta  = param(caso,2);  % Parámetro en el borde derecho (x=L)
    
    % --- CONFIGURACIÓN DEL SISTEMA LINEAL (Constante en el tiempo) ---
    C_tmp = C;
    K_tmp = K;
    
    % Añadir las contribuciones de las condiciones generalizadas a K 
    % K_{11} += \alpha ; K_{NN} += \beta
    K_tmp(1,1)     = K_tmp(1,1) + alpha;
    K_tmp(end,end) = K_tmp(end,end) + beta;
    
    % Matriz del sistema para el esquema implícito: A = C + dt*K
    A = C_tmp + dt*K_tmp;
    
    % --- SIMULACIÓN TEMPORAL ---
    U = zeros(N,M+1);       % Inicializar la matriz de la solución U(x, t)
    U(:,1) = U0(x);         % Condición inicial
    
    for n = 1:M
        t = n*dt;
        
        % 1. Calcular el vector fuente F_t
        F_t = h(t)*Fg;
        % 2. Añadir términos de borde al vector fuente (solo en los nodos de frontera)
        F_t(1) = F_t(1) + alpha*u_left(t);
        F_t(end) = F_t(end) + beta*u_right(t);
        
        % 3. Lado derecho (RHS): C*U^n + dt*F(t)
        RHS = C_tmp*U(:,n) + dt*F_t;
        
        % 4. Resolver para U^{n+1}: A * U^{n+1} = RHS
        U(:,n+1) = A \ RHS;
    end
    
    % Guardar la solución en el tiempo final
    U_end(:,caso) = U(:,end);
    
    % ---------------------------
    % Gráfica individual de cada caso
    % ---------------------------
    figure; hold on; grid on;
    plot(x, U(:,end), 'r-', 'LineWidth', 1.8);
    plot(x, u_exact(x,1), 'k--', 'LineWidth', 2);
    xlabel('x'); ylabel('u(x,1)');
    
    if caso == 4
        titulo_caso = 'Caso 4: \alpha=0 (Neumann), \beta=1 (Robin)';
    elseif caso == 3
        titulo_caso = 'Caso 3: \alpha=1000 (Dirichlet), \beta=0 (Neumann)';
    elseif caso == 2
        titulo_caso = 'Caso 2: \alpha=100, \beta=100 (Dirichlet Aproximado)';
    else
        titulo_caso = 'Caso 1: \alpha=1, \beta=1 (Robin Estándar)';
    end
    
    title(titulo_caso);
    legend('Numérica','Exacta','Location','Best');
    tabla = annotation('textbox',[0.15,0.15,0.25,0.15], ...
                   'String',sprintf('N = %d\ndt = %.4f\nt_f = %.2f',N,dt,tf), ...
                   'FitBoxToText','on', ...
                   'BackgroundColor',[1 1 1], ...
                   'EdgeColor',[0 0 0], ...
                   'FontSize',10);
  
end