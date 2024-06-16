function cost = CostFunction(x, u, ~, ~, household) 
    
    % States
    T_F  = x(:,1);
    % T_S1 = x(:,2);
    % T_S2 = x(:,3);
    T_b  = x(:,4);
    % T_S3 = x(:,5);
    T_R  = x(:,6);
    
    % Inputs
    %  Manipulated Variables 
    T_F_pred_I = u(:,1);
    T_R_succ_I = u(:,2);
    m_F  = u(:,3);
    % m_U  = u(:,4);
    m_O  = u(:,5);
    m_R_succ_I = u(:,6);
    m_R  = u(:,7);

    if household.is_bypass_house

        % Measured Disturbances
        m_O_pred_pred   = u(:,8);
        m_R_I_pred      = u(:,9);
        T_F_pred_pred   = u(:,10);
        T_R_I_pred      = u(:,11);

        lambda_m_O_pred = u(:,12);
        lambda_m_R_pred = u(:,13);
        lambda_T_F_pred = u(:,14);
        lambda_T_R_pred = u(:,15);
        
        delta_m_O_pred  = u(:,16);
        delta_m_R_pred  = u(:,17);
        delta_T_F_pred  = u(:,18);
        delta_T_R_pred  = u(:,19);

        cost =     household.Q .* norm(T_b - household.T_set).^2 ...
             + lambda_m_O_pred' * (m_F - m_O_pred_pred)...
             + 0.5 * delta_m_O_pred * (norm(m_F - m_O_pred_pred)).^2 ...
             + lambda_m_R_pred' * (m_R - m_R_I_pred)...
             + 0.5 * delta_m_R_pred * (norm(m_R - m_R_I_pred)).^2 ...
             + lambda_T_F_pred' * (T_F_pred_I - T_F_pred_pred)...
             + 0.5 * delta_T_F_pred * (norm(T_F_pred_I - T_F_pred_pred)).^2 ...
             + lambda_T_R_pred' * (T_R - T_R_I_pred)...
             + 0.5 * delta_T_R_pred * (norm(T_R - T_R_I_pred)).^2;  
    
    elseif household.is_first_house

        % Measured Disturbances
        m_O_I_succ      = u(:,8);
        m_R_succ_succ   = u(:,9);
        T_F_I_succ      = u(:,10);
        T_R_succ_succ   = u(:,11);

        lambda_m_O_succ = u(:,12);
        lambda_m_R_succ = u(:,13);
        lambda_T_F_succ = u(:,14);
        lambda_T_R_succ = u(:,15);
        
        delta_m_O_succ  = u(:,16);
        delta_m_R_succ  = u(:,17);
        delta_T_F_succ  = u(:,18);
        delta_T_R_succ  = u(:,19);

        cost =     household.Q .* norm(T_b - household.T_set).^2 ...
             + lambda_m_O_succ' * (m_O - m_O_I_succ)...
             + 0.5 * delta_m_O_succ * (norm(m_O - m_O_I_succ)).^2 ...
             + lambda_m_R_succ' * (m_R_succ_I - m_R_succ_succ)...
             + 0.5 * delta_m_R_succ * (norm(m_R_succ_I - m_R_succ_succ)).^2 ...
             + lambda_T_F_succ' * (T_F - T_F_I_succ)...
             + 0.5 * delta_T_F_succ * (norm(T_F - T_F_I_succ)).^2 ....
             + lambda_T_R_succ' * (T_R_succ_I - T_R_succ_succ)...
             + 0.5 * delta_T_R_succ *  (norm(T_R_succ_I - T_R_succ_succ)).^2;   
    
    else
        
        % Measured Disturbances
        m_O_pred_pred   = u(:,8);
        m_O_I_succ      = u(:,9);
        m_R_succ_succ   = u(:,10);
        m_R_I_pred      = u(:,11);
        T_F_pred_pred   = u(:,12);
        T_F_I_succ      = u(:,13);
        T_R_succ_succ   = u(:,14);
        T_R_I_pred      = u(:,15);
        
        lambda_m_O_pred = u(:,16);
        lambda_m_O_succ = u(:,17);
        lambda_m_R_pred = u(:,18);
        lambda_m_R_succ = u(:,19);
        lambda_T_F_pred = u(:,20);
        lambda_T_F_succ = u(:,21);
        lambda_T_R_pred = u(:,22);
        lambda_T_R_succ = u(:,23);
        
        delta_m_O_pred  = u(:,24);
        delta_m_O_succ  = u(:,25);
        delta_m_R_pred  = u(:,26);
        delta_m_R_succ  = u(:,27);
        delta_T_F_pred  = u(:,28);
        delta_T_F_succ  = u(:,29);
        delta_T_R_pred  = u(:,30);
        delta_T_R_succ  = u(:,31);

        cost =     household.Q .* norm(T_b - household.T_set).^2 ...
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
