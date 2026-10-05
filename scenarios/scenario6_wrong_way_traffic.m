function [scenario, egoVehicle] = scenario6_wrong_way_traffic()
    % SCENARIO6_WRONG_WAY_TRAFFIC Scenario 6: Contra-Flow Wrong-Way Traffic Evasion
    % Models a notorious Indian road hazard under Left-Hand Drive.
    % Ego cruises in the left lane (y=+1.75m) at 12 m/s (43 km/h).
    % An auto-rickshaw drives in the wrong direction directly in Ego's lane at 8 m/s.
    % The lead car detects the hazard and evades to the shoulder at t=5s.
    % The right lane has a clear 5-second window before an oncoming truck arrives,
    % allowing Ego to execute an active collision-avoidance maneuver.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 25, 'SampleTime', 0.1);
    
    % Undivided 2-lane road: 300m long, 7m wide (Left: y in [0, 3.5], Right: y in [-3.5, 0])
    roadCenters = [0 0 0; 300 0 0];
    road(scenario, roadCenters, 7);
    
    % Ego vehicle cruising in left lane (y=+1.75m) at 12 m/s
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 1.75 0], 'Velocity', [12 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [0 1.75 0; 300 1.75 0], 12);
    
    % Lead vehicle ahead at 10 m/s: at x=90m it spots the wrong-way auto
    % and smoothly swerves to the left shoulder (y=+3.2m), preventing mutual collision
    leadCar = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [45 1.75 0], 'Velocity', [10 0 0], 'Name', 'LeadCar');
    trajectory(leadCar, [45 1.75 0; 90 1.75 0; 110 3.2 0; 350 3.2 0], 10);
    
    % WRONG-WAY DRIVER: Auto-rickshaw heading West in Ego's left lane (y=+1.75m)
    % Starts at x=190m at speed 8 m/s (Yaw 180). Closing speed with Ego is 20 m/s
    wrongWayAuto = actor(scenario, 'ClassID', cfg.classes.AUTO, ...
        'Length', cfg.dimensions.AUTO(1), 'Width', cfg.dimensions.AUTO(2), ...
        'Height', cfg.dimensions.AUTO(3), 'Position', [190 1.75 0], ...
        'Velocity', [-8 0 0], 'Yaw', 180, 'Name', 'WrongWayAuto');
    trajectory(wrongWayAuto, [190 1.75 0; -50 1.75 0], 8);
    
    % Oncoming Truck in the right lane (y=-1.75m)
    % Starts far back at x=250m at 10 m/s; reaches x=100m only at t=15s
    % Provides a safe 5-second gap for Ego to evade
    oncomingTruck = vehicle(scenario, 'ClassID', cfg.classes.TRUCK, ...
        'Length', cfg.dimensions.TRUCK(1), 'Width', cfg.dimensions.TRUCK(2), ...
        'Height', cfg.dimensions.TRUCK(3), 'Position', [250 -1.75 0], ...
        'Velocity', [-10 0 0], 'Yaw', 180, 'Name', 'OncomingTruck');
    trajectory(oncomingTruck, [250 -1.75 0; -60 -1.75 0], 10);
    
    % Pedestrian walking safely on the right shoulder at x=140m
    actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [140 -4.2 0], ...
        'Velocity', [-0.8 0 0], 'Yaw', 180, 'Name', 'RightShoulderPed');
end
