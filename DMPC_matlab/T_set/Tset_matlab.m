classdef Tset_matlab
    
    % Public properties 
    properties
        dataset
        Ts
        K

        time
        data
        interpolated_data

    end
    
    methods
        % Constructor
        function obj = Tset_matlab(Ts, K)
            obj.load_data();
            obj.Ts = Ts;
            obj.K = K;

            obj.interpolate();

        end

        % Function to get interpolated data at specific time points
        function output = getInterpolatedValues(obj, time_input)
            % Interpolate the data at the specified input time
            output = interp1(obj.time, obj.data, time_input, 'linear', 'extrap');
        end

%%%%%%%%% Helper functions

        function obj = load_data(obj)
            % Get the full path of the currently running script
            if isdeployed
                % If the code is deployed, use the built-in method
                scriptFullPath = mfilename('fullpath');
            else
                % If running in the MATLAB environment, use the editor API
                scriptFullPath = matlab.desktop.editor.getActiveFilename;
            end
            
            % Extract the directory part of the path
            [scriptDir, ~, ~] = fileparts(scriptFullPath);
            
            obj.dataset = load([scriptDir, '/T_set_trajectory.mat']).Trajectory;

            % Extract the timeseries object from the dataset
            timeseries = obj.dataset.Trajectory.get('T_set');
            
            % Get the time and data values from the timeseries object
            obj.time = timeseries.Time;
            obj.data = timeseries.Data;
        end


        % Interpolation function
        function obj = interpolate(obj)
            % Create the time vector with the specified sample time
            t_min = min(obj.time);
            t_max = max(obj.time);
            t_interp = t_min:obj.Ts:t_max;
            
            % Interpolate the data based on the new time vector
            obj.interpolated_data = interp1(obj.time, obj.data, t_interp, 'linear', 'extrap');
        end

    end
end
