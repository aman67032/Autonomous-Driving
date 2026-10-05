% test_safetyMonitor.m
% Unit test for runtime safety monitor, TTC, and emergency braking
function test_safetyMonitor()
    fprintf('Running test_safetyMonitor...\n');
    
    thresholds = safetyThresholds();
    
    % Test 1: TTC computation for closing vehicle
    egoV = [0, 0, 15, 0]; % [x, y, vx, vy] at 15 m/s
    obsState = [30, 0, 0, 0, 4.5, 1.8]; % Stationary obstacle 30m ahead
    ttc = computeTTC(egoV, obsState);
    assert(ttc >= 1.5 && ttc <= 2.2, sprintf('Expected TTC in range [1.5, 2.2]s, got %.2f', ttc));
    fprintf('  [PASS] Test 1: TTC calculated correctly for head-on obstacle (%.2fs)\n', ttc);
    
    % Test 2: Emergency brake parameters
    [brakeCmd, decel, stopDist] = emergencyBrake(egoV, thresholds);
    assert(decel <= thresholds.aebDecel || abs(decel) >= abs(thresholds.aebDecel), 'Deceleration must match or exceed AEB target');
    assert(stopDist > 0, 'Stopping distance must be positive');
    fprintf('  [PASS] Test 2: Emergency brake parameters verified (%.1f m/s^2)\n', decel);
    
    % Test 3: Safety monitor override when TTC < minTTC
    egoState = [0, 0, 0, 15, 0]; % [x, y, heading, speed, accel]
    dangerousObstacle(1).x = 10; % Only 10m ahead at 15m/s -> TTC < 0.7s < 1.5s
    dangerousObstacle(1).y = 0;
    dangerousObstacle(1).vx = 0;
    dangerousObstacle(1).vy = 0;
    dangerousObstacle(1).length = 4.0;
    dangerousObstacle(1).width = 1.8;
    
    plannedTraj = [0, 0; 5, 0; 10, 0];
    currentCmd.throttle = 0.5;
    currentCmd.brake = 0.0;
    currentCmd.steer = 0.0;
    
    [safeCmd, overrideFlag, violation] = safetyMonitor(plannedTraj, egoState, dangerousObstacle, thresholds, currentCmd);
    assert(overrideFlag == true, 'Safety monitor must trigger override on low TTC');
    assert(strcmp(violation, 'TTC_VIOLATION'), 'Violation type must be TTC_VIOLATION');
    assert(safeCmd.brake > 0, 'Safe command must apply brake');
    assert(safeCmd.throttle == 0, 'Safe command must cut throttle');
    fprintf('  [PASS] Test 3: Safety monitor triggers emergency brake override\n');
    
    fprintf('All safety monitor unit tests PASSED successfully.\n\n');
end
