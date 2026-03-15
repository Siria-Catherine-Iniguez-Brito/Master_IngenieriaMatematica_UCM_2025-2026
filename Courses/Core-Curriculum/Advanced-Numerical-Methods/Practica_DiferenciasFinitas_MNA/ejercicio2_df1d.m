function y = ejercicio2_df1d(N, y_0, y_2)
% ------------------------------------------------------------
% ejercicio2_df1d
% ------------------------------------------------------------
% Resuelve el problema de contorno:
%        y'' - y' - 2y = -4x,   x ∈ (0,2)
% con condiciones de frontera de tipo Dirichlet:
%        y(0) = y0,   y(2) = y1
%
% mediante el método de diferencias finitas centradas
% con N puntos interiores (discretización uniforme).
%
% ENTRADAS:
%   N  : número de nodos interiores
%   y_0 : valor de la condición de contorno en x = 0
%   y_2 : valor de la condición de contorno en x = 2
%
% SALIDA:
%   y  : vector columna con la aproximación numérica de y(x)
%        en los puntos [0, h, 2h, ..., 2], incluyendo extremos.
%
% En este problema:  p = -1,  q = -2,  r(x) = -4x
% ------------------------------------------------------------

% Paso de malla
h = 2 / (N + 1);                   

% Nodos interiores
x = linspace(h, 2 - h, N)';         % Puntos internos


% Coeficientes tridiagonales del sistema lineal
a = (1 + h/2);         % subdiagonal (1 - p*h/2)
b = (-2 - 2*h^2);      % diagonal principal (-2 + h^2*q)
c = (1 - h/2);         % superdiagonal (1 + p*h/2)

% Construimos la matriz A
A = gallery('tridiag', N, a, b, c);

% Vector del término independiente (lado derecho)
b_vec = -4 * h^2 * x;

% Ajuste de las condiciones de frontera
b_vec(1) = b_vec(1) - (1 + h/2)*y_0;
b_vec(end) = b_vec(end) - (1 - h/2)*y_2;

% Resolución del sistema lineal
y_internal = A \ b_vec;

% Construcción de la solución completa (incluyendo extremos)
y = [y_0; y_internal; y_2];

end
