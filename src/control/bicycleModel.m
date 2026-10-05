function newState = bicycleModel(currentState, steerAngle, accel, dt, vehicleParams)
    % BICYCLEMODEL Kinematic bicycle model
    %
    % Inputs:
    %   currentState - [x, y, heading, speed]
    %   steerAngle - Steering angle in radians
    %   accel - Acceleration in m/s^2
    %   dt - Time step in seconds
    %   vehicleParams - (optional) struct with wheelbase and maxSpeed
    %
    % Outputs:
    %   newState - [x, y, heading, speed]
    
    x = currentState(1);
    y = currentState(2);
    heading = currentState(3);
    speed = currentState(4);
    
    if nargin >= 5 && isstruct(vehicleParams)
        wheelbase = vehicleParams.wheelbase;
        maxSpeed  = vehicleParams.maxSpeed;
    else
        wheelbase = 2.7; % meters
        maxSpeed = 35.0; % m/s
    end
    
    % State updates (using midpoint integration for accurate curvature response)
    newHeading = heading + (speed / wheelbase) * tan(steerAngle) * dt;
    midHeading = (heading + newHeading) / 2;
    newX = x + speed * cos(midHeading) * dt;
    newY = y + speed * sin(midHeading) * dt;
    newSpeed = speed + accel * dt;
    
    % Wrap heading to [-pi, pi]
    newHeading = mod(newHeading + pi, 2*pi) - pi;
    
    % Clamp speed to [0, maxSpeed]
    newSpeed = max(0, min(maxSpeed, newSpeed));
    
    newState = [newX, newY, newHeading, newSpeed];
end
