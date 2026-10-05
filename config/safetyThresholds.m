function thresholds = safetyThresholds()
% SAFETYTHRESHOLDS Returns a struct containing safety and emergency thresholds.
%
% Outputs:
%   thresholds - Struct containing safety parameters.

    thresholds = struct();
    
    % Time & Distance Thresholds
    thresholds.minTTC = 1.5; % seconds (Minimum Time-to-Collision)
    thresholds.minPET = 0.8; % seconds (Minimum Post-Encroachment Time)
    thresholds.safeFollowDistance = 2.0; % seconds (Time gap)
    thresholds.maxReplanLatency = 0.2; % seconds
    thresholds.animalDetectionBrakeDistance = 30.0; % meters
    
    % Acceleration Limits
    thresholds.maxLatAccel = 4.0; % m/s^2
    thresholds.maxJerk = 10.0; % m/s^3
    thresholds.aebDecel = -8.0; % m/s^2 (Autonomous Emergency Braking)
    
    % Speed Limits for specific scenarios
    thresholds.maxSpeedNearPedestrian = 20 / 3.6; % m/s (20 km/h)
    thresholds.maxSpeedInMarket = 15 / 3.6; % m/s (15 km/h)
end
