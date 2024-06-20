function cost = CostFunction_DecMPC(x, ~, ~, ~, params) 
    persistent k; %number of iterations
    global T_amb_signal;
    if isempty(k)
        k = 0;
    end
    k = k + 1;

    Q = params(29);
    p = params(27); % prediction horizon
    

    %T_set = params(25); 
    T_set = T_amb_signal(k:k+p)';
    

    % States
    T_b  = x(2:p+1,3);

    cost = Q .* norm(T_b - T_set).^2;



end
