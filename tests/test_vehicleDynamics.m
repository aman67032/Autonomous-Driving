% test_vehicleDynamics.m
% Unit test for kinematic bicycle model dynamics
function test_vehicleDynamics()
    fprintf('Running test_vehicleDynamics...\n');
    
    % Load vehicle parameters
    vp = vehicleParams();
    dt = 0.05;
    
    % Test 1: Straight-line acceleration
    state0 = [0; 0; 0; 5.0]; % [x; y; theta; v]
    steer = 0.0;
    accel = 2.0;
    
    state1 = bicycleModel(state0, steer, accel, dt, vp);
    assert(state1(4) > state0(4), 'Speed should increase under positive acceleration');
    assert(abs(state1(2)) < 1e-5, 'Lateral deviation should be near zero on straight path');
    assert(state1(1) > state0(1), 'X position should advance');
    fprintf('  [PASS] Test 1: Straight line acceleration\n');
    
    % Test 2: Turning response (positive steering -> counter-clockwise yaw)
    steer = deg2rad(15);
    accel = 0.0;
    stateTurn = bicycleModel(state0, steer, accel, dt, vp);
    assert(stateTurn(3) > state0(3), 'Yaw heading should increase for positive steer');
    assert(stateTurn(2) > state0(2), 'Y position should increase during positive turn');
    fprintf('  [PASS] Test 2: Turning response & yaw integration\n');
    
    % Test 3: Maximum speed and brake clamping
    stateFast = [0; 0; 0; vp.maxSpeed];
    stateCapped = bicycleModel(stateFast, 0, 5.0, dt, vp);
    assert(stateCapped(4) <= vp.maxSpeed + 1e-4, 'Speed should not exceed maxSpeed limit');
    
    stateStop = [0; 0; 0; 0.1];
    stateStopped = bicycleModel(stateStop, 0, -5.0, dt, vp);
    assert(stateStopped(4) >= 0.0, 'Speed cannot drop below zero (no unintended reverse)');
    fprintf('  [PASS] Test 3: Velocity clamping and non-negative constraints\n');
    
    fprintf('All vehicle dynamics unit tests PASSED successfully.\n\n');
end
