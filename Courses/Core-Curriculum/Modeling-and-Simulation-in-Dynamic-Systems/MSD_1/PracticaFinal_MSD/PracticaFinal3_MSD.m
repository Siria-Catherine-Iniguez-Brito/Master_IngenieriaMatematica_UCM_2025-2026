%% PROBLEMA 3: MODELO DE FITZHUGH-NAGUMO

clear; close all; clc;

colores = [0.0, 0.0, 0.0;   
           0.8, 0.2, 0.2;   
           0.0, 0.3, 0.6;   
           0.1, 0.5, 0.2; 
           0.7, 0.2, 0.5];  

opts = odeset('RelTol',1e-7,'AbsTol',1e-9);

%% APARTADO B: 
% CASO 1: UN EQUILIBRIO 
epsilon = 0.05; 
a = 0.2;
gamma = 1;   
f = @(v,w) v.*(v-a).*(1-v) - w;
g = @(v,w) epsilon*(v - gamma*w);
sistema = @(t,y) [f(y(1),y(2)); g(y(1),y(2))];

figure('Color','w'); 
hold on; grid on;

v_vals = linspace(-0.5, 1.2, 300);

h1 = plot(v_vals, v_vals.*(v_vals-a).*(1-v_vals), 'Color', colores(1,:), 'LineWidth', 1.8);
h2 = plot(v_vals, v_vals/gamma, '--', 'Color', colores(2,:), 'LineWidth', 1.5);


v0 = linspace(-0.4, 1.1, 5);
w0 = linspace(-0.1, 0.3, 5);
for i=1:length(v0)
    for j=1:length(w0)
        [~,y] = ode45(sistema, [0 300], [v0(i); w0(j)], opts);
        plot(y(:,1), y(:,2), 'Color', [colores(3,:), 0.3], 'HandleVisibility','off')
    end
end

h3 = plot(0,0,'ko','MarkerFaceColor', colores(4,:), 'MarkerSize', 7);


