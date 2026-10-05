function [scenario, egoVehicle] = scenario5_cattle_crossing()
    % SCENARIO5_CATTLE_CROSSING Scenario 5: Sudden Cattle Herd Crossing
    % Models a classic Indian rural highway hazard under Left-Hand Drive.
    % Ego cruises at 14 m/s (50 km/h) in the left lane (y=+1.75m).
    % A herd of cattle suddenly crosses from the left roadside at x=70m,
    % stepping into Ego's path at t~4.5s. This triggers an urgent AEB emergency stop.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 30, 'SampleTime', 0.1);
    
    % Undivided 2-lane road: 300m long, 7m wide (Left: y in [0, 3.5], Right: y in [-3.5, 0])
    roadCenters = [0 0 0; 300 0 0];
    road(scenario, roadCenters, 7);
    
    % Ego vehicle cruising at 14 m/s in left lane
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 1.75 0], 'Velocity', [14 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [0 1.75 0; 300 1.75 0], 14);
    
    % Lead car ahead in left lane (clears area before herd enters)
    % Trajectory extends to x=450m so it NEVER stops in the simulation area
    c1 = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [45 1.75 0], 'Velocity', [14 0 0], 'Name', 'LeadCar');
    trajectory(c1, [45 1.75 0; 450 1.75 0], 14);
    
    % Oncoming vehicle in right lane (y=-1.75m) heading West
    c2 = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [150 -1.75 0], 'Velocity', [-12 0 0], 'Yaw', 180, 'Name', 'OncomingCar');
    trajectory(c2, [150 -1.75 0; -80 -1.75 0], 12);
    
    % Crossing Herd of 4 Stray Cows at x = 70m to 76m
    % Cows start at y=+5.5m and cross perpendicularly to y=-5.5m at 1.0 m/s
    % They occupy Ego's left lane (y=+1.75m) between t=3.5s and t=6.5s!
    cowSpacing = [70, 72, 74, 76];
    for i = 1:4
        cowX = cowSpacing(i);
        cow = actor(scenario, 'ClassID', cfg.classes.CATTLE, ...
            'Length', cfg.dimensions.CATTLE(1), 'Width', cfg.dimensions.CATTLE(2), ...
            'Height', cfg.dimensions.CATTLE(3), 'Position', [cowX 5.5 0], ...
            'Velocity', [0 -1.0 0], 'Yaw', -90, 'Name', sprintf('Cow%d', i));
        trajectory(cow, [cowX 5.5 0; cowX -5.5 0], 1.0);
    end
    
    % 1 Pastoral Herder trailing 5m behind the herd at y=+9.5m
    herder = actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [78 9.5 0], ...
        'Velocity', [0 -0.8 0], 'Yaw', -90, 'Name', 'Herder');
    trajectory(herder, [78 9.5 0; 78 -5.0 0], 0.8);
end
