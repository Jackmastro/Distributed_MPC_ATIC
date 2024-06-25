function cost = CostFunction_DecMPC(x, u, ~, ~, params)

    % NMPC Parameters
    Q_disc  = params(29);
    Q_S1    = params(34);
    Q_S3    = params(35);
    R_U     = params(36);

    h_S1    = params(4);
    A_S1    = params(5);
    h_S3    = params(17);
    A_S3    = params(18);

    % Input
    m_U = u(1:end-1, 1);

    % Temperatures
    T_set   = params(25);
    T_amb   = params(26);
    
    % Measured Disturbance
    % T_set = u(1:end-1, 4);

    % States
    T_S1 = x(2:end, 1);
    T_b  = x(2:end, 3);
    T_S3 = x(2:end, 4);

    cost = Q_disc .* norm(T_b - T_set).^2 ...
         + Q_S1 * h_S1 * A_S1 * norm(T_S1 - T_amb).^2 ...
         + Q_S3 * h_S3 * A_S3 * norm(T_S3 - T_amb).^2 ...
         + R_U  * norm(m_U).^2;

end
