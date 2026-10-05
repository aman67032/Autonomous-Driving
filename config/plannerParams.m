function params = plannerParams()
% PLANNERPARAMS Returns a struct containing path planning parameters.
%
% Outputs:
%   params - Struct containing planner configurations.

    % Load vehicle params for max curvature calculation
    vParams = vehicleParams();
    
    params = struct();
    
    % Grid & Time Horizons
    params.gridResolution = 0.5; % meters
    params.planningHorizon = 5.0; % seconds
    params.replanInterval = 0.1; % seconds
    params.numTrajectories = 5;
    
    % Cost Weights
    params.weights = struct();
    params.weights.length = 1.0;
    params.weights.risk = 5.0;
    params.weights.smoothness = 2.0;
    params.weights.comfort = 1.5;
    params.weights.roadSurface = 3.0;
    
    % Kinematic Constraints
    params.maxCurvature = 1 / vParams.minTurnRadius; % 1/m
    params.velocityResolution = 1.0; % m/s
    
    % MPC Settings
    params.mpcHorizon = 20; % steps
    params.mpcTimestep = 0.1; % seconds
end
