function [J_eq_x, J_eq_u] = JacobianEqCon_matlab(~, ~, data, params)

    % Constants
    is_bypass_house = params(49);

    K = data.PredictionHorizon;
    nx = data.NumOfStates;
    nu_mv = length(data.MVIndex);

    if is_bypass_house
        nc = 4;
    else
        nc = 2;
    end

    % State Jacobian
    J_eq_x = zeros(K, nx, nc);

    % Input Jacobian
    J_eq_u = zeros(K, nu_mv, nc);

    J_eq_u(:,:,1) = repmat([0, 0, 1, -1, -1, 0, 0], K, 1);
    J_eq_u(:,:,2) = repmat([0, 0, 0, -1, 0, -1, 1], K, 1);

    % Bypass
    if is_bypass_house
        J_eq_x(:,7,4) = -ones(K, 1);

        J_eq_u(:,:,3) = repmat([0, 0, 0, 0, -1, 1, 0], K, 1);
        J_eq_u(:,2,4) = ones(K, 1);
    end

    J_eq_x
    J_eq_u
end
