classdef Household_DecMPC
    
    % Private household properties 
    properties (Constant)
        
        rho_w = 1; % 1
        cp_w  = 1;
        V_S1  = 1;
        h_S1  = 1;
        A_S1  = 1;
        L_S1  = 1;
        D_S1  = 1;
        V_S2  = 1;
        h_S2  = 1;
        A_S2  = 1; % 10 
        L_S2  = 1;
        D_S2  = 1;
        h_b   = 1;
        A_b   = 1;
        C_b   = 1;
        V_S3  = 1;
        h_S3  = 1;
        A_S3  = 1;
        L_S3  = 1; 
        D_S3  = 1; % 20
        f_Darcy = 0.025;
        DeltaP_S1_max = 4;
        DeltaP_S2_max = 4;
        DeltaP_S3_max = 4; % 24
        
    end
    
    % Public household properties 
    properties 
        % Building set and ambient temperature
        T_set % 25
        T_amb % 26

        % Controller Hyperparameters
        K
        Ts
        Q % 29

        % Modeling 
        nx
        ny
        nu_mv
        nu_md

        % Parameters struct and NMPC object for block in Simulink
        nlobj
        adressBusParams
        validation
    end

    
    methods
        function obj = Household_DecMPC(T_set, T_amb, Ts, K, Q, adressBusParams, validation)
 
            % Set modeling dimensions properties 
            obj.nx = 4;
            obj.ny = 1;
            obj.nu_mv = 1;
            obj.nu_md = 1;
           
            % Set temperature values
            obj.T_amb = T_amb;
            obj.T_set = T_set;
            
            % Set controller hyperparameters
            obj.K = K;
            obj.Ts = Ts;
            obj.Q = Q;

            % Create NMPC object
            obj.nlobj = obj.createNMPC();
            obj.adressBusParams = adressBusParams;
            obj.validation = validation;

        end
        
        function params = getParametersCell(obj)
            propList = properties(obj);
            constPropList = properties('Household_DecMPC');
            
            numParams = numel(propList) + numel(constPropList) - 2;
            params = zeros(numParams, 1); 
            
            idx = 1;
            for i = 1:length(constPropList)
                params(idx) = Household.(constPropList{i});
                idx = idx + 1;
            end

            for i = 1:length(propList)
                if ~strcmp(propList{i}, 'nlobj') | ~strcmp(propList{i}, obj.adressBusParams) % Exclude nlobj and address properties
                    params(idx) = obj.(propList{i});
                    idx = idx + 1;
                end
            end

            params = {params};
        end

        function nlobj = createNMPC(obj)
            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(1+obj.nu_mv):(1+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            params = getParametersCell();

            % CreateParametersBus
            createParameterBus(nlobj, obj.adressBusParams, 'nameBusParams',params)

            % Prediction model
            nlobj.Model.NumberOfParameters = numel(params);
            nlobj.Model.StateFcn = "HouseholdTemperatureDynamic_DecMPC";
            nlobj.Model.OutputFcn = "HouseholdOutput_DecMPC";

            % Cost
            nlobj.Optimization.CustomCostFcn = "CostFunction_DecMPC";

            % Constraints
            nlobj.Optimization.CustomIneqConFcn = "IneqConFunction_DecMPC";

            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu_mv
                nlobj.ManipulatedVariables(i).Min = 0;
            end

            if obj.validation
                % Define a random initial state and input
                x0 = [1; 1; 1; 1];
                u0 = [2,1];
                
                % Validate functions
                validateFcns(nlobj, x0, u0(1), u0(2), params);
            end 

        end

    end
end
