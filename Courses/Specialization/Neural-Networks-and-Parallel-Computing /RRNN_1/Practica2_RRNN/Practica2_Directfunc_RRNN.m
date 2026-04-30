clear all 
close all 
clc 

 x= rand(6*12000000,1); 
 tic 
 y3 = log(abs(cos(x.^2).*sqrt(x)./ exp(x))+1); 
 timec(3) = toc; 
 disp(['Tiempo con funcion directa en secuencial: ' num2str(toc)])

 gcp;
 pjob = gcp; 
 npmax = pjob.NumWorkers; 
 nn = ceil(length(x)/npmax); 

 yp3 = zeros(npmax, nn); 
 tic 
parfor i = 1: npmax 
    xx = x(1+((i-1)*nn): nn + ((i-1)*nn)); 
    yp3(i,:)=  log(abs(cos(xx.^2).*sqrt(xx)./exp(xx))+1)
end 
ypf3 = [yp3(1,:), yp3(2,:), yp3(3,:), yp3(4,:)]; 
timec(5) = toc; 
disp(['Tiempo con funcion directa en  paralelo ' num2str(toc) ' con ' num2str(npmax) ' workers '])
disp(['Speedup: ' num2str(timec(3)/ timec(5) )])






