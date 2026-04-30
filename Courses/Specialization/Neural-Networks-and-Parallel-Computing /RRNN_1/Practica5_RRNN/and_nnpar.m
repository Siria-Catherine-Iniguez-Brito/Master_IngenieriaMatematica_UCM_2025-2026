X = [ 0 0 1 1; 0 1 0 1]; 
Y = [0 0 0 1];

netp = feedforwardnet(2); 

%parpool
netp = train(netp, X, Y, 'useParallel', 'yes'); 

Ypred = netp(X)