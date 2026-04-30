function J = func3(x, compl)
J = 0; 
for i = 1:length(x) 
    for j = 1: compl 
        J = J + abs(x(i)-j*i); 
    end 
end 