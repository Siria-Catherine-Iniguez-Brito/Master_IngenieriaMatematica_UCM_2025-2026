% ------------------------------------------------------------
% SCRIPT PRINCIPAL PRACTICA 2 Ejercicio 1: Ecuación del Calor 
% ------------------------------------------------------------
% Este script implementa el Método de Elementos Finitos (FEM) de Galerkin 
% con funciones base lineales a trozos (L.T.) en el espacio, y el 
% esquema de Euler Implícito para la integración en el tiempo.
%
% Problema: c*u_t = (k*u_x)_x + f(x,t)
% CC: u(0,t) = U_l(t) (Dirichlet) y q(L,t) = Q_r(t) (Neumann/Flujo)
%
% Requiere las funciones externas: phi_k.m y phi_prima_k.m
% -------------------------------------------------------------------------
clear; close all; clc;

% =========================================================================
%% 1. DEFINICIÓN DE DATOS DEL PROBLEMA
% =========================================================================

L = 1;   % Longitud del intervalo espacial
k = 1;   % Coeficiente de difusión 
c = 1;   % Coeficiente de capacidad térmica

% Condición inicial U_0(x) 
U0 = @(x) exp(2-x.^2);

% Condición de borde Dirichlet en x=0
Ul = @(t) exp(2-t);
Ul_prima = @(t) -exp(2-t);

% Condición de borde Neumann en x=L (flujo)
Qr = @(t) 2*exp(1-t);

% Fuente separada f(x,t) = g(x)*h(t)
% f = @(x,t) (1 - 4*x.^2) .* exp(2 - t - x.^2);

g = @(x) (1 - 4*x.^2) .* exp(-x.^2);   % parte espacial de f
h = @(t) exp(2 - t);                   % parte temporal de f


% =========================================================================
%% 2. MALLADO
% =========================================================================
N = 101;     % número de nodos
x_nodos = linspace(0,L,N);   % malla uniforme


%Construir matriz T
T = zeros(N-1, 2); 
for i = 1:N - 1
    T(i, 1) = i;
    T(i, 2) = i + 1; 
end 

% =========================================================================
%% 3. ENSAMBLAJE DE MATRICES K,C y VECTOR F
% =========================================================================
matriz_K = zeros(N,N);     % Matriz de masa
matriz_C = zeros (N,N);    % Matriz de rigidez
vector_Fg = zeros(N,1);    % Vector fuente espacial fijo

for m = 1:N-1
    e1 = T(m,1);
    e2 = T(m,2);

    % Funciones base y sus derivadas
    phi1 = @(z) phi_k(z, x_nodos, e1);
    phi2 = @(z) phi_k(z, x_nodos, e2);

    phi_prima1 = @(z) phi_prima_k(z, x_nodos, e1);
    phi_prima2 = @(z) phi_prima_k(z, x_nodos, e2);


    % Intervalo físico
    a = x_nodos(e1);
    b = x_nodos(e2);

    % Matriz de masa C
    matriz_C(e1,e1) = matriz_C(e1,e1) + integral(@(z) phi1(z).*phi1(z)*c, a, b);
    matriz_C(e1,e2) = matriz_C(e1,e2) + integral(@(z) phi1(z).*phi2(z)*c, a, b);
    matriz_C(e2,e1) = matriz_C(e2,e1) + integral(@(z) phi2(z).*phi1(z)*c, a, b);
    matriz_C(e2,e2) = matriz_C(e2,e2) + integral(@(z) phi2(z).*phi2(z)*c, a, b);

    % Matriz de masa K
    matriz_K(e1,e1) = matriz_K(e1,e1) + integral(@(z) phi_prima1(z).*phi_prima1(z)*k, a, b);
    matriz_K(e1,e2) = matriz_K(e1,e2) + integral(@(z) phi_prima1(z).*phi_prima2(z)*k, a, b);
    matriz_K(e2,e1) = matriz_K(e2,e1) + integral(@(z) phi_prima2(z).*phi_prima1(z)*k, a, b);
    matriz_K(e2,e2) = matriz_K(e2,e2) + integral(@(z) phi_prima2(z).*phi_prima2(z)*k, a, b);

    % Vector Fg (solo depende de g(x)) parte espacial
    vector_Fg(e1) = vector_Fg(e1) + integral(@(z) g(z).*phi1(z), a, b);
    vector_Fg(e2) = vector_Fg(e2) + integral(@(z) g(z).*phi2(z), a, b);

end

% Ajuste por condición de Neumann en x = L 
vector_Fg(end) = vector_Fg(end) - Qr(0)/h(0);   % Lo hacemos porque luego multiplicamos por h(t)


% =========================================================================
%% 4. REDUCCIÓN POR DIRICHLET EN x=0
% =========================================================================
C_bar = matriz_C(2:end, 2:end);
K_bar = matriz_K(2:end, 2:end);


% =========================================================================
%% 5. MÉTODO DE EULER IMPLÍCITO EN EL TIEMPO
% =========================================================================
tf = 1;  
dt = 0.01;               % paso temporal
M = round(tf/dt);

% Inicializar solución
U = zeros(N, M+1);
U(:,1) = U0(x_nodos);    % Condición inicial


H = C_bar + dt*K_bar;

for n = 1:M
    t_next = n*dt;

    % Ahora el vector F depende del tiempo 
    vector_F_t = h(t_next)*vector_Fg;

    % Ajuste por Dirichlet en nodo 1
    F_bar = vector_F_t(2:end) ...
            - Ul_prima(t_next).*matriz_C(2:end,1) ...
            - Ul(t_next).*matriz_K(2:end,1);

    RHS = C_bar*U(2:end,n) + dt*F_bar;

    U(2:end,n+1) = H \ RHS;    % Resolvemos sistema
    U(1,n+1) = Ul(t_next);     % Imponemos la condicion de Dirichlet 
end


% =========================================================================
%% 6. COMPARACIÓN CON LA SOLUCIÓN EXACTA
% =========================================================================
U_exact = @(x,t) exp(2 - t - x.^2);


figure; hold on; grid on;
plot(x_nodos,U(:,end),'r.-', 'LineWidth',1.8);
plot(x_nodos,U_exact(x_nodos,tf),'k--','LineWidth',2);
legend('Numérica','Exacta','Location','Best');
xlabel('x'); ylabel(['u(x,' num2str(tf) ')']);
title('Comparación solución numérica vs exacta (FEM + Euler Implícito)');

% -------- TABLA DENTRO DE LA FIGURA --------
datos_tabla = {
    'Número de nodos N', N;
    'Paso temporal dt', dt;
    'Tiempo final t_f', tf;
    };

% Crear la tabla dentro de la figura
tabla = annotation('textbox',[0.15,0.15,0.25,0.15], ...
                   'String',sprintf('N = %d\ndt = %.4f\nt_f = %.2f',N,dt,tf), ...
                   'FitBoxToText','on', ...
                   'BackgroundColor',[1 1 1], ...
                   'EdgeColor',[0 0 0], ...
                   'FontSize',10);

