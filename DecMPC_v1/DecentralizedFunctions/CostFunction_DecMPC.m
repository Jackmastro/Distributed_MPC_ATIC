function cost = CostFunction_DecMPC(x, u, ~, ~, params) 

    Q = params(29);
    
    % Measured Disturbance
    T_set = u(4);

    % States
    T_b  = x(2:end, 3);

    cost = Q .* norm(T_b - T_set).^2;

end
