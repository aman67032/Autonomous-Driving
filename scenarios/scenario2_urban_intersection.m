function [scenario, egoVehicle] = scenario2_urban_intersection()
    % SCENARIO2_URBAN_INTERSECTION Scenario 2: 4-Way Unsignalized Urban Intersection
    % Models a chaotic Indian city crossing with mixed traffic under Left-Hand Drive.
    % Ego approaches from the South in the left lane (x=-2.0m, y heading North)
    % and executes an unprotected left turn into the Westbound lane (y=+2.0m, -x).
    % Ego must yield to crossing vehicles and pedestrians before completing the turn.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 30, 'SampleTime', 0.1);

    % Two 8m-wide roads crossing at origin
    % North-South Road: Left lane (NB) x=-2.0m, Right lane (SB) x=+2.0m
    % East-West Road:   Left lane (EB) y=-2.0m, Right lane (WB) y=+2.0m
    roadCentersNS = [0 -80 0; 0 80 0];
    roadCentersEW = [-80 0 0; 80 0 0];
    road(scenario, roadCentersNS, 8);
    road(scenario, roadCentersEW, 8);

    % Ego vehicle approaches from south in NB left lane at 6 m/s, turns left onto WB road
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [-2.0 -45 0], 'Velocity', [0 6 0], 'Yaw', 90, 'Name', 'Ego');
    % Smooth turn path: from [-2, -45] -> [-2, -5] -> [-5, 2] -> [-60, 2]
    trajectory(egoVehicle, [-2.0 -45 0; -2.0 -8 0; -8 2.0 0; -60 2.0 0], 5);

    % Car 1: Westbound on East-West road (Right lane y=+2.0m) at 6 m/s
    % Crosses origin at t ~ 7.5s, extends well past intersection to x=-70m
    c1 = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [45 2.0 0], 'Velocity', [-6 0 0], 'Yaw', 180, 'Name', 'Car1_WB');
    trajectory(c1, [45 2.0 0; -70 2.0 0], 6);

    % Car 2: Eastbound on East-West road (Left lane y=-2.0m) at 7 m/s
    % Starts at x=-55m, extends to x=+70m (does NOT park at Ego's exit!)
    c2 = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [-55 -2.0 0], 'Velocity', [7 0 0], 'Name', 'Car2_EB');
    trajectory(c2, [-55 -2.0 0; 70 -2.0 0], 7);

    % Car 3: Southbound on North-South road (Right lane x=+2.0m) at 5.5 m/s
    % Starts at y=+50m, reaches intersection at t ~ 9.0s (clear of Car2)
    c3 = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [2.0 50 0], 'Velocity', [0 -5.5 0], 'Yaw', -90, 'Name', 'Car3_SB');
    trajectory(c3, [2.0 50 0; 2.0 -70 0], 5.5);

    % Auto-rickshaw 1: Aggressively cuts across from West heading East, turns South
    a1 = actor(scenario, 'ClassID', cfg.classes.AUTO, ...
        'Length', cfg.dimensions.AUTO(1), 'Width', cfg.dimensions.AUTO(2), ...
        'Height', cfg.dimensions.AUTO(3), 'Position', [-35 -1.0 0], ...
        'Velocity', [5 0 0], 'Name', 'Auto1');
    trajectory(a1, [-35 -1.0 0; -4 -1.0 0; 2.0 -12 0; 2.0 -60 0], 5);

    % Motorcycle 1: Zips across junction from North to South along shoulder
    m1 = actor(scenario, 'ClassID', cfg.classes.MOTORCYCLE, ...
        'Length', cfg.dimensions.MOTORCYCLE(1), 'Width', cfg.dimensions.MOTORCYCLE(2), ...
        'Height', cfg.dimensions.MOTORCYCLE(3), 'Position', [-3.2 40 0], ...
        'Velocity', [0 -7 0], 'Yaw', -90, 'Name', 'Moto1');
    trajectory(m1, [-3.2 40 0; -3.2 -60 0], 7);

    % Pedestrians on designated perimeter crosswalks (No point-convergence)
    % Ped 1: Crosses North crosswalk (y=+10m) from East to West
    actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [6 10 0], ...
        'Velocity', [-1.2 0 0], 'Yaw', 180, 'Name', 'Ped_North');
    % Ped 2: Crosses South crosswalk (y=-12m) from West to East right in front of Ego's approach
    p2 = actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [-8 -12 0], ...
        'Velocity', [1.1 0 0], 'Name', 'Ped_South');
    trajectory(p2, [-8 -12 0; 8 -12 0], 1.1);
    
    % Ped 3: Crosses West exit crosswalk (x=-10m) from South to North
    p3 = actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [-12 -6 0], ...
        'Velocity', [0 1.0 0], 'Yaw', 90, 'Name', 'Ped_West');
    trajectory(p3, [-12 -6 0; -12 6 0], 1.0);

    % Slow vegetable pushcart on the western kerb
    actor(scenario, 'ClassID', cfg.classes.PUSHCART, ...
        'Length', cfg.dimensions.PUSHCART(1), 'Width', cfg.dimensions.PUSHCART(2), ...
        'Height', cfg.dimensions.PUSHCART(3), 'Position', [-30 3.2 0], ...
        'Velocity', [-0.8 0 0], 'Yaw', 180, 'Name', 'Pushcart');
end
