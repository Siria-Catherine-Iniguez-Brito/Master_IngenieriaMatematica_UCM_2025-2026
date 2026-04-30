function [c,ceq] = cons2(x)
c = [1.5 + x(1) * x(2) * x(3) - x(1) - x(2) - x(4); 
    - x(1) * x(2) + x(4) - 10]; 
ceq = [];
end 