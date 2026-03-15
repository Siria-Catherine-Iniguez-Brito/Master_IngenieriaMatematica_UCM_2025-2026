function phi_prima = phi_prima_k(y, x, k)
% phi__prima_k: derivada de la función phi
% y : punto(s) donde evaluar (escalar o vector)
% x : vector de nodos
% k : índice del nodo (1 <= k <= length(x))

phi_prima = zeros(size(y)); 

% Caso extremo izquierdo k = 1 → solo tramo derecho [x(1), x(2)]
if k == 1
    idx = (y >= x(1)) & (y <= x(2));
    phi_prima(idx) = -1/(x(2) - x(1));
    return
end

% Caso extremo derecho k = length(x) → solo tramo izquierdo [x(end-1), x(end)]
if k == length(x)
    idx = (y >= x(end-1)) & (y <= x(end));
    phi_prima(idx) = 1/(x(end) - x(end-1));
    return
end


% Caso nodo interior
% Tramo izquierdo: [x(k-1), x(k)]
idx_left = (y >= x(k-1)) & (y <= x(k));
phi_prima(idx_left) = 1/(x(k) - x(k-1));

% Tramo derecho: [x(k), x(k+1)]
idx_right = (y >= x(k)) & (y <= x(k+1));
phi_prima(idx_right) = -1/(x(k+1) - x(k));

end
