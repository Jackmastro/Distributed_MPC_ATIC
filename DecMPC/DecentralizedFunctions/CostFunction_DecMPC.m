function cost = CostFunction_DecMPC(x, ~, ~, ~, household) 
    
    % States
    T_b  = x(:,4);

    cost = household.Q .* norm(T_b - household.T_set).^2;
   
end
