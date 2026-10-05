function [scenario, egoVehicle] = scenario9_night_fog_fusion()
    % SCENARIO9_NIGHT_FOG_FUSION Scenario 9: Night / Dense Fog with Multi-Modal Sensor Fusion
    % Models zero street-lighting and dense winter fog under Left-Hand Drive.
    % Cameras suffer severe contrast loss beyond 15m; Radar and 64-channel LiDAR
    % maintain geometric detection of an unlit wooden bullock cart ahead.
    % Ego yields behind the slow cart until an oncoming car passes, then overtakes.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 28, 'SampleTime', 0.1);
    
    % Undivided 2-lane road: 300m long, 7m wide (Left: y in [0, 3.5], Right: y in [-3.5, 0])
    roadCenters = [0 0 0; 300 0 0];
    road(scenario, roadCenters, 7);
    
    % Ego vehicle in left lane (y=+1.75m) cruising at 14 m/s (50 km/h)
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 1.75 0], 'Velocity', [14 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [0 1.75 0; 300 1.75 0], 14);
    
    % UNLIT HAZARD 1: Slow Wooden Bullock Cart ahead in left lane at x=95m
    % Moving slowly at 2.5 m/s without any taillights or reflectors
    bullockCart = actor(scenario, 'ClassID', cfg.classes.PUSHCART, ...
        'Length', 4.8, 'Width', 1.9, 'Height', 2.2, ...
        'Position', [95 1.75 0], 'Velocity', [2.5 0 0], 'Name', 'UnlitBullockCart');
    trajectory(bullockCart, [95 1.75 0; 300 1.75 0], 2.5);
    
    % UNLIT HAZARD 2: Darkly clothed pedestrian on the left shoulder at x=75m
    actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [75 3.8 0], ...
        'Velocity', [0.8 0 0], 'Name', 'UnlitPedestrian');
        
    % Oncoming traffic in right lane (y=-1.75m) heading West at 10 m/s
    % Starts at x=175m, passes the bullock cart at t ~ 6.5s, clearing the lane for Ego by t=8s
    oncomingTraffic = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [175 -1.75 0], 'Velocity', [-10 0 0], 'Yaw', 180, 'Name', 'OncomingCar');
    trajectory(oncomingTraffic, [175 -1.75 0; -50 -1.75 0], 10);
end
