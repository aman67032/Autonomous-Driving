function steeringAngle = lateralController(egoState, refPath)
    % LATERALCONTROLLER Stanley lateral controller
    %
    % Inputs:
    %   egoState - [x, y, heading, speed]
    %   refPath - Nx2 array of [x, y] path points
    %
    % Outputs:
    %   steeringAngle - Command in radians
    
    x = egoState(1);
    y = egoState(2);
    heading = egoState(3);
    speed = egoState(4);
    
    k = 2.5;
    k_soft = 1.0;
    maxSteerAngle = 0.6; % roughly 35 degrees
    
    % Find nearest path point
    minDist = inf;
    nearestIdx = 1;
    for i = 1:size(refPath, 1)
        dist = norm([x - refPath(i,1), y - refPath(i,2)]);
        if dist < minDist
            minDist = dist;
            nearestIdx = i;
        end
    end
    
    % Calculate crosstrack error
    dx = refPath(nearestIdx, 1) - x;
    dy = refPath(nearestIdx, 2) - y;
    
    % Determine side of path
    crosstrackError = minDist;
    pathHeading = atan2(dy, dx);
    angleDiff = pathHeading - heading;
    angleDiff = mod(angleDiff + pi, 2*pi) - pi;
    
    if angleDiff < 0
        crosstrackError = -crosstrackError;
    end
    
    % Calculate heading error
    if nearestIdx < size(refPath, 1)
        pathTangent = atan2(refPath(nearestIdx+1, 2) - refPath(nearestIdx, 2), ...
                            refPath(nearestIdx+1, 1) - refPath(nearestIdx, 1));
    else
        pathTangent = pathHeading;
    end
    
    headingError = pathTangent - heading;
    headingError = mod(headingError + pi, 2*pi) - pi;
    
    % Stanley steering control law
    steeringAngle = headingError + atan2(k * crosstrackError, speed + k_soft);
    
    % Clamp
    steeringAngle = max(-maxSteerAngle, min(maxSteerAngle, steeringAngle));
end
