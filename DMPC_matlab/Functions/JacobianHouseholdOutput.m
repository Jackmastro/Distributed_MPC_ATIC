function [J_y_x, J_y_u] = JacobianHouseholdOutput(~, ~, household)
    
    nx      = household.nx;
    nu      = household.nu;
    ny      = household.ny;

    % State Jacobian
    J_x_x = zeros(ny, nx);
    J_x_x(1,4) = 1;

    % Input Jacobian
    J_x_u = zeros(ny, nu);

end