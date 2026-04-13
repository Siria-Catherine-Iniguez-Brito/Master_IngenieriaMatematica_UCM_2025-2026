%% PRACTICA 2: 

clear; clc; close all;

colores = [0.0, 0.0, 0.0;  
           0.8, 0.2, 0.2;   
           0, 0.3, 0.6;     
           0.5, 0.5, 0.5]; 

%% APARTADO A
% Parámetros ---
T = 1.0;            % Tiempo total (s)
dt = 0.0005;        % Paso de tiempo 
t = 0:dt:T;
N = length(t);

tau = 0.02;         % Constante de tiempo 
Vth = 1.0;          % Umbral
Vreset = 0;         % Reinicio
w = 0.4;            % Peso sináptico 
f1_demo = 60;       % Frecuencia de entrada 


% Simulación 
spikes1 = rand(1, N) < (f1_demo * dt); % Tren de Poisson (Neurona 1)
V = zeros(1, N);                       % Potencial (Neurona 2)
spikes2 = zeros(1, N);                 % Salida (Neurona 2)

for i = 1:N-1
    V(i+1) = V(i) + dt * (-V(i)/tau);
    if spikes1(i)
        V(i+1) = V(i+1) + w;
    end
   
    if V(i+1) >= Vth
        spikes2(i+1) = 1; % Registro de la espiga de salida
        V(i+1) = Vreset;  % Reinicio instantáneo
    end
end


figure('Color', 'w');

% Entrada (Neurona 1 - Poisson)
subplot(3,1,1);
stem(t, spikes1, 'Marker', 'none', 'Color', [0.5 0.5 0.5]);
ylabel('Spikes 1', 'Interpreter', 'latex');
title('Entrada: Tren de Poisson (Neurona 1)', 'Interpreter', 'latex');
set(gca, 'TickDir', 'out', 'YTick', [0 1]);

% Potencial de Membrana (Neurona 2)
subplot(3,1,2); hold on;
plot(t, V, 'b', 'LineWidth', 1);
yline(Vth, '--r', 'Umbral $V_{th}$', 'Interpreter', 'latex', 'LabelHorizontalAlignment', 'left');
ylabel('$V(t)$', 'Interpreter', 'latex');
title('Dinamica del Potencial de Membrana', 'Interpreter', 'latex');
grid on; ylim([0 Vth+0.2]);

% Respuesta (Neurona 2 - Salida)
subplot(3,1,3);
stem(t, spikes2, 'Marker', 'none', 'Color', 'r', 'LineWidth', 1.2);
xlabel('Tiempo (s)', 'Interpreter', 'latex');
ylabel('Spikes 2', 'Interpreter', 'latex');
title('Respuesta: Tren de salida (Neurona 2)', 'Interpreter', 'latex');
set(gca, 'TickDir', 'out', 'YTick', [0 1]);


%% APARTADO B: CURVA DE TRANSFERENCIA f2 vs f1
f1_range = 0:5:100;     
n_reps = 100;           
f2_results = zeros(size(f1_range));

for j = 1:length(f1_range)
    current_f1 = f1_range(j);
    f2_temp = zeros(1, n_reps);
    
    for r = 1:n_reps
        s1 = rand(1, N) < current_f1 * dt;
        v_mem = 0;
        out_spikes = 0;
        for i = 1:N
            v_mem = v_mem + dt * (-v_mem/tau);
            if s1(i)
                v_mem = v_mem + w;
            end
            if v_mem >= Vth
                out_spikes = out_spikes + 1;
                v_mem = Vreset;
            end
        end
        f2_temp(r) = out_spikes / T;
    end
    f2_results(j) = mean(f2_temp);
end

figure('Color', 'w');
hold on; grid on;

plot(f1_range, f2_results, 'o-', 'Color', colores(3,:), ...
    'LineWidth', 1.8, ...
    'MarkerSize', 6, ...
    'MarkerEdgeColor', colores(1,:), ...
    'MarkerFaceColor', colores(3,:), ...
    'DisplayName', 'Respuesta promedio');

xlabel('Frecuencia de entrada $f_1$ (Hz)', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('Frecuencia de salida $f_2$ (Hz)', 'Interpreter', 'latex', 'FontSize', 13);
title('Curva de transferencia de la neurona LIF', 'Interpreter', 'latex', ...
    'FontSize', 16, 'FontName', 'Times');

set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, ...
    'LineWidth', 0.8, 'GridAlpha', 0.3);

xlim([0 max(f1_range)]);
ylim([0 max(f2_results) + 5]);

lgd = legend('Location', 'west', 'Interpreter', 'latex');
legend boxoff;