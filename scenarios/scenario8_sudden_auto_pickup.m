function [scenario, egoVehicle] = scenario8_sudden_auto_pickup()
    % SCENARIO8_SUDDEN_AUTO_PICKUP Scenario 8: Sudden Auto-Rickshaw Passenger Pickup
    % Models a notorious urban Indian hazard under Left-Hand Drive.
    % An auto-rickshaw ahead suddenly spots a hailing passenger on the left pavement,
    % slams on brakes with -5.5 m/s^2 deceleration, and swerves toward the kerb.
    % Ego must perform urgent longitudinal braking while a tailgating motorcycle
    % filters defensively to prevent a pile-up.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 25, 'SampleTime', 0.1);
    
    % Undivided 2-lane road: 250m long, 8m wide (Left: y in [0, 4], Right: y in [-4, 0])
    roadCenters = [0 0 0; 250 0 0];
    road(scenario, roadCenters, 8);
    
    % Ego vehicle cruising in left lane (y=+1.8m) at 12 m/s (~43 km/h)
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 1.8 0], 'Velocity', [12 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [0 1.8 0; 250 1.8 0], 12);
    
    % Erratic Auto-Rickshaw ahead at x=35m in left lane (speed 11 m/s)
    % At x=90m (t=5s), auto sees passenger, slams brakes (-5.5 m/s^2),
    % swerves toward left kerb (y=+3.0m), and halts at x=105m
    auto = actor(scenario, 'ClassID', cfg.classes.AUTO, ...
        'Length', cfg.dimensions.AUTO(1), 'Width', cfg.dimensions.AUTO(2), ...
        'Height', cfg.dimensions.AUTO(3), 'Position', [35 1.8 0], ...
        'Velocity', [11 0 0], 'Name', 'ErraticAuto');
    % True -5.5 m/s^2 emergency deceleration: 11 m/s -> 0 in ~2 seconds over ~11 meters
    autoWaypoints = [35 1.8 0; 90 1.8 0; 100 2.8 0; 105 3.0 0];
    trajectory(auto, autoWaypoints, [11; 11; 3.0; 0]);
    
    % Passenger hailing auto from the left pavement at x=110m, y=+3.8m
    % (Auto stops safely 5m before the passenger, avoiding collision)
    actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
        'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
        'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [110 3.8 0], ...
        'Velocity', [0 0 0], 'Name', 'HailingPassenger');
        
    % Defensive two-wheeler behind ego (motorcycle at x=-18m)
    % Offset toward center lane (y=+0.6m) with attentive deceleration to avoid rear-ending
    moto = actor(scenario, 'ClassID', cfg.classes.MOTORCYCLE, ...
        'Length', cfg.dimensions.MOTORCYCLE(1), 'Width', cfg.dimensions.MOTORCYCLE(2), ...
        'Height', cfg.dimensions.MOTORCYCLE(3), 'Position', [-18 0.6 0], ...
        'Velocity', [11 0 0], 'Name', 'FilteringMoto');
    trajectory(moto, [-18 0.6 0; 80 0.6 0; 120 0.2 0; 250 0.2 0], [11; 11; 4.0; 10.0]);
    
    % Oncoming traffic in right lane (y=-2.0m) preventing immediate right overtake
    oncomingCar = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [150 -2.0 0], 'Velocity', [-10 0 0], 'Yaw', 180, 'Name', 'OncomingCar');
    trajectory(oncomingCar, [150 -2.0 0; -30 -2.0 0], 10);
end
