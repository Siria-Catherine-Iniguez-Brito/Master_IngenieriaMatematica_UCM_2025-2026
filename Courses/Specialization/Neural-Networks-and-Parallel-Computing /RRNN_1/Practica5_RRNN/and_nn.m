X = [ 0 0 1 1; 0 1 0 1]; 
Y = [0 0 0 1];

net = feedforwardnet(2); 

net = train(net, X, Y); 

Ypred = net(X)