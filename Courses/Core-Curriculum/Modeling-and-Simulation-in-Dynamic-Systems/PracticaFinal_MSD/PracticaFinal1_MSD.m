%% PRACTICA 1: 

%% APARTADO B

clear; close all; clc;

% Sistema
f = @(t, y) [y(2); (log(abs(y(1))) - 1) ./ (y(1).^2 .* sign(y(1)))];

Tmax = 20;

% Figura 
figure('Color','w','Position',[50 50 400 400]);
hold on; grid on; axis equal;

% Trayectorias
x_vals = [-4 -3.5 -3 -2.5 -2 -0.5 0.5 2 2.5 3 3.5 4];
u_vals = [-1.2 -0.6 0.6 1.2];

for i = 1:length(x_vals)
    for j = 1:length(u_vals)
        
        y0 = [x_vals(i), u_vals(j)];
        
        [~, y_fwd] = ode45(f, [0 Tmax], y0);
        [~, y_bwd] = ode45(f, [0 -Tmax], y0);
        
        plot(y_fwd(:,1), y_fwd(:,2), 'Color',[0.82 0.82 0.82], 'LineWidth',0.5);
        plot(y_bwd(:,1), y_bwd(:,2), 'Color',[0.82 0.82 0.82], 'LineWidth',0.5);
    end
end

% Separatrizas
e_val = exp(1);
lambda = sqrt(1/e_val^3);
epsilon = 0.05;

azul = [0 0.35 0.7];

% Puntos de equilibrio
puntos = [-e_val, 0; e_val, 0];

for p = 1:size(puntos,1)
    
    x_eq = puntos(p,1);
    u_eq = puntos(p,2);
    
    % Autovectores
    v1 = [1; lambda];
    v2 = [1; -lambda];
    
    direcciones = [v1, v2];
    
    for k = 1:2
        
        v = direcciones(:,k);
        
        for s = [-1, 1]
            
            y0 = [x_eq; u_eq] + s * epsilon * v;
            y0 = y0';
            
            % Integración (adelante y atrás)
            [~, y_fwd] = ode45(f, [0 Tmax], y0);
            [~, y_bwd] = ode45(f, [0 -Tmax], y0);
            
            plot(y_fwd(:,1), y_fwd(:,2), 'Color', azul, 'LineWidth', 1.4);
            plot(y_bwd(:,1), y_bwd(:,2), 'Color', azul, 'LineWidth', 1.4);
        end
    end
end

% Equilibrios
plot(e_val, 0, 'ko', 'MarkerFaceColor','k', 'MarkerSize', 5);
plot(-e_val, 0, 'ko', 'MarkerFaceColor','k', 'MarkerSize', 5);


xline(0,'--','Color',[0.6 0.6 0.6],'LineWidth',0.8);
xlabel('$x$', 'Interpreter', 'latex','FontSize', 12);
ylabel('$u$', 'Interpreter', 'latex','FontSize', 12);
title('Diagrama de fases con separatrices', 'FontSize', 17, 'FontWeight', 'normal', 'FontName', 'Times');
set(gca,'Box', 'off', 'TickDir', 'out', 'FontName', 'Times', 'FontSize', 11);
xlim([-5 5]);
ylim([-5 5]);


