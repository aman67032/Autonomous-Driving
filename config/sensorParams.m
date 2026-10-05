function params = sensorParams()
% SENSORPARAMS Returns a struct containing sensor configurations for the ego vehicle.
%
% Outputs:
%   params - Struct containing sensor parameters (camera, lidar, radar).

    params = struct();
    
    % Camera Parameters
    params.camera = struct();
    params.camera.range = 80; % meters
    params.camera.fov = deg2rad(60); % radians
    params.camera.resolution = [1920, 1080]; % [width, height]
    params.camera.fps = 30; % Hz
    params.camera.mountHeight = 1.5; % meters
    params.camera.pitch = deg2rad(1); % radians
    
    % Lidar Parameters
    params.lidar = struct();
    params.lidar.range = 100; % meters
    params.lidar.channels = 64; 
    params.lidar.fov = deg2rad(360); % radians
    params.lidar.fps = 10; % Hz
    params.lidar.mountHeight = 1.8; % meters
    
    % Radar Parameters
    params.radar = struct();
    params.radar.range = 150; % meters
    params.radar.fov = deg2rad(90); % radians
    params.radar.fps = 20; % Hz
    params.radar.mountHeight = 0.5; % meters
end
