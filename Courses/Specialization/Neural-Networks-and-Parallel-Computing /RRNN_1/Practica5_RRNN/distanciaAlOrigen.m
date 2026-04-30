X = rand(2,30000)*1000; 
Y = sqrt(X(1,:).^2 + X(2,:).^2); 


% Secuencial
tic;
net = feedforwardnet(10); 

 
net = train(net, X, Y); 
t1 = toc
Ypred1 = net(X);
Ypred1(1:10);
error1 = max((Y - Ypred1)./Y) 


% Paralelo
tic; 
netp = feedforwardnet(10); 
netp = train(netp, X, Y, 'useParallel', 'yes'); 
t2 = toc 
Ypred2 = netp(X);
Ypred2(1:10);


speedup = t1/t2
error2 = max(abs(Y - Ypred2)./Y)  

% Pruebaa
X3 = rand(2,1000)*1000; 
Y3 = sqrt(X3(1,:).^2 + X3(2,:).^2); 
Ypred3 = netp(X3); 
error3 = max(abs(Y3 - Ypred3)./Y3)