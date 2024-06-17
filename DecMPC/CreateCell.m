mc = metaclass(A);

% Initialize an array to hold the values of the constant properties
params = [];

% Loop through each property and check if it is constant
for i = 1:length(mc.Properties)
    prop = mc.Properties{i};
    disp(prop)
    if strcmp(prop.GetAccess, 'public') && prop.Constant
        % Access the constant property value using the class name
        value = Household_DecMPC.(prop.Name);
        % Append the value to the params array
        params = [params, value];
    end
end
params = {params(1:length(params))}