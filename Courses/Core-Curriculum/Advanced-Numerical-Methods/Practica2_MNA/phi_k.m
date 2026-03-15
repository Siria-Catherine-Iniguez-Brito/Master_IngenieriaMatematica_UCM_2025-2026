function phi = phi_k(y, x, k)
% phi_k: función vectorizada
% y : punto(s) donde evaluar (puede ser escalar o vector)
% x : vector de nodos [x1, x2, ..., xN]
% k : índice del nodo (1 <= k <= N)

phi = zeros(size(y)); 

% Caso extremo izquierdo k = 1 → solo tramo derecho
if k == 1
    idx = (y >= x(1)) & (y <= x(2));
    phi(idx) = (x(2) - y(idx)) ./ (x(2) - x(1));
    return
end

% Caso extremo derecho k = N → solo tramo izquierdo
if k == length(x)
    idx = (y >= x(end-1)) & (y <= x(end));
    phi(idx) = (y(idx) - x(end-1)) ./ (x(end) - x(end-1));
    return
end


% Caso nodo interior
% Tramo izquierdo: [x(k-1), x(k)]
idx_left = (y >= x(k-1)) & (y <= x(k));
phi(idx_left) = (y(idx_left) - x(k-1)) ./ (x(k) - x(k-1));

% Tramo derecho: [x(k), x(k+1)]
idx_right = (y >= x(k)) & (y <= x(k+1));
phi(idx_right) = (x(k+1) - y(idx_right)) ./ (x(k+1) - x(k));

end

