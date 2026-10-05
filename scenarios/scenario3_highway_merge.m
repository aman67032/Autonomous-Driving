function [scenario, egoVehicle] = scenario3_highway_merge()
    % SCENARIO3_HIGHWAY_MERGE Scenario 3: Highway Merge with Slow Tractor & Fast Traffic
    % Models an Indian divided national highway (Left-Hand Drive).
    % Main highway has 2 lanes heading East (+x):
    %   Left Lane  (Slow/Cruising) : y = +1.75m
    %   Right Lane (Fast Overtaking): y = -1.75m
    % Ego enters via a left-hand slip ramp at 14 m/s, merging at x=180m.
    % Ego encounters a slow 15 km/h tractor in the merge lane while fast 80 km/h
    % traffic occupies the overtaking lane, forcing intelligent gap selection.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 32, 'SampleTime', 0.1);
    
    % Main Highway: 400m long, 7m wide (2 lanes of 3.5m)
    roadCenters = [0 0 0; 400 0 0];
    road(scenario, roadCenters, 7);
    
    % Slip Road Merge Ramp from left: enters at x=0, y=20m; blends at x=180m, y=1.75m
    rampCenters = [0 20 0; 90 10 0; 180 1.75 0];
    road(scenario, rampCenters, 3.5);
    
    % Ego Vehicle on merge ramp (speed 14 m/s ~ 50 km/h)
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 20 0], 'Velocity', [14 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [rampCenters; 400 1.75 0], 14);
    
    % Slow Agricultural Tractor ahead in highway left lane (speed 4.0 m/s ~ 14.4 km/h)
    % Positioned at x=205m; reaches x=257m at t=13s when Ego merges at x=180m
    tractor = vehicle(scenario, 'ClassID', cfg.classes.TRUCK, ...
        'Length', 4.5, 'Width', 2.0, 'Height', 2.5, 'Position', [205 1.75 0], ...
        'Velocity', [4 0 0], 'Name', 'Tractor');
    trajectory(tractor, [205 1.75 0; 400 1.75 0], 4);
    
    % Fast Car 1 in right lane (overtaking lane y=-1.75m) at 22 m/s (80 km/h)
    % Reaches merge area simultaneously at t ~ 12.8s
    c1 = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [100 -1.75 0], 'Velocity', [22 0 0], 'Name', 'HighwayCar1');
    trajectory(c1, [100 -1.75 0; 400 -1.75 0], 22);
    
    % Fast Truck in right lane following at 18 m/s behind Car 1
    t1 = vehicle(scenario, 'ClassID', cfg.classes.TRUCK, ...
        'Length', cfg.dimensions.TRUCK(1), 'Width', cfg.dimensions.TRUCK(2), ...
        'Height', cfg.dimensions.TRUCK(3), 'Position', [40 -1.75 0], ...
        'Velocity', [18 0 0], 'Name', 'HighwayTruck');
    trajectory(t1, [40 -1.75 0; 400 -1.75 0], 18);
end
