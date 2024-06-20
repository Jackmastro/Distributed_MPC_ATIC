function cost = CostFunction_DecMPC(x, ~, ~, ~, params) 
    global k; %number of iterations
    global T_ref_signal;

    Q = params(29);
    p = params(27); % prediction horizon
    index = params(34);
    %T_set = params(25); 
    
      
    T_set = T_ref_signal(index+1:index+p)';


    % States
    T_b  = x(2:p+1,3);

    cost = Q .* norm(T_b - T_set).^2;

end
