% Get the meta-class for Household_DecMPC
mc = metaclass(Household_DecMPC);

% Initialize arrays to hold the names and values of the properties
constantProps = [];
constantValues = [];
publicProps = [];
publicValues = [];

% Loop through each property and check its attributes
for i = 1:length(mc.Properties)
    prop = mc.Properties{i};
    
    % Check for constant properties
    if prop.Constant
        value = Household_DecMPC.(prop.Name);
        constantProps = [constantProps, {prop.Name}];
        constantValues = [constantValues, value];
    end
    
    % Check for public properties
    if ~prop.Constant && strcmp(prop.SetAccess, 'public')
        value = householdMPC.(prop.Name);
        publicProps = [publicProps, {prop.Name}];
        publicValues = [publicValues, value];
    end
end

% Display constant properties and their values
disp('Constant properties and values:');
disp(constantProps);
disp(constantValues);

% Display public properties and their values
disp('Public properties and values:');
disp(publicProps);
disp(publicValues);

% Combine constant and public properties into one array
allProps = [constantProps, publicProps];
allValues = [constantValues, publicValues];

% Display all properties and their values
disp('All properties and values:');
disp(allProps);
disp(allValues);