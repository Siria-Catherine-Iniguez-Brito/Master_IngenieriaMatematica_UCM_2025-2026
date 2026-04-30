function f = fun2(x)
f = 0; 
lims = 6000000; 
for ii = 1: lims 
    f = f + exp(x(1)) * (4 * x(3)^2 + 2 * x(4)^2 + 4 * x(1) * x(2) + 2 * x(2)) / exp(ii); 
end 
end 