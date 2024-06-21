function [lambda_AB, lambda_BC, difference_m, difference_T, is_converged] = UpdateMultipliers(X_A, MV_A, X_B, MV_B, X_C, MV_C, md_A, md_C)
    
    difference_m = 0;
    mass_tolerance = 1;
    alfa_m = 0.1; 

    difference_T = 0;
    temperature_tolerance = 1;
    alfa_T = 1; 

    %% A-B 

    lambda_AB_m_O = md_A(:,5);
    lambda_AB_m_R = md_A(:,6);
    lambda_AB_T_F = md_A(:,7);
    lambda_AB_T_R = md_A(:,8);

    % lambda_AB_m_O
    lambda_AB_m_O = lambda_AB_m_O + alfa_m * (MV_A(:,5) - MV_B(:,3));
    difference_m = difference_m + norm((MV_A(:,5) - MV_B(:,3)));

    % lambda_AB_m_R
    lambda_AB_m_R = lambda_AB_m_R + alfa_m * (MV_A(:,6) - MV_B(:,7));
    difference_m = difference_m + norm(MV_A(:,6) - MV_B(:,7));

    % lambda_AB_T_F
    lambda_AB_T_F = lambda_AB_T_F + alfa_T * (X_A(:,1) - MV_B(:,1));
    difference_T  = difference_T + norm((X_A(:,1) - MV_B(:,1)));

    % lambda_AB_T_R
    lambda_AB_T_R = lambda_AB_T_R + alfa_T * (MV_A(:,2) - X_B(:,6));
    difference_T  = difference_T + norm((MV_A(:,2) - X_B(:,6)));

    lambda_AB = [lambda_AB_m_O, lambda_AB_m_R, lambda_AB_T_F, lambda_AB_T_R];

    %% B-C 
    
    lambda_BC_m_O = md_C(:,5);
    lambda_BC_m_R = md_C(:,6);
    lambda_BC_T_F = md_C(:,7);
    lambda_BC_T_R = md_C(:,8);

    % lambda_BC_m_O
    lambda_BC_m_O = lambda_BC_m_O + alfa_m * (MV_B(:,5) - MV_C(:,3));
    difference_m = difference_m + norm(MV_B(:,5) - MV_C(:,3));

    % lambda_BC_m_R
    lambda_BC_m_R = lambda_BC_m_R + alfa_m * (MV_B(:,6) - MV_C(:,7));
    difference_m = difference_m + norm(MV_B(:,6) - MV_C(:,7));

    % lambda_BC_T_F
    lambda_BC_T_F = lambda_BC_T_F + alfa_T * (X_B(:,1) - MV_C(:,1));
    difference_T = difference_T + norm((X_B(:,1) - MV_C(:,1)));

    % lambda_BC_T_R
    lambda_BC_T_R = lambda_BC_T_R + alfa_T * (MV_B(:,2) - X_C(:,6));
    difference_T = difference_T + norm((MV_B(:,2) - X_C(:,6)));

    lambda_BC = [lambda_BC_m_O, lambda_BC_m_R, lambda_BC_T_F, lambda_BC_T_R];

    if difference_m <= mass_tolerance && difference_T <= temperature_tolerance
        is_converged = true;
    else 
        is_converged = false;
    end

end