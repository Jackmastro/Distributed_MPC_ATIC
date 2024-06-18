classdef Household
    
    % Private household properties 
    properties (Constant)
        rho_w = 1; % 1
        cp_w  = 1;
        V_F   = 1;
        h_F   = 1;
        A_F   = 1;
        V_S1  = 1;
        h_S1  = 1;
        A_S1  = 1;
        V_S2  = 1;
        h_S2  = 1; % 10
        A_S2  = 1;
        h_b   = 1;
        A_b   = 1;
        C_b   = 1;
        V_S3  = 1;
        h_S3  = 1;
        A_S3  = 1;
        V_R   = 1;
        h_R   = 1;
        A_R   = 1; % 20
        V_B   = 1;
        h_B   = 1;
        A_B   = 1; % 23
    end
    
    % Public household properties 
    properties 
        % Building set and ambient temperature
        T_set % 24
        T_amb

        % Modeling 
        is_first_house
        is_bypass_house % 27
        nx
        ny
        nu_mv
        nu_md

        % Controller Hyperparameters
        K
        Ts
        Q % 34
        
        % Damping Weights - Lagrange Multipliers Cost Function
        delta_m_O_pred = 1;
        delta_m_O_succ = 1;
        delta_m_R_pred = 1;
        delta_m_R_succ = 1;
        delta_T_F_pred = 1;
        delta_T_F_succ = 1;
        delta_T_R_pred = 1;
        delta_T_R_succ = 1;

        % Step sizes - Lagrange Multipliers Update 
        alfa_m_O_pred = 1; 
        alfa_m_O_succ = 1;
        alfa_m_R_pred = 1;
        alfa_m_R_alfa = 1;
        alfa_T_F_pred = 1;
        alfa_T_F_succ = 1;
        alfa_T_R_pred = 1;
        alfa_T_R_succ = 1;

        % NMPC object and adress for Simulink
        nlobj
        adressBusParams
        validation
    end
    
    methods

        function obj = Household(is_first_house, is_bypass_house, T_set, T_amb, Ts, K, Q, adressBusParams, validation) 
            
            % Set the first_house and bypass_house properties
            obj.is_first_house = is_first_house;
            obj.is_bypass_house = is_bypass_house;

            % Set modeling dimensions properties 
            if is_bypass_house
                obj.nx = 7;
            else
                obj.nx = 6;
            end

            obj.ny = 1;
            obj.nu_mv = 7;

            if is_bypass_house
                obj.nu_md = 8;
            elseif is_first_house
                obj.nu_md = 8;
            else
                obj.nu_md = 16;
            end

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
            
            numParams = numel(propList) - 2; % excluding nlobj and adressBusParams
            params = zeros(numParams, 1); 

            for i = 1:numParams
                if strcmp(propList{i}, 'nlobj') || strcmp(propList{i}, 'adressBusParams') % Exclude nlobj and adress properties
                    continue
                end

                params(i) = obj.(propList{i});
            end

            params = {params};
        end
        
        function nlobj = createNMPC(obj)

            % Create NMPC object
            nlobj = nlmpc(obj.nx, obj.ny, 'MV', [1:obj.nu_mv], 'MD', [(obj.nu_mv+1):(obj.nu_mv+obj.nu_md)]);

            % NMPC parameters
            nlobj.PredictionHorizon = obj.K; 
            nlobj.Ts = obj.Ts;

            params = obj.getParametersCell();

            % CreateParametersBus
            createParameterBus(nlobj, obj.adressBusParams, 'nameBusParams', params)

            % Prediction model
            nlobj.Model.NumberOfParameters = numel(params);
            nlobj.Model.StateFcn = "HouseholdTemperatureDynamic";
            nlobj.Model.OutputFcn = "HouseholdOutput";

            % Cost
            nlobj.Optimization.CustomCostFcn = "CostFunction";

            % Constraints
            nlobj.Optimization.CustomEqConFcn = "EqConFunction";


            % State & Manipulated Variable constraints
            for i = 1:obj.nx
                nlobj.States(i).Min = 0;
            end

            for i = 1:obj.nu_mv
                nlobj.ManipulatedVariables(i).Min = 0;
            end

            % Validation 
            if obj.validation 
%                 % TO CHECK
%                 trackingOptions = nlmpcmoveopt;
%                 trackingOptions.Parameters = params;

                % Define a random initial state and input
                x0 = ones(obj.nx, 1);  % Example initial states
                u0 = ones(obj.nu_mv + obj.nu_md, 1); 
                
                params = {obj};
              
                % Validate functions
                validateFcns(obj.nlobj, x0, u0(1:7)', u0(8:15)', params);
            end
        end
    end
end
