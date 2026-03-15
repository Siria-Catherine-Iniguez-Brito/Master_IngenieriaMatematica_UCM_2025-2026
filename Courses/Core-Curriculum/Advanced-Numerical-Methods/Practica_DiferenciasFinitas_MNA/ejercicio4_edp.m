function [t_sol, U_sol] = ejercicio4_edp(N, T, f)
% ------------------------------------------------------------
% ejercicio4_edp
% ------------------------------------------------------------
% Resuelve numéricamente la ecuación del calor 1D mediante el
% MÉTODO DE LÍNEAS (semidiscretización en el espacio):
%
%        u_t = u_xx,       (x,t) ∈ (0,1) × (0,T)
%
% con condiciones de contorno homogéneas:
%        u(0,t) = 0,   u(1,t) = 0,
%
% y condición inicial:
%        u(x,0) = f(x).
%
% ENTRADAS:
%   N : número de nodos interiores en el espacio (sin contar los extremos)
%   T : tiempo final de simulación
%   f : función anónima con la condición inicial f(x)
%
% SALIDAS:
%   t_sol : vector columna con los tiempos calculados por ode23s
%   U_sol : matriz (longitud(t_sol)) × (N+2) con las soluciones
%           aproximadas u(x_i, t_j), incluyendo las fronteras
%           x = 0 y x = 1 (ambas nulas).
% ------------------------------------------------------------

% --- Discretización espacial ---
h = 1 / (N + 1);        % Paso de malla espacial

% --- Construcción de la matriz Laplaciana (solo nodos interiores) ---
% La matriz D :
%   D = tridiag(1, -2, 1)

e = ones(N,1);
D = spdiags([e -2*e e], -1:1, N, N);

% --- Definición del sistema semidiscreto ---
% Se obtiene el sistema ODE:
%        U'(t) = (1/h^2) * D * U(t)
rhs = @(t,U) (1/h^2) * (D * U);

% --- Nodos interiores del dominio espacial ---
x = (1:N)' * h;

% --- Condición inicial (en nodos interiores) ---
U0 = f(x);

% --- Integración temporal mediante ode23s ---
% Se integra el sistema U'(t) = rhs(t,U) en el intervalo [0, T],
% partiendo de la condición inicial U0.
[t_sol, U_sol] = ode23s(rhs, [0, T], U0);

% --- Condiciones de contorno ---
% Añadimos las columnas correspondientes a los bordes x=0 y x=1,
% donde se cumple u = 0 para todo t.
U_sol = [zeros(length(t_sol),1), U_sol, zeros(length(t_sol),1)];

end
