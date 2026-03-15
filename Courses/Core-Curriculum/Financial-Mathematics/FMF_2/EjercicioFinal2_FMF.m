clear all;

%% --- Parámetros del Modelo ---
K = 100;        
r = @(t) 0.06 + 0*t;      
sigma = @(t) 0.2 + 0*t;
q = @(t) 0.035 + 0*t;
S0 = 90;

S_max = 3 * K;       
T = 1/2;              

N_sim = 10^4;

pasos = 10.^[2 3 4];
media_abs_error = zeros(size(pasos));

for l = 1: length(pasos)
    %% --- Configuración de la Malla de Diferencias Finitas ---
    M = 1000; 
    N = pasos(l);
    h = S_max / M; 
    tau = T / N;
        
    n_filas = M + 1;    
    n_columnas = N + 1; 

    matriz = zeros(n_filas, n_columnas);
    
    
    %% --- Condiciones de Contorno e Iniciales ---
    matriz(:, end) = max((0:M)*h' - K, 0);
    tiempo = 0: tau: T ; 
    vec_r = r(tiempo);
    vec_q = q(tiempo);
    matriz(end, :) = S_max * exp(-trapz(tiempo, vec_q) + cumtrapz(tiempo, vec_q)) - K * exp(-trapz(tiempo, vec_r) + cumtrapz(tiempo, vec_r));
    %matriz(1, :) = 0; 
    
    i_vec = (1:M-1)'; 
    ai1 = (tau / 4) * ((r(tiempo(N + 1)) - q(tiempo(N + 1))) * i_vec - sigma(tiempo(N + 1))^2 * (i_vec.^2));
    bi1 = (tau / 2) * (sigma(tiempo(N + 1))^2 * i_vec.^2 + r(tiempo(N + 1)));
    ci1 = (-tau / 4) * ((r(tiempo(N + 1)) - q(tiempo(N + 1))) * i_vec + sigma(tiempo(N + 1))^2 * (i_vec.^2));
    
    for j = n_columnas : -1 : 2
        
        vector_d = zeros(M - 1, 1);
        vector_d(end) = -ci1(end) * matriz(M + 1,j); 
     
        izq = (1 - bi1) .* matriz(2 : end - 1, j) - [ci1(1: end - 1) .* matriz(3 : end - 1, j); 0] - [0; ai1(2 : end) .* matriz(2 : end - 2, j)];

        ai1 = (tau / 4) * ((r(tiempo(j - 1)) - q(tiempo(j - 1)))* i_vec - sigma(tiempo(j - 1))^2 * (i_vec.^2));
        bi1 = (tau / 2) * (sigma(tiempo(j - 1))^2 * i_vec.^2 + r(tiempo(j - 1)));
        ci1 = (-tau / 4) * ((r(tiempo(j - 1)) - q(tiempo(j - 1))) * i_vec + sigma(tiempo(j - 1))^2 * (i_vec.^2));
        
        vector_d(end) = vector_d(end) - ci1(end) * matriz(M + 1,j - 1);
        
        matriz(2 : M, j - 1) = tridiag(ai1(2 : end), 1 + bi1, ci1(1 : end - 1), izq + vector_d);  
    end 
    
    
    S = zeros(N_sim, N);       
    S(:, 1) = S0;

    % --- Generación de Caminos  ---
    for j = 2 : n_columnas
        Z = randn(N_sim, 1);
        S(:, j) = S(:, j - 1) .* (1 + r(tiempo(j - 1)) * tau + sigma(tiempo(j - 1)) * sqrt(tau) * Z);
    end

    S_filas = (0 : M)' * h;
    i0 = zeros(N_sim, 1);
    i0(:) = floor(S0 ./ h) + 1;

    % --- Matriz de Deltas  ---
    Mdelta = zeros(n_filas, n_columnas);
    
    for j = 1:n_columnas
        for i = 2 : n_filas-1
            Mdelta(i, j) = (matriz(i + 1, j) - matriz(i - 1, j)) / (2 * h);
        end
        Mdelta(1, j) = (-3*matriz(1, j) + 4 * matriz(2,j) - matriz(3, j)) / (2 * h);
        Mdelta(end, j) = (matriz(end - 2, j) - 4 * matriz(end - 1, j) + 3 * matriz(end, j)) / (2 * h);
    end
    
    alpha = zeros(N_sim, 1); 
    for k = 1 : N_sim
        alpha(k) = (S_filas(i0(k) + 1) - S0) / (S_filas(i0(k) + 1) - S_filas(i0(k)));
    end 

    delta = zeros(N_sim, n_columnas);
    delta(:, 1) = alpha .* Mdelta(i0, 1) + (1 - alpha) .* Mdelta(i0 + 1, 1);
    
    d = zeros(N_sim, n_columnas);
    d(:, 1) = alpha .* matriz(i0, 1) + (1 - alpha) .* matriz(i0 + 1, 1) - delta(1) * S0; 
    
    % Cartera
    pi = zeros(N_sim, n_columnas);
    pi(:, 1) = delta(1) * S0 + d(1); 

    % Bucle algoritmo
    for j = 2 : N
        
        pi(:, j) = delta(:, j-1) .* S(:, j) .* exp(q(tiempo(j-1)) * tau) + d(:,j - 1) .* exp(r(tiempo(j - 1)) * tau); 
    
        i0(:) = floor(S(:, j) ./ h) + 1;
        
        for k = 1:N_sim
            alpha(k) = (S_filas(i0(k) + 1) - S(k, j)) / (S_filas(i0(k) + 1) - S_filas(i0(k)));
        end 
        
        delta(:,j) = alpha(:) .* Mdelta(i0, j) + (1 - alpha(:)) .* Mdelta(i0 + 1, j); 
    
        d(:,j) = (delta(:, j - 1) .* exp(q(tiempo(j - 1)) * tau) - delta(:, j)) .* S(:, j) + d(:, j - 1) .* exp(r(tiempo(j - 1)) * tau);
    end 
    pi(:, N+1) = delta(:, N) .* S(:, N+1) .* exp(q(tiempo(N)) * tau) + d(:,N) .* exp(r(tiempo(N)) * tau);
    
    payoff_real = max(S(:, end) - K, 0);
    
    % Error de replicación
    error_replicacion = pi(:, end) - payoff_real;
    
    % Histogramas de Error de Replicación 
    figure('Name', ['Histograma Error N = ' num2str(pasos(l))], 'NumberTitle', 'off');
    histogram(error_replicacion, 50, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'w');
    grid on;
    title(['Distribución del Error de Replicación (\Pi_T - Payoff) para N = ' num2str(pasos(l))]);
    xlabel('Error de Replicación');
    ylabel('Frecuencia (Simulaciones)');
    
    hold on;
    line([0 0], ylim, 'Color', 'r', 'LineStyle', '--', 'LineWidth', 2);

    
    % Estadísticas
    fprintf('--- Resultados de la Replicación (N = %d) ---\n', pasos(l));
    fprintf('Error medio absoluto: %.4f\n', mean(abs(error_replicacion)));
    fprintf('Error máximo: %.4f\n', max(abs(error_replicacion)));

    if l == 2
        figure('Name', 'Analisis de Trayectorias: Activo vs Cartera', 'NumberTitle', 'off');
        
        n_caminos = 5;
        colores = jet(n_caminos); 
        
        % --- Activo Subyacente (S) ---
        subplot(2, 1, 1);
        hold on;
        for idx = 1 : n_caminos
            plot(tiempo, S(idx,:), 'Color', colores(idx,:), 'LineWidth', 1, ...
                'DisplayName', ['Camino ' num2str(idx)]);
        end
        title('Evolucion del Activo Subyacente (S)');
        ylabel('Precio (S)');
        grid on;
        legend('Location', 'northeastoutside');

        % --- Cartera Replicante (Pi) ---
        subplot(2, 1, 2);
        hold on;
        for idx = 1:n_caminos
            plot(tiempo, pi(idx,:), 'Color', colores(idx,:), 'LineWidth', 1, ...
                'DisplayName', ['Cartera ' num2str(idx)]);
        end
        title('Valor de la Cartera de Replica (\Pi)');
        xlabel('Tiempo (t)');
        ylabel('Valor (\Pi)');
        grid on;
        legend('Location', 'northeastoutside');
        
    end
    
    payoff_final = max(S(:, end) - K, 0);
    error_final = pi(:, end) - payoff_final;
    media_abs_error(l) = mean(abs(error_final));

end 

figure('Name','Anális del error');
loglog(pasos, media_abs_error, '-s', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
grid on;
xlabel('Número de pasos de tiempo (N)');
ylabel('Error Medio Absoluto');
title('Análisis de Convergencia del Error de Cobertura');




