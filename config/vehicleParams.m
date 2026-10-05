function params = vehicleParams()
% VEHICLEPARAMS Returns a struct containing vehicle parameters for the ego vehicle.
%
% Outputs:
%   params - Struct containing vehicle parameters.

    params = struct();
    
    % Dimensions (meters)
    params.wheelbase = 2.7;
    params.trackWidth = 1.6;
    params.length = 4.5;
    params.width = 1.8;
    
    % Mass & Inertia
    params.mass = 1500; % kg
    params.Iz = 2500; % kg*m^2
    
    % Performance
    params.maxSpeed = 80 / 3.6; % m/s (80 km/h)
    params.maxAccel = 3.0; % m/s^2
    params.maxDecel = -7.0; % m/s^2
    
    % Steering
    params.maxSteerAngle = deg2rad(35); % radians
    params.minTurnRadius = params.wheelbase / tan(params.maxSteerAngle); % meters
    
    % Tire Dynamics
    params.Cf = 50000; % N/rad (Cornering stiffness, front)
    params.Cr = 50000; % N/rad (Cornering stiffness, rear)
end
