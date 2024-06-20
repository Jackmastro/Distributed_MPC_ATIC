function [J_y_x, J_y_u] = JacobianOutput_matlab(~, ~, params)
    
    nx     = params(45);
    ny     = params(46);
    nu     = params(47) + params(48);

    % State Jacobian
    J_y_x = zeros(ny, nx);
    J_y_x(1,4) = 1;

    % Input Jacobian
    J_y_u = zeros(ny, nu);

end