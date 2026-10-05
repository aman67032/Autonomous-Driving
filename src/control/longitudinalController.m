function throttleOrBrake = longitudinalController(currentSpeed, targetSpeed, dt)
    % LONGITUDINALCONTROLLER PID speed controller
    %
    % Inputs:
    %   currentSpeed - Current speed in m/s
    %   targetSpeed - Target speed in m/s
    %   dt - Time step in seconds
    %
    % Outputs:
    %   throttleOrBrake - Command [-1, 1], positive=throttle, negative=brake
    
    if nargin < 3 || isempty(dt)
        dt = 0.1;
    end
    
    persistent integralError;
    persistent prevError;
    
    if isempty(integralError)
        integralError = 0;
        prevError = 0;
    end
    
    Kp = 1.0;
    Ki = 0.1;
    Kd = 0.05;
    
    error = targetSpeed - currentSpeed;
    
    % Integrator anti-windup
    integralError = integralError + error * dt;
    integralError = max(-5.0, min(5.0, integralError));
    
    derivativeError = (error - prevError) / dt;
    
    controlAction = Kp * error + Ki * integralError + Kd * derivativeError;
    
    prevError = error;
    
    % Normalize and clamp to [-1, 1]
    throttleOrBrake = max(-1.0, min(1.0, controlAction));
end
