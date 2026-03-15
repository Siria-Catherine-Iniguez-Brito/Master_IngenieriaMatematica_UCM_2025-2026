function y = ejercicio6_df1d(N,yN)
% ------------------------------------------------------------
% ejercicio6_df
% ------------------------------------------------------------
% Resuelve el problema de contorno mixto:
%        y'' - y' - 2y = -4x,   x ∈ (0,1)
% con condiciones:
%        y'(0) = 4,   y(1) = 1 + e^2
%
% mediante el método de diferencias finitas centradas.
%
% ENTRADAS:
%   N : número de subintervalos (N+1 nodos)
%
% SALIDA:
%   y : vector columna con la aproximación numérica
%            en los puntos x = 0:h:1 (incluyendo el extremo derecho)
% ------------------------------------------------------------------

% Paso de malla y dominio
h = 1 / N;
x = linspace(0, 1, N+1);     % N+1 puntos (incluye 0 y 1)
%yN = 1 + exp(2);             % Condición Dirichlet en x = 1

% --- Diagonales de la matriz tridiagonal ---
lower = (1 + h/2) * ones(N-1,1);   % Subdiagonal (a)
main  = (-2 - 2*h^2) * ones(N,1);  % Diagonal principal (b)
upper = (1 - h/2) * ones(N-1,1);   % Superdiagonal (c)

% --- Modificar la primera fila (condición de Neumann) ---
main(1)  = -(1 + h^2);
upper(1) = 1;

% --- Construcción de la matriz A ---
A = diag(main) + diag(upper,1) + diag(lower,-1);

% --- Construcción del vector del lado derecho ---
b = -4 * x(1:N)' * h^2;           % término fuente -4x_i * h^2
b(1)   = 4 * (h + 0.5*h^2);       % condición de Neumann en x=0
b(end) = b(end) - (1 - h/2)*yN;   % condición de Dirichlet en x=1

% --- Resolución del sistema A*y = b ---
y_inner = A \ b;

% --- Solución completa (añadiendo extremo derecho) ---
y = [y_inner; yN];
end


