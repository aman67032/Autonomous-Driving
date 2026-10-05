function sensors = initSensors(sensorParams)
    % initSensors Initializes perception sensors for the autonomous vehicle
    % Inputs:
    %   sensorParams - Struct containing parameters for sensors (optional)
    % Outputs:
    %   sensors - Struct containing initialized sensor objects

    if nargin < 1
        sensorParams = struct();
    end
    
    % Default camera parameters
    focalLength = [800, 800];
    principalPoint = [960, 540];
    imageSize = [1080, 1920];
    
    % Override with user params if provided
    if isfield(sensorParams, 'focalLength')
        focalLength = sensorParams.focalLength;
    end
    if isfield(sensorParams, 'principalPoint')
        principalPoint = sensorParams.principalPoint;
    end
    if isfield(sensorParams, 'imageSize')
        imageSize = sensorParams.imageSize;
    end
    
    intrinsics = cameraIntrinsics(focalLength, principalPoint, imageSize);
    
    % Create monoCamera
    sensorIndex = 1;
    pitch = 1; % degrees
    yaw = 0; % degrees
    roll = 0; % degrees
    sensorLocation = [1.5 0 1.5]; % [x y z] in meters relative to vehicle center
    camExtrinsics = cameraExtrinsics(sensorLocation, pitch, yaw, roll);
    camera = monoCamera(intrinsics, camExtrinsics);
    
    % Lidar
    lidar = lidarPointCloudGenerator('SensorIndex', 2, ...
        'SensorLocation', [1.5 0 2.0], ...
        'AzimuthResolution', 0.1, ...
        'ElevationResolution', 1.25, ...
        'ElevationLimits', [-15 15]);
        
    % Radar
    radar = drivingRadarDataGenerator('SensorIndex', 3, ...
        'MountingLocation', [3.5 0 0.5], ...
        'FieldOfView', [90 5], ...
        'RangeLimits', [0 150]);
        
    sensors.camera = camera;
    sensors.lidar = lidar;
    sensors.radar = radar;
end
