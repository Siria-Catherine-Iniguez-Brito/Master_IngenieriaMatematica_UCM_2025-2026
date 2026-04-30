ub = [10,  90]; 
lb =[1, -90];

% Optimizacin por Monte-Carlo
SM = 10; 
for i = 1:SM
    x = [randi([lb(1) ub(1)]), randi([lb(2) ub(2)])]; 
    param(i,1:2) = x;
    J(i) = wing(x,0); 
end 

[a,b] = min(J); 
disp(['El diseño optimo es: ' num2str(param(b,:))])
disp(['La portanza es: ' num2str(J(b))])
wing(param(b,:),1)
saveas(gcf,'Disenooptim-MC','jpg')