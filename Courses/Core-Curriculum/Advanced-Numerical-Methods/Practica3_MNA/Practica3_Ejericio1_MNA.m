% -------------------------------------------------------------------------
% SCRIPT PRINCIPAL PRACTICA 3 Ejercicio 1
% -------------------------------------------------------------------------
% Método de Elementos Finitos lineales (P1) sobre una malla triangular
% Dominio: círculo
%
% Ecuación:
%    -div(k(x,y) * grad(u)) = f(x,y)   en Ω
%     u = h(x,y)                       en ∂Ω
%
% -------------------------------------------------------------------------

clear; close all; clc;
load("DatosEj1.mat")

% =========================================================================
%% 1. DEFINICIÓN DE DATOS DEL PROBLEMA
% =========================================================================

k = @(x,y) 1+ y.^2;                  % Coeficiente de difusión
f = @(x,y)  -1 + (x.^2+y.^2)/ 2 ;    % Término fuente
h = @(x,y) 1;                        % Condición de Dirichlet (en el borde)

% Función para calcular el baricentro de un triángulo
baricentro = @(v1, v2, v3) [(v1(1)+v2(1)+v3(1))/3, (v1(2)+v2(2)+v3(2))/3];

vertices = pcircle;     % Coordenadas de los nodos (N x 2)
D = tcircle;            % Matriz de los elementos 

N = size(vertices, 1);  % Número total de nodos
M = size(D, 1);         % Número total de triángulos

% Inicializar matriz de rigidez A y vector de carga L
A = zeros(N,N); 
L = zeros (N,1); 


% Gradiente de las funciones de forma de referencia
gradiente_phi_estrella = [-1 -1; 1 0; 0 1];


% =========================================================================
%% 2. ENSAMBLAJE DE MATRIZ A Y VECTOR L
% =========================================================================

for m = 1: M
    % --- Nodos del elemento m ---
    indices_locales = D(m, :);
    indice_v1 = indices_locales(1);
    indice_v2 = indices_locales(2);
    indice_v3 = indices_locales(3);
    
    % --- Coordenadas de los vértices ---
    v1 = vertices(indice_v1, :);
    v2 = vertices(indice_v2, :);
    v3 = vertices(indice_v3, :);
   
    % --- Baricentro y área ---
     coords = baricentro(v1,v2,v3);  
     x_0 = coords(1);   % Asigna la primera componente (x)
     y_0 = coords(2);   % Asigna la segunda componente (y)
     
     P = [v1; v2; v3];
     grad_F = P'* gradiente_phi_estrella;  
     T = abs (det(grad_F)) /2; % Área del triángulo
     
    % --- Gradientes de las funciones base ---
     grad_phi = gradiente_phi_estrella / grad_F; 
     R = grad_phi * grad_phi'; 
     
     % Ensamblaje de A (usando la aproximación del baricentro)
     A_contrib = abs(T)*k(x_0,y_0)* R;
     A(indice_v1, indice_v1) = A(indice_v1, indice_v1) + A_contrib(1,1);
     A(indice_v1, indice_v2) = A(indice_v1, indice_v2) + A_contrib(1,2);
     A(indice_v1, indice_v3) = A(indice_v1, indice_v3) + A_contrib(1,3);
     A(indice_v2, indice_v1) = A(indice_v2, indice_v1) + A_contrib(2,1);
     A(indice_v2, indice_v2) = A(indice_v2, indice_v2) + A_contrib(2,2);
     A(indice_v2, indice_v3) = A(indice_v2, indice_v3) + A_contrib(2,3);
     A(indice_v3, indice_v1) = A(indice_v3, indice_v1) + A_contrib(3,1);
     A(indice_v3, indice_v2) = A(indice_v3, indice_v2) + A_contrib(3,2);
     A(indice_v3, indice_v3) = A(indice_v3, indice_v3) + A_contrib(3,3);
     
     % Ensamblaje de L 
     L(indice_v1) =  L(indice_v1) + (T / 3)* f(v1(1), v1(2));
     L(indice_v2) =  L(indice_v2) + (T / 3)* f(v2(1), v2(2));
     L(indice_v3) =  L(indice_v3) + (T / 3)* f(v3(1), v3(2));
end 


% =========================================================================
%% 3. APLICACIÓN DE CONDICIONES DIRICHLET Y RESOLUCIÓN
% =========================================================================

Dirichlet_Nodos = boundary_points;
All_Nodos = 1:N; 
Nodos_libres = setdiff(All_Nodos, Dirichlet_Nodos);

% Construir el Sistema Reducido 
A_bar = A(Nodos_libres, Nodos_libres); 
L_bar = L(Nodos_libres); 

% Submatriz A_{libres, Dirichlet}
A_libres_dirichlet = A(Nodos_libres, Dirichlet_Nodos);

% Evaluar h en nodos de contorno
x_d = vertices(Dirichlet_Nodos,1);
y_d = vertices(Dirichlet_Nodos,2);
u_D_vec = h(x_d, y_d); 
u_D_vector = ones(length(Dirichlet_Nodos), 1) * u_D_vec;

% Restar la contribución de Dirichlet: {L} = L_{libres} - A_{libres,Dirichlet} * u_D
L_bar = L_bar - A_libres_dirichlet * u_D_vector;

% Resolver el Sistema Lineal
U_bar = A_bar \ L_bar; 

% Reconstruir la Solución Completa U 
U = zeros(N, 1); 
U(Nodos_libres) = U_bar(:); 
U(Dirichlet_Nodos) = u_D_vector; 


% =========================================================================
%% 4. VISUALIZACIÓN 3D 
% =========================================================================

figure; 
trisurf(D, vertices(:,1), vertices(:,2), U);
title('Solución del Ejercicio 1 (Método de Elementos Finitos)');
xlabel('Coordenada x');
ylabel('Coordenada y');
zlabel('u(x,y)');
view(3); 
colorbar;   
colormap jet;