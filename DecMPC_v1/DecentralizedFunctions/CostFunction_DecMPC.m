function cost = CostFunction_DecMPC(x, ~, ~, ~, params) 
    T_set = params(25); 
    
    Q = params(29);
    
    % States
    T_b  = x(:,3);

    cost = Q .* norm(T_b - T_set).^2;
   
end
