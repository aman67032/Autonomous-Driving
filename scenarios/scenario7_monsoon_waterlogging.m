function [scenario, egoVehicle] = scenario7_monsoon_waterlogging()
    % SCENARIO7_MONSOON_WATERLOGGING Scenario 7: Monsoon Flooding & Submerged Potholes
    % Models post-monsoon Indian driving conditions with waterlogged carriageways,
    % submerged deep potholes, reduced tire-road friction (mu=0.35), and an oncoming bus.
    % Under Left-Hand Drive: Ego travels in left lane (y=+1.75m).
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 28, 'SampleTime', 0.1);
    
    % Undivided 2-lane road: 250m long, 7m wide (Left: y in [0, 3.5], Right: y in [-3.5, 0])
    roadCenters = [0 0 0; 250 0 0];
    road(scenario, roadCenters, 7);
    
    % Ego vehicle cruising in left lane at 10 m/s (36 km/h)
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 1.75 0], 'Velocity', [10 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [0 1.75 0; 250 1.75 0], 10);
    
    % Waterlogged Hazard Area 1: Deep water pool spanning Ego's entire left lane
    % Centered at x=75m, y=+1.75m. Length 16m, width 3.2m
    actor(scenario, 'ClassID', cfg.classes.HAZARD, 'Length', 16, 'Width', 3.2, ...
        'Height', 0.3, 'Position', [75 1.75 0], 'Name', 'WaterloggedZone');
        
    % Submerged Deep Pothole concealed inside the pool at x=82m
    actor(scenario, 'ClassID', cfg.classes.HAZARD, 'Length', 1.5, 'Width', 1.5, ...
        'Height', 0.4, 'Position', [82 1.5 0], 'Name', 'SubmergedPothole');
    
    % Pedestrian wading through rainwater on the left shoulder
    actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [78 3.8 0], ...
        'Velocity', [0.4 0 0], 'Name', 'WadingPedestrian');
    
    % Stalled Two-Wheeler (Motorcycle stuck in floodwater) at x=89m, y=+2.5m
    actor(scenario, 'ClassID', cfg.classes.MOTORCYCLE, ...
        'Length', cfg.dimensions.MOTORCYCLE(1), 'Width', cfg.dimensions.MOTORCYCLE(2), ...
        'Height', cfg.dimensions.MOTORCYCLE(3), 'Position', [89 2.5 0], ...
        'Velocity', [0 0 0], 'Name', 'StalledMotorcycle');
    
    % Oncoming State Transport Bus driving in the right lane (y=-1.75m) at 7 m/s
    % Starts at x=190m; reaches flood zone at t=15.7s (leaves a clear window for Ego)
    oncomingBus = vehicle(scenario, 'ClassID', cfg.classes.TRUCK, ...
        'Length', 11, 'Width', 2.6, 'Height', 3.4, 'Position', [190 -1.75 0], ...
        'Velocity', [-7 0 0], 'Yaw', 180, 'Name', 'OncomingBus');
    trajectory(oncomingBus, [190 -1.75 0; -40 -1.75 0], 7);
end
