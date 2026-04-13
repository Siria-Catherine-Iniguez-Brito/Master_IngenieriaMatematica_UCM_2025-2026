%% PRACTICA 4:

clear; clc; close all;

colores = [0, 0.3, 0.6;   
           0.8, 0.2, 0.2; 
           0.1, 0.5, 0.2; 
           0.9, 0.6, 0;   
           0.4, 0.4, 0.4]; 


%% APARTADO A: 
a = 0; b = 0.3; 
N = 40; 
punto_fijo = [1/0.7, 0.3/0.7];

% Condiciones iniciales
CIs = [0.2, 0.1; 0.2, 0.45; 1.4, 0.05; 1.0, 0.45; 0.6, 0.25];

figure('Color', 'w');
hold on; grid on;

h_trayectorias = zeros(1, size(CIs,1));

for i = 1:size(CIs,1)
    x = zeros(1,N); y = zeros(1,N);
    x(1) = CIs(i,1); y(1) = CIs(i,2);
    
    for t = 2:N
        x(t) = 1 - a*x(t-1)^2 + y(t-1);
        y(t) = b*x(t-1);
    end
    
    h_trayectorias(i) = plot(x, y, '.-', 'Color', colores(i,:), ...
        'LineWidth', 0.8, 'MarkerSize', 7, 'MarkerFaceColor', colores(i,:));
    
    plot(x(1), y(1), 'o', 'Color', colores(i,:), 'MarkerSize', 5, 'HandleVisibility', 'off');
end

% Punto Fijo 
h_pf = plot(punto_fijo(1), punto_fijo(2), 'kx', 'MarkerSize', 10, 'LineWidth', 1.5);

xlabel('$x_t$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$y_t$', 'Interpreter', 'latex', 'FontSize', 13);
title(['Evoluci\''on de trayectorias ($a = ', num2str(a), '$)'], ...
      'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');

set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, 'LineWidth', 0.8);
axis([0 1.6 0 0.5]);

lgd2 = legend([h_trayectorias, h_pf], ...
    {'Tray. 1', 'Tray. 2', 'Tray. 3', 'Tray. 4', 'Tray. 5', 'Punto Fijo $P^*$'}, ...
    'Interpreter', 'latex', 'Location', 'west');
legend boxoff;


%% APARTADO B: 

% Parámetros
a_crit = 0.3675;
a_vals = linspace(0.01, 1.4, 1000);
a_p2 = linspace(a_crit, 1.4, 1000);

% Cálculo de puntos fijos Periodo 1
x_pos = (-0.7 + sqrt(0.7^2 + 4*a_vals)) ./ (2*a_vals);
x_neg = (-0.7 - sqrt(0.7^2 + 4*a_vals)) ./ (2*a_vals);

% Cálculo de ciclo Periodo 2
x_p2_sup = (0.7 + sqrt(4*a_p2 - 1.47)) ./ (2*a_p2);
x_p2_inf = (0.7 - sqrt(4*a_p2 - 1.47)) ./ (2*a_p2);


figure;
hold on; grid on;

% Punto fijo x+ 
h1 = plot(a_vals(a_vals < a_crit), x_pos(a_vals < a_crit), 'Color', colores(1, :), 'LineWidth', 1.8);
h2 = plot(a_vals(a_vals >= a_crit), x_pos(a_vals >= a_crit), '--', 'Color', colores(1, :), 'LineWidth', 1.2);

% Punto fijo x- 
h3 = plot(a_vals, x_neg, '--', 'Color', colores(2,:), 'LineWidth', 1.2);

% Ciclo de Periodo 2 
h4 = plot(a_p2, x_p2_sup, 'Color', colores(3,:), 'LineWidth', 1.5);
h5 = plot(a_p2, x_p2_inf, 'Color', colores(3,:), 'LineWidth', 1.5);

