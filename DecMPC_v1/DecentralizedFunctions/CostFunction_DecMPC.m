function cost = CostFunction_DecMPC(x, ~, ~, ~, params) 

    Q = params(29);
    K = params(27); % prediction horizon
    T_set = params(25); 


    % States
    T_b  = x(2:end, 3);

    cost = Q .* norm(T_b - T_set).^2;

end
