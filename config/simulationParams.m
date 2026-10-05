function params = simulationParams()
% SIMULATIONPARAMS Returns a struct containing global simulation settings.
%
% Outputs:
%   params - Struct containing simulation parameters.

    params = struct();
    
    % Time settings
    params.timestep = 0.01; % seconds
    params.duration = 60.0; % seconds
    
    % Execution Rates
    params.sampleRate = 100; % Hz
    params.plannerRate = 10; % Hz
    params.perceptionRate = 10; % Hz
    params.controlRate = 50; % Hz
    params.safetyMonitorRate = 50; % Hz
    
    % Diagnostics & Misc
    params.enableLogging = true;
    params.enableVisualization = true;
    params.seed = 42; % For reproducibility
end
