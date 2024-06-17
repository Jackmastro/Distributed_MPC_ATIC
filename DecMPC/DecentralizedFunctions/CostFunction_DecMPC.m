function cost = CostFunction_DecMPC(x, ~, ~, ~, params) 
    
    % States
    T_b  = x(:,4);

    cost = params(29) .* norm(T_b - params(25)).^2;
   
end
