function xk1 = DiscrHouseholdTemperatureDynamic(xk, uk, params)
    
    % Constants
    Ts = params(33);
    
    % Zero Hold
    xk1 = xk + Ts * ContHouseholdTemperatureDynamic(xk, uk, params);

end
