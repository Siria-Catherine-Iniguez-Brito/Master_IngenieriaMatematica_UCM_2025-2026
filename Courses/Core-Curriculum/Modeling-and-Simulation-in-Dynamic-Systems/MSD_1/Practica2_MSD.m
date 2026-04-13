function dy = RHS_c2(t, y, a)
dy = zeros(2,1);
dy(1) = y(2) ;
dy(2) = -2*a*y(2) + 1 - y(1)^2;
end 

Tmax = 100; 
lambda = [0.5, 2]; 
[Y1_start, Y2_start] = meshgrid(linspace(-2.5, 2.5, 8), linspace(-1.5, 1.5, 8));
y0 = [Y1_start(:), Y2_start(:)];

figure ('color','w', 'Position',[100 100 400 600])
for i = 1:2
    subplot(2,2,i)
    for k = 1: size(y0,1)
        [t,y] = ode15s(@(t,y) RHS_c2(t,y,lambda(i)), [0 Tmax], y0(k,:)); 
        plot(y(:,1), y(:,2))
        hold on 
    end 
    [t,y]= ode15s(@(t,y) RHS_c2(t,y,lambda(i)), [0 Tmax], [1.001, 1]);
    plot(y(:,1), y(:,2), 'r', 'LineWidth',2)
    axis([-3 3, -2 2])
    title(['El plano de fases (lambda = ' num2str(lambda(i)) ')'], 'FontSize', 14)
    subplot(2,2,i+2)
    plot(t,y(:,1),'r', 'LineWidth', 2)
    ylim([-1 10])
    xlabel('tiempo','FontSize',14);
    ylabel('x(t)', 'FontSize',14)
    hold on
end 

