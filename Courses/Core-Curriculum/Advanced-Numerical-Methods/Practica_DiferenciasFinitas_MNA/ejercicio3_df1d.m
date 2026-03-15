function y = ejercicio3_df1d(N, y_0, y_1)
% ------------------------------------------------------------
% ejercicio3_df1d
% ------------------------------------------------------------
% Resuelve el problema de contorno:
%        y'' - x y' - 2x^2 y = 2 e^{x^2},   x ∈ (0,1)
% con condiciones de frontera de tipo Dirichlet:
%        y(0) = y0,   y(1) = y1
%
% mediante el método de diferencias finitas centradas
% con N puntos interiores (discretización uniforme).
%
% ENTRADAS:
%   N  : número de nodos interiores
%   y_0 : valor de la condición de contorno en x = 0
%   y_1 : valor de la condición de contorno en x = 1
%
% SALIDA:
%   y  : vector columna con la aproximación numérica de y(x)
%        en los puntos [0, h, 2h, ..., 1], incluyendo extremos.
%
% ESQUEMA NUMÉRICO:
%   (1 + h x_i / 2) y_{i-1} + (-2 - 2 h^2 x_i^2) y_i
%   + (1 - h x_i / 2) y_{i+1} = 2 h^2 e^{x_i^2}
% ------------------------------------------------------------

% Paso de la malla 
h = 1 / (N + 1);                        
x = linspace(h, 1 - h, N)';             % Puntos interiores

% Inicializar matriz A y vector b
A = zeros(N, N);
b = zeros(N, 1);

% Construcción de A y b
for i = 1:N
    xi = x(i);
    
    % Coeficientes locales
    ai = 1 + (h * xi) / 2;            % Coef. de y_{i-1}
    bi = -2 - 2 * h^2 * xi^2;         % Coef. de y_i
    ci = 1 - (h * xi) / 2;            % Coef. de y_{i+1}
    
    % Término fuente
    fi = 2 * exp(xi^2);               % f(x_i)
    
    % Rellenar matriz y vector
    if i > 1
        A(i, i-1) = ai;
    else
        % Corrección por condición en x=0
        b(i) = b(i) - ai * y_0;
    end
    
    A(i, i) = bi;
    
    if i < N
        A(i, i+1) = ci;
    else
        % Corrección por condición en x=1
        b(i) = b(i) - ci * y_1;
    end
    
    % Parte del término independiente (h^2 * f(x_i))
    b(i) = b(i) + fi * h^2;
end

% Resolución del sistema lineal A * y = b
y = A \ b;

% Construcción del vector solución completo
y = [y_0; y; y_1];
end
