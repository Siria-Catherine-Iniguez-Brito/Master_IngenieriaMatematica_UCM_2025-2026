% -------------------------------------------------------------------------
% SCRIPT PRINCIPAL TRABAJO FINAL: EJERCICIO 1 
% -------------------------------------------------------------------------
% Resolución de un problema de conducción de calor en 2D:
% Ecuación: -div(k(x,y) * grad(u)) = f(x,y)
% Dominio: Una elipse con un agujero circular (E\C).
% Condiciones de Contorno (C.C.):
%   1. Dirichlet (u=h) en el borde del Círculo (dC).
%   2. Neumann (du/dn=g) en el borde de la Elipse (dE).
%
% Se utiliza el Método de Elementos Finitos.
% -------------------------------------------------------------------------

clear; close all; clc;

% Cargar los datos del dominio
load("DatosEjFinal.mat") 

% =========================================================================
%% 1. DEFINICIÓN DE FUNCIONES Y PARÁMETROS DEL MALLADO
% =========================================================================

% --- Funciones del Problema ---
k = @(x,y) sqrt(x.^2 + y.^2);     % Coeficiente de difusión kappa(x,y)
f = @(x,y) 4 ;                    % Término fuente f(x,y)
h = @(x,y) 1;                     % Dato de Dirichlet (u=h) en el círculo
g = @(x,y) -1;                    % Dato de Neumann (du/dn=g) en la elipse
q = g;                            % Alias para el dato de Neumann (g)

% --- Parámetros de la Malla ---
baricentro = @(v1, v2, v3) [(v1(1)+v2(1)+v3(1))/3, (v1(2)+v2(2)+v3(2))/3];
vertices = p;                     % Coordenadas de los nodos (N x 2)
D = t;                            % Matriz de los elementos (triangulación)
N = size(p, 1);                   % Número total de nodos
M = size(D, 1);                   % Número total de triángulos (elementos)

% Inicializar matriz de rigidez A y vector de carga L
A = zeros(N,N); 
L = zeros (N,1); 
aristas_Nm = NeumannEdges;        % Lista de aristas en el contorno de Neumann (dE)

% Gradiente de las funciones de forma de referencia (phi_1, phi_2, phi_3)
gradiente_phi_estrella = [-1 -1; 1 0; 0 1];


% =========================================================================
%% 2. ENSAMBLAJE DE LA MATRIZ DE RIGIDEZ (A) Y EL VECTOR DE CARGA (L)
% =========================================================================

% --- 2.1. Contribución de la Integral de Dominio (Rigidez y Fuente) ---
for m = 1: M
    % Nodos e índices locales (v1, v2, v3) del triángulo m
    indices_locales = D(m, :);
    v1 = vertices(indices_locales(1), :);
    v2 = vertices(indices_locales(2), :);
    v3 = vertices(indices_locales(3), :);
   
    % 1. Baricentro (x_0, y_0) para evaluar kappa y f (aproximación)
    coords = baricentro(v1,v2,v3);  
    x_0 = coords(1);   
    y_0 = coords(2);   
     
    % 2. Mapeo de Referencia y Área
    P = [v1; v2; v3];
    grad_F = P'* gradiente_phi_estrella;  
    Area_T = abs(det(grad_F))/2; % Área del triángulo T
     
    % 3. Gradientes de las funciones base (grad(phi_i))
    grad_phi = gradiente_phi_estrella / grad_F; 
    
    % --- Ensamblaje de la Matriz A ---
    R = grad_phi * grad_phi'; 
    A_contrib = Area_T * k(x_0,y_0) * R;
    A(indices_locales, indices_locales) = A(indices_locales, indices_locales) + A_contrib;
     
    % --- Ensamblaje del Vector L ---
    L(indices_locales(1)) =  L(indices_locales(1)) + (Area_T / 3 )* f(v1(1), v1(2));
    L(indices_locales(2)) =  L(indices_locales(2)) + (Area_T / 3 )* f(v2(1), v2(2));
    L(indices_locales(3)) =  L(indices_locales(3)) + (Area_T / 3 )* f(v3(1), v3(2));
end 


% --- 2.2. Contribución de la C.C. de Neumann (Borde de la Elipse) ---
for j = 1:length(aristas_Nm)
         indice_v1 = aristas_Nm(j,1); 
         v1 = vertices(indice_v1, :);
         x_1 = v1(1);
         y_1 = v1(2);
         
         indice_v2 = aristas_Nm(j,2); 
         v2 = vertices(indice_v2, :);
         x_2 = v2(1);   
         y_2 = v2(2);   
         
         % Longitud de la arista (h_j)
         resta = v1 - v2;  
         longitud_arista = norm(resta);
       
         % Contribución al vector L de Neumann
         
         % Contribución en v1
         contrib_v1 = -k(x_1, y_1) * q(x_1, y_1) * (longitud_arista / 2);
         
         % Contribución en v2
         contrib_v2 = -k(x_2, y_2) * q(x_2, y_2) * (longitud_arista / 2);
         
         % Sumar la contribución a los nodos correspondientes
         L(indice_v1) = L(indice_v1) - contrib_v1;
         L(indice_v2) = L(indice_v2) - contrib_v2; 
end 


% =========================================================================
%% 3. APLICACIÓN DE C.C. DIRICHLET Y RESOLUCIÓN DEL SISTEMA
% =========================================================================

% --- 3.1. Identificación de Nodos ---
Dirichlet_Nodos = DirichletNodes; 
Todos_los_Nodos = 1:N; 
% Nodos libres: todos los que NO están en el contorno de Dirichlet
Nodos_libres = setdiff(Todos_los_Nodos, Dirichlet_Nodos); 

% --- 3.2. Construir el Sistema Reducido ---
% Extraer la submatriz de rigidez para los nodos libres
A_barra = A(Nodos_libres, Nodos_libres); 

% Extraer el vector de carga inicial para los nodos libres
L_barra = L(Nodos_libres); 

% --- 3.3. Contribución de los Nodos Dirichlet ---
A_libres_dirichlet = A(Nodos_libres, Dirichlet_Nodos);

% Evaluar el dato h(x,y) en los nodos de Dirichlet
% Dado que h(x,y)=1, creamos un vector de unos.
Num_Dirichlet = length(Dirichlet_Nodos);
u_D_vector = ones(Num_Dirichlet, 1); 

% Restar la contribución de Dirichlet al lado derecho 
L_barra = L_barra - A_libres_dirichlet * u_D_vector;

% --- 3.4. Resolver el Sistema Lineal Reducido ---
U_barra = A_barra \ L_barra; 

% --- 3.5. Reconstruir la Solución Completa U --- 
% Inicializar el vector solución global
U = zeros(N, 1); 
% Asignar los valores calculados a los nodos libres
U(Nodos_libres) = U_barra(:); 
% Asignar el valor conocido (h=1) a los nodos Dirichlet
U(Dirichlet_Nodos) = u_D_vector;


% =========================================================================
%% 4. VISUALIZACIÓN DE LA SOLUCIÓN
% =========================================================================

figure; 
trisurf(D, vertices(:,1), vertices(:,2), U);
title('Solución Aproximada del Ejercicio 1 (Método de Elementos Finitos P1)');
xlabel('Coordenada x');
ylabel('Coordenada y');
zlabel('Solución u(x,y)');
view(3); 
colorbar;   
colormap jet;