function y = ejercicio1_df1d(N, y_0, y_1)
% ------------------------------------------------------------
% ejercicio1_df1d
% ------------------------------------------------------------
% Resuelve el problema de contorno:
%        y'' - y = 0,   x ∈ (0,1)
% con condiciones de frontera de tipo Dirichlet:
%        y(0) = y0,   y(1) = y1
%
% mediante el método de diferencias finitas centradas
% con N puntos interiores (discretización uniforme).
%
% ENTRADAS:
%   N  : número de nodos interiores
%   y0 : valor de la condición de contorno en x=0
%   y1 : valor de la condición de contorno en x=1
%
% SALIDA:
%   y  : vector columna con la aproximación numérica de y(x)
%        en los puntos [0, h, 2h, ..., 1], incluyendo extremos.
% ------------------------------------------------------------

% Paso de malla
h = 1 / (N + 1);

%Construimos la matriz A
A = gallery('tridiag', N, 1, -(2 + h^2), 1);

% Vector del término independiente
b = zeros(N, 1);
b(1) = -y_0;
b(end) = -y_1;

% Resolución del sistema lineal A*y = b
y = A\b; 

% Añadir los valores de contorno al vector solución
y = [y_0; y; y_1]; 
end 




