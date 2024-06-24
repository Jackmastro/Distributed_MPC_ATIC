function cost = CostFunction_matlab(x, u, ~, ~, params) 

    % NMPC Parameters
    Q_disc  = params(44);
    Q_F     = params(59);
    Q_S1    = params(60);
    Q_S3    = params(61);
    Q_R     = params(62);
    R_BYP   = params(63);
    R_U     = params(64);

    h_F     = params(4);
    A_F     = params(5); 
    h_S1    = params(9);
    A_S1    = params(10); 
    % h_b     = params(18);
    % A_b     = params(19); 
    h_S3    = params(22);
    A_S3    = params(23); 
    h_R     = params(27);
    A_R     = params(28); 
    % h_BYP   = params(32);
    % A_BYP   = params(33); 

    % T_set = params(40);

    is_bypass_house = params(49);
    is_first_house  = params(50);

    delta_m_O_pred  = params(51);
    delta_m_O_succ  = params(52);
    delta_m_R_pred  = params(53);
    delta_m_R_succ  = params(54);
    delta_T_F_pred  = params(55);
    delta_T_F_succ  = params(56);
    delta_T_R_pred  = params(57);
    delta_T_R_succ  = params(58);

    % States
    T_F     = x(2:end, 1); % shared
    T_S1    = x(2:end, 2);
    % T_S2   = x(2:end, 3);
    T_b     = x(2:end, 4); % private
    T_S3    = x(2:end, 5);
    T_R     = x(2:end, 6); % shared
    
    % Inputs
    %  Manipulated Variables 
    T_F_pred_I  = u(1:end-1, 1);
    T_R_succ_I  = u(1:end-1, 2);
    m_F         = u(1:end-1, 3);
    m_U       = u(1:end-1, 4);
    m_O         = u(1:end-1, 5);
    m_R_succ_I  = u(1:end-1, 6);
    m_R         = u(1:end-1, 7);
    
    if is_first_house

        % Measured Disturbances
        m_O_I_succ      = u(1:end-1, 8);
        m_R_succ_succ   = u(1:end-1, 9);
        T_F_I_succ      = u(1:end-1, 10);
        T_R_succ_succ   = u(1:end-1, 11);

        lambda_m_O_succ = u(1:end-1, 12);
        lambda_m_R_succ = u(1:end-1, 13);
        lambda_T_F_succ = u(1:end-1, 14);
        lambda_T_R_succ = u(1:end-1, 15);

        T_amb     = u(1:end-1, 16);
        T_set     = u(1:end-1, 17);

        % m_F_past = u(1:end-1, 18);

        cost =     Q_disc .* norm(T_b - T_set).^2 ...
             + Q_F  * h_F  * A_F  * norm(T_F  - T_amb).^2 ...
             + Q_S1 * h_S1 * A_S1 * norm(T_S1 - T_amb).^2 ...
             + Q_S3 * h_S3 * A_S3 * norm(T_S3 - T_amb).^2 ...
             + Q_R  * h_R  * A_R  * norm(T_R  - T_amb).^2 ...
             + R_U  * norm(m_U).^2 ...
             + lambda_m_O_succ' * (m_O - m_O_I_succ)...
             + 0.5 * delta_m_O_succ * (norm(m_O - m_O_I_succ)).^2 ...
             + lambda_m_R_succ' * (m_R_succ_I - m_R_succ_succ)...
             + 0.5 * delta_m_R_succ * (norm(m_R_succ_I - m_R_succ_succ)).^2 ...
             + lambda_T_F_succ' * (T_F - T_F_I_succ)...
             + 0.5 * delta_T_F_succ * (norm(T_F - T_F_I_succ)).^2 ...
             + lambda_T_R_succ' * (T_R_succ_I - T_R_succ_succ)...
             + 0.5 * delta_T_R_succ *  (norm(T_R_succ_I - T_R_succ_succ)).^2;  
        
    elseif is_bypass_house

        % Measured Disturbances
        m_U       = u(1:end-1, 4);

        m_O_pred_pred   = u(1:end-1, 8);
        m_R_I_pred      = u(1:end-1, 9);
        T_F_pred_pred   = u(1:end-1, 10);
        T_R_I_pred      = u(1:end-1, 11);

        lambda_m_O_pred = u(1:end-1, 12);
        lambda_m_R_pred = u(1:end-1, 13);
        lambda_T_F_pred = u(1:end-1, 14);
        lambda_T_R_pred = u(1:end-1, 15);

        T_amb           = u(1:end-1, 16);
        T_set           = u(1:end-1, 17);

        cost =     Q_disc .* norm(T_b - T_set).^2 ...
             + Q_F  * h_F  * A_F  * norm(T_F  - T_amb).^2 ...
             + Q_S1 * h_S1 * A_S1 * norm(T_S1 - T_amb).^2 ...
             + Q_S3 * h_S3 * A_S3 * norm(T_S3 - T_amb).^2 ...
             + Q_R  * h_R  * A_R  * norm(T_R  - T_amb).^2 ...
             + R_BYP * norm(m_R_succ_I).^2 ... 
             + R_U  * norm(m_U).^2 ...
             + lambda_m_O_pred' * (m_F - m_O_pred_pred)...
             + 0.5 * delta_m_O_pred * (norm(m_F - m_O_pred_pred)).^2 ...
             + lambda_m_R_pred' * (m_R - m_R_I_pred)...
             + 0.5 * delta_m_R_pred * (norm(m_R - m_R_I_pred)).^2 ...
             + lambda_T_F_pred' * (T_F_pred_I - T_F_pred_pred)...
             + 0.5 * delta_T_F_pred * (norm(T_F_pred_I - T_F_pred_pred)).^2 ...
             + lambda_T_R_pred' * (T_R - T_R_I_pred)...
             + 0.5 * delta_T_R_pred * (norm(T_R - T_R_I_pred)).^2;  
    
    else
        % Middle House
        % Measured Disturbances
        m_O_pred_pred   = u(1:end-1, 8);
        m_R_I_pred      = u(1:end-1, 9);
        T_F_pred_pred   = u(1:end-1, 10);
        T_R_I_pred      = u(1:end-1, 11);
        m_O_I_succ      = u(1:end-1, 12);
        m_R_succ_succ   = u(1:end-1, 13);
        T_F_I_succ      = u(1:end-1, 14);
        T_R_succ_succ   = u(1:end-1, 15);

        lambda_m_O_pred = u(1:end-1, 16);
        lambda_m_R_pred = u(1:end-1, 17);
        lambda_T_F_pred = u(1:end-1, 18);
        lambda_T_R_pred = u(1:end-1, 19);
        lambda_m_O_succ = u(1:end-1, 20);
        lambda_m_R_succ = u(1:end-1, 21);
        lambda_T_F_succ = u(1:end-1, 22);
        lambda_T_R_succ = u(1:end-1, 23);

        T_amb           = u(1:end-1, 24);
        T_set           = u(1:end-1, 25);

        cost =     Q_disc .* norm(T_b - T_set).^2 ...
             + Q_F  * h_F  * A_F  * norm(T_F  - T_amb).^2 ...
             + Q_S1 * h_S1 * A_S1 * norm(T_S1 - T_amb).^2 ...
             + Q_S3 * h_S3 * A_S3 * norm(T_S3 - T_amb).^2 ...
             + Q_R  * h_R  * A_R  * norm(T_R  - T_amb).^2 ...
             + R_U  * norm(m_U).^2 ...
             + lambda_m_O_pred' * (m_F - m_O_pred_pred)...
             + 0.5 * delta_m_O_pred * (norm(m_F - m_O_pred_pred)).^2 ...
             + lambda_m_O_succ' * (m_O - m_O_I_succ)...
             + 0.5 * delta_m_O_succ * (norm(m_O - m_O_I_succ)).^2 ...
             + lambda_m_R_pred' * (m_R - m_R_I_pred)...
             + 0.5 * delta_m_R_pred * (norm(m_R - m_R_I_pred)).^2 ...
             + lambda_m_R_succ' * (m_R_succ_I - m_R_succ_succ)...
             + 0.5 * delta_m_R_succ * (norm(m_R_succ_I - m_R_succ_succ)).^2 ...
             + lambda_T_F_pred' * (T_F_pred_I - T_F_pred_pred)...
             + 0.5 * delta_T_F_pred * (norm(T_F_pred_I - T_F_pred_pred)).^2 ...
             + lambda_T_F_succ' * (T_F - T_F_I_succ)...
             + 0.5 * delta_T_F_succ * (norm(T_F - T_F_I_succ)).^2 ...
             + lambda_T_R_pred' * (T_R - T_R_I_pred)...
             + 0.5 * delta_T_R_pred * (norm(T_R - T_R_I_pred)).^2 ...
             + lambda_T_R_succ' * (T_R_succ_I - T_R_succ_succ)...
             + 0.5 * delta_T_R_succ *  (norm(T_R_succ_I - T_R_succ_succ)).^2;  
    end

end
