function y = ejercicio8_df1d(N, y0, yprima)
% ------------------------------------------------------------
% ejercicio8_df1d
% ------------------------------------------------------------
% Resuelve el problema:
%   y'' - x y' - 2 x^2 y = 2 e^{x^2},   x ∈ (0,1)
% con condiciones mixtas:
%   y(0) = y0,      (Dirichlet)
%   y'(1) = yprima, (Neumann)
%
% Método: diferencias finitas centradas (orden O(h^2)).
% ------------------------------------------------------------

h = 1 / N;
x = linspace(0, 1, N+1)';  % Nodos x_0, x_1,...,x_N

x_int = x(2:N);            % Puntos interiores x_1, ..., x_{N-1} (Longitud N-1)

% Coeficientes de la EDO (a_i, b_i, c_i, d_i) para i=1,...,N-1
a_sub  = 1 + (h/2)*x_int;         % Coeficiente de y_{i-1}
b_diag = -2 - 2*h^2 * x_int.^2;  % Coeficiente de y_i
c_sup  = 1 - (h/2)*x_int;         % Coeficiente de y_{i+1}
rhs    = 2 * h^2 * exp(x_int.^2); % Término independiente d_i

% Construcción de matriz tridiagonal A (dim (N-1)x(N-1))
A = diag(b_diag) + ...
    diag(c_sup(1:end-1), 1) + ... % Superdiagonal c_1, ..., c_{N-2}
    diag(a_sub(2:end), -1);       % Subdiagonal a_2, ..., a_{N-1}

% --- 1. Condición Dirichlet en x=0: y(0)=y0 ---
% Modifica el lado derecho (rhs_1 = d_1 - a_1*y0)
rhs(1) = rhs(1) - a_sub(1)*y0;

% --- 2. Condición Neumann en x=1: y'(1) = yprima ---
c_N1 = c_sup(end); % c_{N-1}

% Modificación de la última ecuación (i=N-1) por sustitución de y_N:
% A(N-1, N-2) = a_{N-1} - c_{N-1}/3
A(end,end-1) = a_sub(end) - c_N1/3;

% A(N-1, N-1) = b_{N-1} + 4*c_{N-1}/3
A(end,end)   = b_diag(end) + (4*c_N1)/3;

% rhs(N-1) = d_{N-1} - c_{N-1}*(2h*yprima)/3
rhs(end)     = rhs(end) - (2*h*yprima*c_N1)/3; 

% Resolver sistema (obtiene y_1, ..., y_{N-1})
y_inner = A \ rhs;

% --- 3. Recuperar y_N (el nodo en x=1) ---
% Usamos la fórmula de la derivada de 2º orden despejada:
if N >= 2
    yN = (4*y_inner(end) - y_inner(end-1) + 2*h*yprima) / 3;
else
    % Caso N pequeño (por seguridad)
    yN = y_inner(end) + h*yprima;
end

% Solución completa: [y_0; y_1; ...; y_{N-1}; y_N]
y = [y0; y_inner; yN];

end