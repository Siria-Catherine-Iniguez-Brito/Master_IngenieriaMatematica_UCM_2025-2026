clear all; close all; clc;
format long

a = 0.5;
gamma = 0.3535; 
epsilon = 0.001;


L1_inst = (-gamma + sqrt(gamma^2 + 4*(1+a)))/2; 
L2_inst = (gamma + sqrt(gamma^2 + 4*a*(1+a)))/2;


options = odeset('RelTol', 1e-12);

figure('Color', 'w'); hold on; grid on;


% Heteroclina 
[~, yh1] = ode45(@(t,y) RHS_c2(t,y,a,gamma), [0 100], [1-epsilon; -epsilon*L1_inst], options);
[~, yh2] = ode45(@(t,y) RHS_c2_back(t,y,a,gamma), [0 100], [-a+epsilon; -epsilon*L2_inst], options);


plot(yh1(:,1), yh1(:,2), 'b', 'LineWidth', 1);
plot(yh2(:,1), yh2(:,2), 'r--', 'LineWidth', 1);


plot([1, 0, -a], [0, 0, 0], 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 4, 'LineWidth', 1);
text(1.05, 0.05, '(1,0)', 'FontWeight', 'bold');
text(0.05, 0.05, '(0,0)', 'FontWeight', 'bold');
text(-0.6, 0.05, '(-a,0)', 'FontWeight', 'bold');

xlabel('x'); ylabel('dy/dt');
title(sprintf('Plano de Fases: \\gamma = %.4f', gamma));
axis([-0.8 1.2 -0.8 0.8]);


function dy = RHS_c2(t,y,a,gamma)
    dy = [y(2); -gamma*y(2) - (a*y(1) + (1-a)*y(1)^2 - y(1)^3)];
end 
function dy_back = RHS_c2_back(t,y,a,gamma)
    dy_back = [-y(2); gamma*y(2) + (a*y(1) + (1-a)*y(1)^2 - y(1)^3)];
end 