xlabel('$v$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$w$', 'Interpreter', 'latex', 'FontSize', 13);
title('Plano de fases: 1 equilibrio', 'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, 'LineWidth', 0.8, 'GridAlpha', 0.3);
axis([-0.5 1.5 -0.5 0.5]);

lgd1 = legend([h1 h2 h3], {'Nulclina $\dot{v}=0$', 'Nulclina $\dot{w}=0$', 'Nodo Estable $P_1$'}, ...
    'Interpreter', 'latex', 'Location', 'southeast');
legend boxoff;

% CASO 2: TRES EQUILIBRIOS
a_2 = 0.1; 
gamma_2 = 10; 
epsilon_2 = 0.01;

f2 = @(v,w) v.*(v-a_2).*(1-v) - w;
g2 = @(v,w) epsilon_2*(v - gamma_2*w);
sistema2 = @(t,y) [f2(y(1),y(2)); g2(y(1),y(2))];

% Cálculo de raíces y puntos
v_raices = roots([-1, (1+a_2), -(a_2+1/gamma_2), 0]);
eq_v = sort(v_raices); 
eq_w = eq_v / gamma_2;

vs = eq_v(2); 
ws = eq_w(2); 

dfdv = -3*vs^2 + 2*(1+a_2)*vs - a_2; 
J = [dfdv, -1; epsilon_2, -epsilon_2*gamma_2];
[V_mat, D_mat] = eig(J);
[~, idx_u] = max(diag(real(D_mat))); 
[~, idx_s] = min(diag(real(D_mat))); 

figure('Color','w'); 
hold on; grid on;

v_plot = linspace(-0.5, 1.2, 300); 
h_n1 = plot(v_plot, v_plot.*(v_plot-a_2).*(1-v_plot), 'Color', colores(1,:), 'LineWidth', 1.8);
h_n2 = plot(v_plot, v_plot/gamma_2, '--', 'Color', colores(2,:), 'LineWidth', 1.5);

% Variedades de la Silla 
d_init = 1e-4; t_sep = 300; 
for s = [1, -1]
    [~, r_s] = ode45(@(t,y) -sistema2(t,y), [0 t_sep], [vs; ws] + s*d_init*V_mat(:,idx_s), opts);
    h_estable = plot(r_s(:,1), r_s(:,2), 'Color', colores(4,:), 'LineWidth', 2.2); 
    [~, r_u] = ode45(sistema2, [0 t_sep], [vs; ws] + s*d_init*V_mat(:,idx_u), opts);
    h_inestable = plot(r_u(:,1), r_u(:,2), 'Color', colores(5,:), 'LineWidth', 2.2); 
end

% Trayectorias de fondo
[V2, W2] = meshgrid(linspace(-0.4, 1.1, 8), linspace(-0.02, 0.12, 6));
for i=1:numel(V2)
    [~, tr] = ode45(sistema2, [0 300], [V2(i); W2(i)], opts);
    plot(tr(:,1), tr(:,2), 'Color', [colores(3,:), 0.2], 'HandleVisibility', 'off');
end

h_p2 = plot([eq_v(1), eq_v(3)], [eq_w(1), eq_w(3)], 'ko', 'MarkerFaceColor', 'c', 'MarkerSize', 7);
h_p3 = plot(vs, ws, 'ks', 'MarkerFaceColor', colores(2,:), 'MarkerSize', 9);


xlabel('$v$', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('$w$', 'Interpreter', 'latex', 'FontSize', 13);
title('Plano de Fases: 3 equilibrios', 'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, 'LineWidth', 0.8, 'GridAlpha', 0.3);
axis([-0.5 1.5 -0.10 0.30]);

lgd2 = legend([h_n1, h_n2, h_estable, h_inestable, h_p2, h_p3], ...
    {'Nulclina $\dot{v}=0$', 'Nulclina $\dot{w}=0$', 'Var. Estable', 'Var. Inestable', ...
     'Nodos Estables', 'Silla $P_2$'}, ...
    'Interpreter', 'latex', 'Location', 'northwest');
legend boxoff;



%% APARTADO C: 

a_vec = linspace(0, 0.9, 500);
g_bif = 4 ./ (1 - a_vec).^2;
epsilon = 0.01;

gamma_critico = 1/sqrt(epsilon);
a_critico = 1 - sqrt(4/gamma_critico); 
idx_split = find(a_vec >= a_critico, 1);

figure('Color', 'w');
hold on; grid on;

% Rama inestable
plot(a_vec(1:idx_split), g_bif(1:idx_split), 'Color', colores(2,:), ...
    'LineWidth', 2.5, 'DisplayName', 'Silla-Nodo Inestable');

% Rama estable
plot(a_vec(idx_split:end), g_bif(idx_split:end), 'Color', colores(3,:), ...
    'LineWidth', 2.5, 'DisplayName', 'Silla-Nodo Estable');

% Punto critico
plot(a_critico, gamma_critico, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8, 'HandleVisibility', 'off');


text(0.1, 12, '$\lambda_2 > 0$', 'Color', colores(2,:), 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');
text(0.7, 45, '$\lambda_2 < 0$', 'Color', colores(3,:), 'Interpreter', 'latex', 'FontSize', 12, 'FontWeight', 'bold');
text(a_critico + 0.02, gamma_critico - 2, ['$\gamma_{crit} = ', num2str(gamma_critico), '$'], ...
    'Interpreter', 'latex', 'FontSize', 11, 'FontName', 'Times');

text(0.15, 30, '\textbf{3 puntos de equilibrio}', 'Interpreter', 'latex', 'FontSize', 11, 'FontName', 'Times');
text(0.65, 15, '\textbf{1 punto de equilibrio}', 'Interpreter', 'latex', 'FontSize', 11, 'FontName', 'Times');


text(0.15, 45, {'\textbf{Bifurcaci\''on}', '\textbf{Silla-Nodo}', '($\lambda_1 = 0$)'}, ...
    'Interpreter', 'latex', 'Color', [0.6 0.4 0], 'FontSize', 12, 'HorizontalAlignment', 'center');

xlabel('$a$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$\gamma$', 'Interpreter', 'latex', 'FontSize', 14);
title('Diagrama de Bifurcación', 'Interpreter', 'latex', 'FontSize', 16, 'FontName', 'Times');


set(gca, 'Box', 'on', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11, ...
    'LineWidth', 1, 'GridAlpha', 0.2);

axis([0 1.5 0 55]);
legend('Location', 'southeast', 'Interpreter', 'latex');
legend boxoff;


