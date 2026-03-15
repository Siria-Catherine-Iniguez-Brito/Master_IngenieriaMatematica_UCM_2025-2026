function matriz_U = ejercicio5_edp(N, M, T, f)
% ------------------------------------------------------------
% ejercicio5_edp
% ------------------------------------------------------------
% Resuelve numéricamente la ECUACIÓN DE ONDAS en 1D:
%
%        u_tt = u_xx,       (x,t) ∈ (0,2) × (0,T)
%
% con condiciones de contorno homogéneas:
%        u(0,t) = 0,   u(2,t) = 0,
%
% y condiciones iniciales:
%        u(x,0)  = f(x),
%        u_t(x,0) = π·sin(πx).
%
% mediante el MÉTODO DE DIFERENCIAS FINITAS EXPLÍCITO.
%
%
% ENTRADAS:
%   N : número de nodos interiores en el espacio (sin contar los extremos)
%   M : número de pasos temporales
%   T : tiempo final de simulación
%   f : función anónima con la condición inicial f(x)
%
% SALIDA:
%   matriz_U : matriz (M+1) × (N+2) con las soluciones aproximadas
%              u(x_i, t_j) en cada nodo y paso temporal,
%              incluyendo las fronteras x = 0 y x = 2 (ambas nulas).
% ------------------------------------------------------------

% --- Discretización espacial y temporal ---
h  = 2 / (N + 1);        % Paso espacial en el dominio [0,2]
dt = T / (M + 1);        % Paso temporal

% --- Vector de nodos interiores ---
vector_X = (1:N) * h;    % Puntos x_i = i*h, i=1..N

% --- Condición inicial u(x,0) ---
vector_U0 = f(vector_X);     % Evaluar f(x) en nodos interiores
vector_U0 = vector_U0(:);    % Asegurar formato de columna

% --- Inicialización de la matriz de resultados ---
% matriz_U almacenará U^0, U^1, ..., U^M
matriz_U = zeros(M + 1, N);
matriz_U(1,:) = vector_U0';  % Primera fila = condición inicial

% --- Velocidad inicial u_t(x,0) ---
V0 = pi * sin(pi * vector_X)';   % Derivada temporal inicial
V0 = V0(:);

% --- Cálculo de U^1 (primer paso temporal) ---
% Usamos:
%   U^1 = U^0 + dt·u_t^0 + ½(dt²)·u_xx^0
% donde u_xx^0 se calcula con diferencias centradas.
U0ext = [0; vector_U0; 0];   % Añadir fronteras (u=0)
lap = (U0ext(3:end) - 2*U0ext(2:end-1) + U0ext(1:end-2)) / h^2;
vector_U1 = vector_U0 + dt*V0 + 0.5*(dt^2)*lap;
matriz_U(2,:) = vector_U1';  % Segunda fila = U^1

% --- Construcción de la matriz D ---
diagonal = -2 * ones(N,1);
sup = ones(N-1,1);
D = diag(diagonal) + diag(sup,1) + diag(sup,-1);

% --- Parámetro de Courant ---
c = dt / h;

% --- Iteración temporal (esquema explícito) ---
% Para j = 1,...,M-1:
%   U^{j+1} = (2I + c²D)·U^j - U^{j-1}
for j = 2:M
    vector_U = (2*eye(N) + c^2 * D) * matriz_U(j,:)' - matriz_U(j-1,:)';
    matriz_U(j+1,:) = vector_U';
end

% --- Añadir fronteras nulas (u=0 en x=0 y x=2) ---
matriz_U = [zeros(M+1,1), matriz_U, zeros(M+1,1)];

end

