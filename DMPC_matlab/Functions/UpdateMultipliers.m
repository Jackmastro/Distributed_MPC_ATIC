function [lambda_AB, lambda_BC, difference_m, difference_T, is_converged] = UpdateMultipliers(X_A_shifted, MV_A, X_B_shifted, MV_B, X_C_shifted, MV_C, md_A, md_C)
    
    difference_m = 0;

    mass_tolerance = 0.11;
    alpha_m = 0.01;

    difference_T = 0;
    temperature_tolerance = 0.61;
    alpha_T = 0.005;

    %% Cut last row of all inputs
    X_A_shifted_cut = removeLastRow(X_A_shifted);
    X_B_shifted_cut = removeLastRow(X_B_shifted);
    X_C_shifted_cut = removeLastRow(X_C_shifted);

    MV_A_cut = removeLastRow(MV_A);
    MV_B_cut = removeLastRow(MV_B);
    MV_C_cut = removeLastRow(MV_C);

    md_A_cut = removeLastRow(md_A);
    md_C_cut = removeLastRow(md_C);

    %% A-B 

    lambda_AB_m_O_cut = md_A_cut(:, 5);
    lambda_AB_m_R_cut = md_A_cut(:, 6);
    lambda_AB_T_F_cut = md_A_cut(:, 7);
    lambda_AB_T_R_cut = md_A_cut(:, 8);

    % lambda_AB_m_O
    lambda_AB_m_O_cut = lambda_AB_m_O_cut + alpha_m * (MV_A_cut(:,5) - MV_B_cut(:,3));
    difference_m = difference_m + norm((MV_A_cut(:,5) - MV_B_cut(:,3)));

    % lambda_AB_m_R
    lambda_AB_m_R_cut = lambda_AB_m_R_cut + alpha_m * (MV_A_cut(:,6) - MV_B_cut(:,7));
    difference_m = difference_m + norm(MV_A_cut(:,6) - MV_B_cut(:,7));

    % lambda_AB_T_F
    lambda_AB_T_F_cut = lambda_AB_T_F_cut + alpha_T * (X_A_shifted_cut(:,1) - MV_B_cut(:,1));
    difference_T  = difference_T + norm((X_A_shifted_cut(:,1) - MV_B_cut(:,1)));

    % lambda_AB_T_R
    lambda_AB_T_R_cut = lambda_AB_T_R_cut + alpha_T * (MV_A_cut(:,2) - X_B_shifted_cut(:,6));
    difference_T  = difference_T + norm((MV_A_cut(:,2) - X_B_shifted_cut(:,6)));

    % Recombine lambdas and copy last row
    lambda_AB = copyLastRow([lambda_AB_m_O_cut, lambda_AB_m_R_cut, lambda_AB_T_F_cut, lambda_AB_T_R_cut]);

    %% B-C 
    
    lambda_BC_m_O_cut = md_C_cut(:, 5);
    lambda_BC_m_R_cut = md_C_cut(:, 6);
    lambda_BC_T_F_cut = md_C_cut(:, 7);
    lambda_BC_T_R_cut = md_C_cut(:, 8);

    % lambda_BC_m_O
    lambda_BC_m_O_cut = lambda_BC_m_O_cut + alpha_m * (MV_B_cut(:,5) - MV_C_cut(:,3));
    difference_m = difference_m + norm(MV_B_cut(:,5) - MV_C_cut(:,3));

    % lambda_BC_m_R
    lambda_BC_m_R_cut = lambda_BC_m_R_cut + alpha_m * (MV_B_cut(:,6) - MV_C_cut(:,7));
    difference_m = difference_m + norm(MV_B_cut(:,6) - MV_C_cut(:,7));

    % lambda_BC_T_F
    lambda_BC_T_F_cut = lambda_BC_T_F_cut + alpha_T * (X_B_shifted_cut(:,1) - MV_C_cut(:,1));
    difference_T = difference_T + norm((X_B_shifted_cut(:,1) - MV_C_cut(:,1)));

    % lambda_BC_T_R
    lambda_BC_T_R_cut = lambda_BC_T_R_cut + alpha_T * (MV_B_cut(:,2) - X_C_shifted_cut(:,6));
    difference_T = difference_T + norm((MV_B_cut(:,2) - X_C_shifted_cut(:,6)));

    % Recombine lambdas and copy last row
    lambda_BC = copyLastRow([lambda_BC_m_O_cut, lambda_BC_m_R_cut, lambda_BC_T_F_cut, lambda_BC_T_R_cut]);

    %% Tolerance check
    
    if difference_m <= mass_tolerance && difference_T <= temperature_tolerance
        is_converged = true;
    else 
        is_converged = false;
    end

    %% Helper functions

    function X_A_extended = copyLastRow(X_A)
        % This function returns a new matrix with the last row of the input matrix X
        % copied to a new row at the end of the matrix.
    
        % Get the size of the input matrix
        [rows, cols] = size(X_A);
        
        % Initialize the new matrix with an extra row
        X_A_extended = zeros(rows + 1, cols);
        
        % Copy the original matrix to the new matrix
        X_A_extended(1:rows, :) = X_A;
        
        % Copy the last row of the original matrix to the new last row
        X_A_extended(rows + 1, :) = X_A(end, :);
    end


    function X_trimmed = removeLastRow(X)
        % This function returns a new matrix with the last row of the input matrix X removed.
    
        % Get the size of the input matrix
        [rows, ~] = size(X);
        
        % Check if the matrix has more than one row
        if rows > 1
            % Create the new matrix without the last row
            X_trimmed = X(1:rows-1, :);
        else
            % If the matrix has only one row, return an empty matrix
            X_trimmed = [];
        end
    end

end