% Punto de Bifurcación 
x_crit = (-0.7 + sqrt(0.7^2 + 4*a_crit)) ./ (2*a_crit);
h6 = plot(a_crit, x_crit, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5, 'DisplayName', 'Bifurcaci\''on Flip');
xline(a_crit, ':', 'Color', colores(5,:), 'LineWidth', 0.8);


xlabel('$a$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$x^*$', 'Interpreter', 'latex', 'FontSize', 13);
title('Diagrama de bifurcaci\''on anal\''itico', 'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, 'LineWidth', 0.8);
xlim([0 1.4]);
ylim([-5 3]);

lgd = legend([h1, h2, h3, h4, h6], ...
    {'P1 estable ($x^*_+$)', 'P1 inestable', 'P1 silla ($x^*_-$)', 'Ciclo Periodo 2', 'Bifurcaci\''on Flip'}, ...
    'Interpreter', 'latex', 'Location', 'southeast');
legend boxoff;


%% APARTADO C: Diagrama de Bifurcaciones 
b = 0.3;
a_vals = linspace(0, 1.4, 1000);
results = []; 

figure(3)
hold on
for a = a_vals
    x = 0.1; y = 0.1;
    for i = 1:500
        x_n = 1 - a*x^2 + y;
        y = b*x;
        x = x_n;
    end
    x_save = zeros(1, 100);
    for i = 1:100
        x_n = 1 - a*x^2 + y;
        y = b*x;
        x = x_n;
        x_save(i) = x;
    end
    plot(a * ones(1,100), x_save, '.k', 'MarkerSize', 1)
end
grid on;          

xlabel('$a$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$x$', 'Interpreter', 'latex', 'FontSize', 13);
title('Diagrama de bifurcaciones', 'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');

set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, 'LineWidth', 0.8);
xlim([0 1.4]);
ylim([-1.5 1.5]); 


%% APARTADO D: CÁLCULO DE LA DIMENSIÓN DE MINKOWSKI 
% Parámetros para el régimen caótico
a_caos = 1.4; 
b_caos = 0.3;
N_puntos = 500000;

x_caos = zeros(N_puntos,1); 
y_caos = zeros(N_puntos,1);
x_caos(1) = 0.1; y_caos(1) = 0.1; % Condición inicial

% Iteración del sistema
for t = 2:N_puntos
    x_caos(t) = 1 - a_caos*x_caos(t-1)^2 + y_caos(t-1);
    y_caos(t) = b_caos*x_caos(t-1);
end

data = [x_caos(2001:end), y_caos(2001:end)];

% Normalización al intervalo [0, 1]
data_min = min(data);
data_max = max(data);
data_norm = (data - data_min) ./ (data_max - data_min);

% Definir radios r y Algoritmo de conteo (Box-Counting)
r_values = 2.^(-(1:20)); 
N_r = zeros(size(r_values));

for i = 1:length(r_values)
    r = r_values(i);
    nIntr = ceil(1/r); 
    xscal = ceil(nIntr * data_norm);
    xscal(xscal == 0) = 1;
    N_r(i) = size(unique(xscal, 'rows'), 1);
end

% Cálculo de la pendiente (Dimensión de Minkowski)
log_inv_r = log(1./r_values);
log_N = log(N_r);

rango = 1:14; % Solo los puntos donde el escalado es válido

p_fit = polyfit(log_inv_r(rango), log_N(rango), 1);
dim_M = p_fit(1);

figure('Color','w');
hold on; grid on;

plot(log_inv_r, log_N, 'ko', 'MarkerFaceColor', [0.4 0.4 0.4], 'MarkerSize', 5, 'DisplayName', 'Datos $N(r)$');
plot(log_inv_r, polyval(p_fit, log_inv_r), 'r-', 'LineWidth', 1.8, 'DisplayName', 'Ajuste lineal');

line([log_inv_r(14) log_inv_r(14)], [min(log_N) max(log_N)], 'Color', [0.6 0.6 0.6], 'LineStyle', '--', 'HandleVisibility', 'off');

xlabel('$\ln(1/r)$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$\ln(N(r))$', 'Interpreter', 'latex', 'FontSize', 13);
title(['Dimensi\''on de Minkowski ($d_M \approx ', num2str(dim_M, 4), '$)'], 'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, 'LineWidth', 0.8, 'GridAlpha', 0.3);
legend('Location', 'northwest', 'Interpreter', 'latex');
legend boxoff;


% Para la dimension de Correlacion
sub_data = data(1:10000, :);  
dist_matrix = pdist(sub_data);
r_corr = logspace(-3, 0, 20);
Cr = zeros(size(r_corr));

for i = 1:length(r_corr)
    Cr(i) = sum(dist_matrix < r_corr(i)) / (length(dist_matrix));
end

log_r = log(r_corr);
log_Cr = log(Cr);
rango_c = 5:15; 
p_corr = polyfit(log_r(rango_c), log_Cr(rango_c), 1);
dim_D2 = p_corr(1);

figure('Color','w');
hold on; grid on;

plot(log_r, log_Cr, 'bo', 'MarkerFaceColor', [0.3 0.5 0.9], 'MarkerSize', 5, 'DisplayName', 'Datos $C(r)$');
plot(log_r, polyval(p_corr, log_r), 'r-', 'LineWidth', 1.8, 'DisplayName', 'Ajuste lineal');

xlabel('$\ln(r)$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$\ln(C(r))$', 'Interpreter', 'latex', 'FontSize', 13);
title(['Dimensi\''on de Correlaci\''on ($D_2 \approx ', num2str(dim_D2, 4), '$)'], ...
      'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');

set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, 'LineWidth', 0.8, 'GridAlpha', 0.3);
legend('Location', 'northwest', 'Interpreter', 'latex');
legend boxoff;

% Mostrar resultados finales por consola
fprintf('--- Resultados finales para a = %.2f ---\n', a_caos);
fprintf('Dimensión de Minkowski (d_M): %.4f\n', dim_M);
fprintf('Dimensión de Correlación (D_2): %.4f\n', dim_D2);