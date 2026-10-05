function tracks = fuseSensorData(cameraDets, lidarDets, radarDets)
    % fuseSensorData Fuses multi-modal detections using EKF multiObjectTracker
    
    % tracker initialization
    tracker = multiObjectTracker('FilterInitializationFcn', @initConstantVelocityFilter, ...
        'AssignmentThreshold', [30 200], ...
        'DeletionThreshold', [5 5], ...
        'ConfirmationThreshold', [3 5]);
    
    % Format inputs as objectDetection array
    allDetections = cell(0,1);
    t = 0; % simulation time or current time
    
    % Add camera detections (example formatting)
    for i = 1:length(cameraDets)
        meas = [cameraDets(i).position3D(1); cameraDets(i).position3D(2); 0; 0; 0; 0];
        measNoise = diag([1 1 1 1 1 1]); % placeholder noise
        det = objectDetection(t, meas, 'MeasurementNoise', measNoise);
        allDetections{end+1} = det;
    end
    
    if ~isempty(allDetections)
        tracks = tracker(allDetections, t);
    else
        tracks = [];
    end
end

function filter = initConstantVelocityFilter(detection)
    % Simple initialization for a 3D constant velocity EKF
    state = [detection.Measurement(1); detection.Measurement(2); detection.Measurement(3); 0; 0; 0];
    stateCov = eye(6);
    filter = trackingEKF(State=state, StateCovariance=stateCov);
end
