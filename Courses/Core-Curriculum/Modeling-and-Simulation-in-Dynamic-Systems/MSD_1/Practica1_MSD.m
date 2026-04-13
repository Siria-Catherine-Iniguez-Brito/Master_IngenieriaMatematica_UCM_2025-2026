% CLASE 1: El amortiguadoe 

L = 0.2; % El valor del parametro lambda
a = 1; % Longitud del bache 

mu1 = -L + sqrt(L^2-1); % Los autovalores de A 
mu2 = -L - sqrt(L^2-1); 

% Solucion para t in [0,a]
C1 = -mu2/(mu2 - mu1);
C2= mu1/(mu2 - mu1);
t1 = linspace(0, a, 100); 
y1 = C1 * exp(mu1 * t1) + C2 * exp(mu2 * t1) + 1; 

% Solucion para t > a 
y0 = C1 * exp(mu1 * a) + C2 * exp(mu2 * a) + 1; % Condiciones iniciales
u0 = mu1 * C1 * exp(mu1 * a) + mu2 * C2 * exp(mu2 * a); 
D = [1 1; mu1 mu2] \ [y0; u0]; % Las constantes

t2 = linspace(a, 10, 100);
y2 = D(1) * exp(mu1 * (t2 - a)) + D(2) * exp(mu2 * (t2 - a));

%% COMENTARIO: 
% Dado que el parámetro de amortiguamiento es L = 0.2 < 1, 
% el sistema es subamortiguado, lo que genera autovalores complejos. 
% Aunque la solución analítica resultante es puramente real 
% (ya que representa un desplazamiento físico), 
% el cálculo numérico genera componentes imaginarias infinitesimales debido
% a la precisión de redondeo. Por ello, se toma la parte real de la solución 
% para la representación gráfica. 

% Grafica 
plot(t1, real(y1), 'b', 'LineWidth', 2)
hold on
plot(t2, real(y2), 'r', 'LineWidth', 2)
grid on 
legend('Fase de Bache (t <= a)', 'Fase de Recuperación (t > a)')
xlabel('Tiempo (t)')
ylabel('Desplazamiento (y)')
title(['Amortiguador (\lambda = ', num2str(L), ')'])