function matriz_U = ejercicio1_edp(N, M, T, f)
% ------------------------------------------------------------
% ejercicio1_edp
% ------------------------------------------------------------
% Resuelve numéricamente la ecuación del calor 1D:
%
%        u_t = u_xx,       (x,t) ∈ (0,1) × (0,T)
%
% con condiciones de contorno homogéneas:
%        u(0,t) = 0,   u(1,t) = 0,
%
% y condición inicial:
%        u(x,0) = f(x).
%
% mediante el método de diferencias finitas explícito (Euler hacia adelante).
%
% El dominio se discretiza con paso espacial h y paso temporal dt.
% En cada paso de tiempo se aplica el esquema:
%
%        U^{n+1} = (I + (dt/h^2) * D) * U^n,
%
% donde D es la matriz tridiagonal que representa la segunda derivada
% espacial.
%
% ENTRADAS:
%   N : número de nodos interiores en el espacio (sin contar los extremos)
%   M : número de pasos temporales
%   T : tiempo final de simulación
%   f : función anónima con la condición inicial f(x)
%
% SALIDA:
%   matriz_U : matriz (M+2) × (N+2) con las soluciones aproximadas
%              u(x_i, t_j) en cada nodo y paso temporal,
%              incluyendo las fronteras x = 0 y x = 1 (ambas nulas).
% ------------------------------------------------------------

% --- Discretización espacial y temporal ---
h  = 1 / (N + 1);          % Paso de malla espacial
dt = T / (M + 1);          % Paso de tiempo

% --- Vector de coordenadas espaciales ---
vector_X = 0:h:1;
vector_X = vector_X(2:end-1);   % Solo nodos interiores

% --- Inicialización de la matriz de resultados ---
matriz_U = zeros(M+2, N);

% --- Condición inicial ---
vector_U = f(vector_X);     % Evaluar f(x) en nodos interiores
vector_U = vector_U(:);     % Asegurar formato de columna
matriz_U(1,:) = vector_U;   % Primer instante (t=0)

% --- Construcción de la matriz del operador Laplaciano (2ª derivada) ---
diagonal = -2 * ones(N,1);       % Diagonal principal
sup = ones(N-1,1);               % Super- e sub-diagonales
D = diag(diagonal) + diag(sup,1) + diag(sup,-1);

% --- Iteración temporal (esquema explícito) ---
for j = 2:M+1
    vector_U = ((dt/h^2) * D + eye(N)) * vector_U;   % Avance en el tiempo
    matriz_U(j,:) = vector_U';                       % Guardar resultado
end
% --- Añadir fronteras nulas (u=0 en x=0 y x=1) ---
matriz_U = [zeros(M+2,1), matriz_U, zeros(M+2,1)];
end
 
