function ValidationFunction_DecMPC(household, test)

if test
    % Define a random initial state and input
    x0 = [1; 1; 1; 1];
    u0 = [2,1];
    
    params = {household};
    
    % Validate functions
    validateFcns(household.nlobj, x0, u0(1), u0(2), params);
else 
    disp('No validation test has been run.')

end