close all

% Define parameters
duration_days = 1; % duration in days
duration_seconds = duration_days * 24 * 3600; % duration in seconds

% Time vector
t = linspace(0, duration_seconds, duration_seconds);

% Sinusoidal parameters
amplitude = 10; % amplitude of the temperature variation (e.g., +/- 10 degrees)
mean_temp = 273; % mean temperature (e.g., 20 degrees Celsius)
frequency = 0.5 / (24 * 3600); % frequency of the sinusoidal wave (1 cycle per day)
phase_shift = 0; % phase shift to start from midnight and peak at noon

% Temperature as a function of time
temperature = mean_temp + amplitude * sin(2 * pi * frequency * t + phase_shift);

% Plot the temperature evolution
figure;
plot(t, temperature);
xlabel('Time (seconds)');
ylabel('Temperature (°C)');
title('Ambient Temperature Evolution Over 2 Days');
grid on;
