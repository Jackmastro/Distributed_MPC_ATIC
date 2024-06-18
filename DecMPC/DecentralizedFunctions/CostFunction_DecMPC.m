function cost = CostFunction_DecMPC(x, ~, ~, ~, params) 
    
    Q = params(29);
    T_set = params(25); 
    
    % States
    T_b  = x(:,4);

    cost = params(29) .* norm(T_b - T_set).^2;
   
end
