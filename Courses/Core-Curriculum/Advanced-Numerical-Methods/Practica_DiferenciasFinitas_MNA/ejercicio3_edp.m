function matriz_U = ejercicio3_edp(N, M, T, f)
% ------------------------------------------------------------
% ejercicio1_df1d
% ------------------------------------------------------------
% Resuelve numericamente la ecuacion del calor con el metodo de
% CRANK–NICHOLSON:
%
%   u_t = u_xx ,  x ∈ (0,1),  t ∈ (0,T)
%   u(0,t) = 0 ,  u(1,t) = 0
%   u(x,0) = f(x)
%
% ENTRADAS:
%   N : número de nodos interiores en el espacio
%   M : número de pasos en el tiempo
%   T : tiempo final
%   f : función inicial (handle de MATLAB)
%
% SALIDA:
%   matriz_U : matriz (M+2) x (N+2) con la solución numérica
%              Incluye los valores en los bordes (x=0 y x=1)
%-------------------------------------------------------------

% Paso espacial
h = 1 / (N + 1);

% Paso temporal
dt = T / (M + 1);

% Vector con los nodos espaciales (0, h, 2h, ..., 1)
vector_X = 0:h:1;

% Eliminamos los extremos (solo nodos interiores)
vector_X = vector_X(2:end-1);

% Inicializamos la matriz que contendrá las soluciones
% Cada fila representa un instante de tiempo
% Cada columna un nodo interior
matriz_U = zeros(M + 2, N);

% Condición inicial: u(x,0) = f(x)
vector_U = f(vector_X);
vector_U = vector_U(:);              

% Guardamos la condición inicial en la primera fila
matriz_U(1,:) = vector_U';

%-------------------------------------------------------------
% MATRIZ (D^2)
%-------------------------------------------------------------
% D es la matriz tridiagonal que aproxima la derivada segunda
%   D = diag(-2) + diag(1,1) + diag(1,-1)
diagonal = -2 * ones(N,1);
sup      =  ones(N-1,1);
D = diag(diagonal) + diag(sup,1) + diag(sup,-1);

%-------------------------------------------------------------
% MATRICES DEL MÉTODO DE CRANK–NICHOLSON
%-------------------------------------------------------------
% Coeficiente c = dt / (2*h^2)
c = dt / (2 * h^2);

% Matriz del sistema implícito:
%   (I - cD) U^{j+1} = (I + cD) U^j
A = speye(N) - c * D;   % Matriz del lado izquierdo
B = speye(N) + c * D;   % Matriz del lado derecho

%-------------------------------------------------------------
% CALCULAMOS U^{j+1}
%-------------------------------------------------------------
% Avanzamos desde t = 0 hasta t = T
for j = 2 : M + 1
    % Resolución del sistema lineal:
    % U^{j+1} = A^{-1} * (B * U^j)
    vector_U = A \ (B * vector_U);

    % Guardamos el resultado en la matriz de soluciones
    matriz_U(j,:) = vector_U';
end

%-------------------------------------------------------------
% CONDICIONES DE CONTORNO (u=0 en x=0 y x=1)
%-------------------------------------------------------------
% Añadimos columnas de ceros a izquierda y derecha
matriz_U = [zeros(M+2,1), matriz_U, zeros(M+2,1)];

end
