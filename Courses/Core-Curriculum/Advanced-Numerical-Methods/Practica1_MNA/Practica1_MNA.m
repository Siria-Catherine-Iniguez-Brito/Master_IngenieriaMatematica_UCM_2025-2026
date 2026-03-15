% -------------------------------------------------------------------------
% SCRIPT PRINCIPAL PRACTICA 1
% -------------------------------------------------------------------------
% Este script calcula la solución aproximada U(x) a una E.D.O. de valor
% de contorno homogéneo -u''(x) = f(x) (con k=1) usando el Método de Galerkin 
% con elementos finitos lineales (L.T.).
%
% El script evalúa dos tipos de mallados:
% 1. Malla Adaptada (no uniforme)
% 2. Malla Regular (uniforme)
%
% Requiere las funciones: practica1.m, U_approx.m, U_prime_approx.m
% -------------------------------------------------------------------------

clear all; close all; clc;

% =========================================================================
%% 1. DEFINICIONES GLOBALES Y SOLUCIÓN EXACTA
% =========================================================================

% --- Parámetros del Problema ---
t_i = 0;   % Inicio del dominio (x=0)
L = 1;     % Fin del dominio (x=1)
k = 1;     % Coeficiente de difusión (-[k*u']' = f).
M = 15;    % Número de nodos interiores (grados de libertad)

% --- Funciones Exactas ---
% Solución exacta u(x)
solucion_exacta = @(z) exp(-5*(z-0.5).^2) - exp(-5/4);

% Fuente f(x) = -[k*u']'
f = @(z) 10 * (1 - 10*(z - 0.5).^2) .* exp(-5*(z - 0.5).^2);

% Derivada exacta u'(x)
derivada_exacta = @(z) exp(-5*(z-0.5).^2) .* (-10*(z - 0.5));


% =========================================================================
%% 2. ANÁLISIS CON MALLADO ADAPTADO (NO UNIFORME)
% =========================================================================

disp('--- Malla Adaptada (M=15) ---');

% Vector de longitudes de paso h_k proporcionado para la malla adaptada.
% h tiene M+1 elementos (h_1 hasta h_{M+1}).
h_adaptada = [0.2012, 0.0673, 0.0493, 0.0417, 0.0376, 0.0353, 0.0341, 0.0335,...
              0.0335, 0.0341, 0.0353, 0.0376, 0.0417, 0.0493, 0.0673, 0.2012 ];

% Resolver el sistema: [coef, x] = practica1(t_i, L, h, f, k, M)
[coef_adaptado, x_adaptado] = practica1(t_i, L, h_adaptada, f, k, M); 

% --- 2.1 Cálculo del Error L2 de la Solución ---
L2_squared_error_adaptado = 0;
for k_err = 1:(M + 1)
    x_k = x_adaptado(k_err);
    x_kp1 = x_adaptado(k_err+1);
    
    % Integrando: |u(x) - U(x)|^2. Se usa U_approx.m
    integrand = @(x_int) (solucion_exacta(x_int) - U_approx(x_int, x_adaptado, coef_adaptado)).^2;
    
    % Sumar la contribución del elemento I_k
    L2_squared_error_adaptado = L2_squared_error_adaptado + integral(integrand, x_k, x_kp1);
end
L2_error_adaptado = sqrt(L2_squared_error_adaptado);
disp(['Error L2 de la solución (Adaptada): ', num2str(L2_error_adaptado)]);


% --- 2.2 Gráfica de la Solución U(x) vs. u(x) ---
y_plot_sol = linspace(t_i, L, 500); % Puntos de evaluación para la gráfica
U_plot_sol_adaptada = U_approx(y_plot_sol, x_adaptado, coef_adaptado);
titulo_sol_adaptada = sprintf('Solución Aproximada vs. Exacta (Malla Adaptada, M=%d)\nError L2: %.6f', M, L2_error_adaptado);

figure; 
plot(y_plot_sol, U_plot_sol_adaptada, 'b-', 'DisplayName', 'Aproximada U(x)');
hold on;
plot(y_plot_sol, solucion_exacta(y_plot_sol), 'r--', 'DisplayName', 'Exacta u(x)');
title(titulo_sol_adaptada);
xlabel('x');
ylabel('u(x)');
legend show;
grid on;


% --- 2.3 Gráfica de la Derivada U'(x) vs. u'(x) ---
U_nodes_adaptado = [0; coef_adaptado; 0];
U_prime_plot_adaptada = U_prime_approx(y_plot_sol, x_adaptado, coef_adaptado);
sol_prime_e = derivada_exacta(y_plot_sol); 

% Cálculo del Error H1-seminorma (Error L2 de la derivada)
H1_semi_squared_error_adaptado = 0;
for k_err = 1:(M + 1)
    x_k = x_adaptado(k_err);
    x_kp1 = x_adaptado(k_err+1);
    h_k = x_kp1 - x_k;
    
    % U'(x) es constante U_prime_k en el intervalo (se calcula con la fórmula del elemento)
    U_prime_k = (U_nodes_adaptado(k_err+1) - U_nodes_adaptado(k_err)) / h_k;
    
    % Integrando: |u'(x) - U'(x)|^2
    integrand_prime = @(x_int) (derivada_exacta(x_int) - U_prime_k).^2;
    
    H1_semi_squared_error_adaptado = H1_semi_squared_error_adaptado + integral(integrand_prime, x_k, x_kp1);
end
H1_semi_error_adaptado = sqrt(H1_semi_squared_error_adaptado);
disp(['Error L2 de la derivada (Adaptada): ', num2str(H1_semi_error_adaptado)]);

titulo_prime_adaptada = sprintf('Derivada Aproximada vs. Exacta (Malla Adaptada, M=%d)\nError L2 de la Derivada: %.6f', M, H1_semi_error_adaptado);

figure; 
plot(y_plot_sol, U_prime_plot_adaptada, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Aproximada U''(x)');
hold on;
plot(y_plot_sol, sol_prime_e, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Exacta u''(x)');
title(titulo_prime_adaptada);
xlabel('x');
ylabel("Derivada u'(x)");
legend show;
grid on;


% --- 2.4 Gráfica de la Función Base (Solo phi_1 del Mallado Adaptado) ---
disp(' ');
disp('--- Visualización de la Base phi_1 (Malla Adaptada) ---');

% La base phi_1 está asociada al nodo interior x_2 (x_nodes(2))
% Su soporte es [x_1, x_3].
x_1_adaptada = x_adaptado(1);     % x_1
x_2_adaptada = x_adaptado(2);     % x_2 (nodo donde phi_1 = 1)
x_3_adaptada = x_adaptado(3);     % x_3
h_1_adaptada = x_adaptado(2) - x_adaptado(1); % h_1
h_2_adaptada = x_adaptado(3) - x_adaptado(2); % h_2 (diferente de h_1)

% Definición explícita de phi_1(z)
phi1_adaptada = @(z) ((x_1_adaptada <= z) & (z <= x_2_adaptada)) .* ((z - x_1_adaptada) ./ h_1_adaptada) + ...
                   ((x_2_adaptada < z) & (z <= x_3_adaptada)) .* ((x_3_adaptada - z) ./ h_2_adaptada);

z_adaptada = linspace(t_i, L, 400); % Vector de puntos para la gráfica
zy_adaptada = phi1_adaptada(z_adaptada);              % Evaluación vectorial de phi_1(z)

figure;
plot(z_adaptada, zy_adaptada, 'm-', 'LineWidth', 2);
title('Visualización de la Función Base \phi_1 (Malla Adaptada, M=15)');
xlabel('x');
ylabel('\phi_1(x)');
grid on;


% =========================================================================
%% 3. ANÁLISIS CON MALLADO REGULAR (UNIFORME)
% =========================================================================

disp(' ');
disp('--- Malla Regular (M=15) ---');

% Vector de longitudes de paso h_k regular (M+1 elementos iguales)
h_regular = 1/(M+1)*ones(1,M+1);

% Resolver el sistema FEM
[coef_regular, x_regular] = practica1(t_i, L, h_regular, f, k, M); 

% --- 3.1 Cálculo del Error L2 de la Solución (||u - U||_2) ---
L2_squared_error_regular = 0;
for k_err = 1:(M + 1)
    x_k = x_regular(k_err);
    x_kp1 = x_regular(k_err+1);
    
    % Integrando: |u(x) - U(x)|^2. Se usa U_approx.m
    integrand = @(x_int) (solucion_exacta(x_int) - U_approx(x_int, x_regular, coef_regular)).^2;
    
    % Sumar la contribución del elemento
    L2_squared_error_regular = L2_squared_error_regular + integral(integrand, x_k, x_kp1);
end
L2_error_regular = sqrt(L2_squared_error_regular);
disp(['Error L2 de la solución (Regular): ', num2str(L2_error_regular)]);


% --- 3.2 Gráfica de la Solución U(x) vs. u(x) ---
% Reutilizamos y_plot_sol
U_plot_sol_regular = U_approx(y_plot_sol, x_regular, coef_regular);
titulo_sol_regular = sprintf('Solución Aproximada vs. Exacta (Malla Regular, M=%d)\nError L2: %.6f', M, L2_error_regular);

figure; 
plot(y_plot_sol, U_plot_sol_regular, 'b-', 'DisplayName', 'Aproximada U(x)');
hold on;
plot(y_plot_sol, solucion_exacta(y_plot_sol), 'r--', 'DisplayName', 'Exacta u(x)');
title(titulo_sol_regular);
xlabel('x');
ylabel('u(x)');
legend show;
grid on;


% --- 3.3 Gráfica de la Derivada U'(x) vs. u'(x) ---
U_nodes_regular = [0; coef_regular; 0];
U_prime_plot_regular = U_prime_approx(y_plot_sol, x_regular, coef_regular);

% Cálculo del Error H1-seminorma (Error L2 de la derivada)
H1_semi_squared_error_regular = 0;
for k_err = 1:(M + 1)
    x_k = x_regular(k_err);
    x_kp1 = x_regular(k_err+1);
    h_k = x_kp1 - x_k;
    
    % U'(x) es constante U_prime_k en el intervalo (se calcula con la fórmula del elemento)
    U_prime_k = (U_nodes_regular(k_err+1) - U_nodes_regular(k_err)) / h_k;
    
    % Integrando: |u'(x) - U'(x)|^2
    integrand_prime = @(x_int) (derivada_exacta(x_int) - U_prime_k).^2;
    
    H1_semi_squared_error_regular = H1_semi_squared_error_regular + integral(integrand_prime, x_k, x_kp1);
end
H1_semi_error_regular = sqrt(H1_semi_squared_error_regular);
disp(['Error L2 de la derivada (Regular): ', num2str(H1_semi_error_regular)]);


titulo_prime_regular = sprintf('Derivada Aproximada vs. Exacta (Malla Regular, M=%d)\nError L2 de la Derivada: %.6f', M, H1_semi_error_regular);

figure; 
plot(y_plot_sol, U_prime_plot_regular, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Aproximada U''(x)');
hold on;
plot(y_plot_sol, sol_prime_e, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Exacta u''(x)');
title(titulo_prime_regular);
xlabel('x');
ylabel("Derivada u'(x)");
legend show;
grid on;


% =========================================================================
%% 4. DIBUJO DE LA FUNCIÓN BASE (Solo phi_1 - Malla Regular)
% =========================================================================
% Esto es para visualizar la forma de la función base phi_1
disp(' ');
disp('--- Visualización de la Base phi_1 (Malla Regular) ---');

% La base phi_1 está asociada al nodo interior x_2 (x_nodes(2))
% Su soporte es [x_1, x_3]. x_nodes tiene 17 nodos.
x_1 = x_regular(1);     % x_1
x_2 = x_regular(2);     % x_2 (nodo donde phi_1 = 1)
x_3 = x_regular(3);     % x_3
h_1 = x_regular(2) - x_regular(1); % h_1

% Definición explícita de phi_1(z)
phi1 = @(z) ((x_1 <= z) & (z <= x_2)) .* ((z - x_1) ./ h_1) + ...
            ((x_2 < z) & (z <= x_3)) .* ((x_3 - z) ./ h_1); % h_2 = h_1 en malla regular

z = linspace(t_i, L, 400); % Vector de puntos para la gráfica
zy = phi1(z);              % Evaluación vectorial de phi_1(z)

figure;
plot(z, zy, 'g-', 'LineWidth', 2);
title('Visualización de la Función Base \phi_1 (Malla Regular, M=15)');
xlabel('x');
ylabel('\phi_1(x)');
grid on;


% =========================================================================
%% 5. FUNCIONES 
% =========================================================================
function [coef, x] = practica1(t_i, L, h, f, k, M)
% ------------------------------------------------------------
% practica1
% ------------------------------------------------------------
% Resuelve numéricamente la Ecuación de Sturm-Liouville 1D:
%
%        -[k * u'(x)]' = f(x),   (x) ∈ (t_i, L)
%
% con condiciones de contorno homogéneas de Dirichlet:
%        u(t_i) = 0,   u(L) = 0.
%
% mediante el Método de Galerkin con Elementos Finitos Lineales a Trozos.
% El dominio se discretiza con un vector de pasos 'h' (malla adaptada o regular).
%
% El sistema lineal a resolver es la formulación variacional:
%
%        A * coef = b,
%
% donde A es la matriz de rigidez y b es el vector de carga.
%
% ENTRADAS:
%   t_i : Coordenada inicial del dominio (usualmente 0)
%   L   : Coordenada final del dominio (usualmente 1)
%   h   : Vector de longitudes de paso de la malla (M+1 elementos)
%   f   : Función anónima con la función fuente f(x)
%   k   : Coeficiente de difusión k (usualmente 1)
%   M   : Número de nodos interiores (grados de libertad)
%
% SALIDA:
%   coef : Vector de M coeficientes [xi_1, ..., xi_M], que son los valores
%          de la solución aproximada U en los nodos interiores [x_2, ..., x_{M+1}].
%   x    : Vector de todos los nodos de la malla [x_1, ..., x_{M+2}],
%          incluyendo las fronteras.
% ------------------------------------------------------------


%--- 1. Generación del mallado (Vector de Nodos x) ---

% Inicializa el vector de nodos 'x' con M+2 elementos (M nodos interiores + 2 extremos).
x = zeros(M + 2, 1);
% Asigna la condición de contorno de inicio: x_1 = t_i.
x(1) = t_i;
% Asigna la condición de contorno final: x_{M+2} = L.
x(end, 1) = L;

% Nodos interiores: construye los nodos x_i sumando las longitudes de paso h_{i-1}.
for i = 2: (length(x) - 1)
    x(i) = x(i-1) + h(i-1); 
end 

% --- 2. Construcción de la Matriz de Rigidez A (Sistema A * xi = b) ---
% La matriz A es tri-diagonal simétrica para k=constante.

% A_ii (Elementos de la diagonal principal):
diagonal = ones(M,1);
for i = 1:M
    diagonal(i, 1) = k*(1/h(i) + 1/ h(i+1)); 
end 

% A_{i, i+1} (Elementos de la diagonal superior)
sup = ones(M-1,1);
for i = 1:M-1
    sup(i, 1) = -k/h(i+1); 
end 

% A_{i+1, i} (Elementos de la diagonal inferior):
inf = ones(M-1,1);
for i = 2:M
    inf(i-1, 1) = -k/h(i); 
end 

% Ensambla la matriz tri-diagonal A.
A = diag(diagonal) + diag(sup, 1) + diag(inf, -1);


% --- 3. Construcción del Vector de Carga b ---
b = ones(M,1);
for i = 1:M
    
    % Contribución del lado izquierdo: intervalo [x_{i}, x_{i+1}].
    integral_izquierda = integral(@(y) f(y) .* ((y - x(i)) ./ h(i)), x(i), x(i+1));
    
    % Contribución del lado derecho: intervalo [x_{i+1}, x_{i+2}].
    integral_derecha = integral(@(y) f(y) .* ((x(i+2) - y) ./ h(i+1)), x(i+1), x(i+2));

    % Suma ambas contribuciones para obtener b_i
    b(i) = integral_izquierda + integral_derecha;
end

% --- 4. Resolución del Sistema ---

% Resuelve el sistema lineal A * coef = b
coef = A\b; 

end 

function U_val = U_approx(x_val, x_nodes, coef)
% ------------------------------------------------------------
% U_approx
% ------------------------------------------------------------
% Calcula la solución aproximada de Elementos Finitos (FEM) U(x)
% mediante la suma directa de las funciones base lineales (phi_j),
% ponderadas por sus coeficientes (xi_j):
%
%           U(x) = sum_{j=1}^{M} coef(j) * phi_j(x)
%
% NOTA: Esta función asume que U(x_1)=0 y U(x_{M+2})=0 (C.C. de Dirichlet
% homogéneas), por lo que solo suma sobre las M bases interiores.
%
% ENTRADAS:
%   x_val: Vector de puntos (x) donde se desea evaluar la solución U(x).
%   x_nodes: Vector de todos los nodos de la malla [x_1, ..., x_{M+2}].
%   coef: Coeficientes [xi_1, ..., xi_M] (valores de U en los nodos interiores).
%
% SALIDA:
%   U_val: Vector con los valores de la solución aproximada U(x) evaluada en x_val.
% ------------------------------------------------------------

M = length(coef);
U_val = zeros(size(x_val)); % Inicializamos el vector de resultados U(x) a cero


% Iteramos sobre cada grado de libertad (j = 1 a M) que corresponde
% a los nodos interiores x_{j+1} y a la función base phi_j.
for j = 1:M
     % --- 1. Definir los nodos y pasos de soporte para la base phi_j ---

     x_j   = x_nodes(j);     % Nodo izquierdo (x_j)
     x_jp1 = x_nodes(j+1);   % Nodo central (x_{j+1})
     x_jp2 = x_nodes(j+2);   % Nodo derecho (x_{j+2})
        
     % Longitudes de paso de los dos elementos que forman el soporte
     h_j   = x_jp1 - x_j;
     h_jp1 = x_jp2 - x_jp1;

     % --- 2. Construcción vectorial de la base phi_j(x_val) ---
        
     % Tramo IZQUIERDO (ascendente): phi_j(x) = (x - x_j) / h_j
     % El tramo está activo solo en el intervalo [x_j, x_{j+1}]
     phi_j_izq = ((x_j <= x_val) & (x_val <= x_jp1)) .* ((x_val - x_j) / h_j);
        
     % Tramo DERECHO (descendente): phi_j(x) = (x_{j+2} - x) / h_{j+1}
     % El tramo está activo solo en el intervalo (x_{j+1}, x_{j+2}]
     phi_j_der = ((x_jp1 < x_val) & (x_val <= x_jp2)) .* ((x_jp2 - x_val) / h_jp1);
        
     % La función base phi_j es la suma de sus tramos
     phi_j = phi_j_izq + phi_j_der;
        
     
     % --- 3. Acumular la contribución ---
        
     % Suma la contribución del coeficiente actual (coef(j)) multiplicado por
     % el valor de la base phi_j evaluada en los puntos x_val.
     U_val = U_val + coef(j) * phi_j;
end
end

function U_prime_val = U_prime_approx(x_val, x_nodes, coef)
% ------------------------------------------------------------
% U_prime_approx
% ------------------------------------------------------------
% Calcula la derivada de la solución aproximada de Elementos Finitos U'(x),
% que es una función constante a trozos.
%
% La derivada en cada elemento I_k = [x_k, x_{k+1}] es simplemente la
% pendiente constante de la función lineal U(x):
%
%        U'(x) |_(I_k) = (U(x_{k+1}) - U(x_k)) / h_k
%
% Se asume que la solución U(x) incluye las condiciones de contorno (C.C.)
% homogéneas, es decir, U(x_1)=0 y U(x_{M+2})=0.
%
% ENTRADAS:
%   x_val: Vector de puntos (x) donde se desea evaluar U'(x).
%   x_nodes: Vector de todos los nodos de la malla [x_1, ..., x_{M+2}].
%   coef: Coeficientes [xi_1, ..., xi_M] (valores de U en los nodos interiores).
%
% SALIDA:
%   U_prime_val: Vector con los valores de la derivada U'(x) evaluada en x_val.
% ------------------------------------------------------------    
    M = length(coef);
    % U en todos los nodos (incluyendo C.C.): U(0)=0, U(L)=0
    U_nodes = [0; coef; 0]; 
    U_prime_val = zeros(size(x_val)); % Inicializamos el vector de resultados
    
    % Iteramos sobre cada intervalo o elemento (k = 1 a M+1)
    for k = 1:(M + 1)
        % --- 1. Definir el elemento I_k = [x_k, x_{k+1}] y su pendiente ---
        x_k = x_nodes(k);
        x_kp1 = x_nodes(k+1);
        h_k = x_kp1 - x_k;
        
        % U'(x) es constante en el intervalo [x_k, x_{k+1}]. Se calcula como la
        % diferencia de valores de la solución en los nodos dividida por el paso h_k.
        U_prime_k = (U_nodes(k+1) - U_nodes(k)) / h_k;
        

        % --- 2. Asignar el valor constante a los puntos de evaluación ---

        % Encontrar los índices (idx) de los puntos de evaluación x_val que caen 
        % dentro del elemento actual [x_k, x_{k+1}].
        idx = (x_val >= x_k) & (x_val <= x_kp1);
        
        % Asignar la derivada constante (U_prime_k) a todos los puntos encontrados.
        U_prime_val(idx) = U_prime_k;
    end
end