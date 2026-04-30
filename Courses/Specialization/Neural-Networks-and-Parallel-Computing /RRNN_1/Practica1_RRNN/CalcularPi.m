%% Ejemplo 2 

%% Forma secuencial
n = 100000000; 

tic 
PI = 4*sum(sqrt(rand(1,n).^2+rand(1,n).^2)<1)/n; 
toc 


%% Forma paralela parfor 
try 
    pjob = parpool
end 

npmax = pjob.NumWorkers; % Numero de nucleos que tenemos 

n = 100000000; 

tic 
nn = round(n/npmax); 
PI = distributed(0); 

parfor i = 1 : npmax 
    PI = PI + 4*sum(sqrt(rand(1,nn).^2+rand(1,nn).^2)<1)/(nn*npmax); 
end 

tiemp(1)=toc; 
tic 


%% Forma paralela smd 

spmd 
    c= 4*sum(sqrt(rand(1,nn).^2+rand(1,nn).^2)<1)/nn; 
end 

Pi = mean([c{1:npmax}]); 
tiemp(2)=toc; 



clear tiemp 
if exist('pjob') == 0
    pjob =parpool
    npmax = pjob.NumWorkers; 
end 

n = 100000000; 
tic 
PI = 4*sum(sqrt(rand(1,n).^2+rand(1,n).^2)<1)/n; 
tiemp(1)=toc; 

for np = 1:npmax
    np 
    tic 
    nn = round(n/np); 
    Pi = 0; 

    parfor i = 1:np 
        Pi = Pi + 4*sum(sqrt(rand(1,nn).^2+rand(1,nn).^2)<1)/(nn*np);
    end 
Pi = mean(Pi)

tiemp(end+1)=toc; 
end 

figure(1)
clf 
plot(tiemp(1)./tiemp(2:end), ':or', 'LineWidth',2)
xlabel('Numero de Workers')
ylabel('Ratio')
title('Speed up')
box on 
grid on 