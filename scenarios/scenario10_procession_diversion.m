function [scenario, egoVehicle] = scenario10_procession_diversion()
    % SCENARIO10_PROCESSION_DIVERSION Scenario 10: Street Procession & Road Diversion
    % Models a large slow-moving wedding/religious procession occupying the left half
    % of the carriageway under Left-Hand Drive. Temporary traffic cones route traffic
    % into a single-lane choke point. Ego executes Stateflow CRAWL_MODE while
    % an oncoming car patiently yields at the other end.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 32, 'SampleTime', 0.1);
    
    % Deterministic random seed for crowd positioning
    rng(cfg.defaultSeed);
    
    % Urban road: 200m long, 9m wide (Left lane: y in [0, 4.5], Right lane: y in [-4.5, 0])
    roadCenters = [0 0 0; 200 0 0];
    road(scenario, roadCenters, 9);
    
    % Ego vehicle starts in left lane at [0, 2.25, 0] at 8 m/s (~29 km/h)
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 2.25 0], 'Velocity', [8 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [0 2.25 0; 200 2.25 0], 8);
    
    % Temporary Roadwork Cones / Diversion Barricades routing traffic from
    % left lane (y=+2.25m) rightward into the shared bypass corridor (y=-1.0m)
    conePositions = [50 3.0; 60 2.2; 70 1.2; 80 0.5; 90 0.5; 100 0.5; 110 1.2; 120 3.0];
    for c = 1:size(conePositions, 1)
        actor(scenario, 'ClassID', cfg.classes.HAZARD, 'Length', 0.5, 'Width', 0.5, 'Height', 0.8, ...
            'Position', [conePositions(c, 1) conePositions(c, 2) 0], 'Name', sprintf('Cone%d', c));
    end
    
    % MOVING PROCESSION CROWD: 8 pedestrians clustered behind the barricade cones
    % Moving slowly at 0.8 m/s in the left area (y in [1.5, 4.0], x from 75 to 95)
    for p = 1:8
        px = 75 + rand() * 18;
        py = 1.8 + rand() * 2.0;
        ped = actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
            'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
            'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [px py 0], ...
            'Velocity', [0.8 0 0], 'Name', sprintf('CrowdPed%d', p));
        trajectory(ped, [px py 0; px+20 py 0], 0.8);
    end
    
    % Decorated Procession Pushcart / Band Cart at center of crowd
    cart = actor(scenario, 'ClassID', cfg.classes.PUSHCART, ...
        'Length', cfg.dimensions.PUSHCART(1), 'Width', cfg.dimensions.PUSHCART(2), ...
        'Height', cfg.dimensions.PUSHCART(3), 'Position', [85 2.8 0], ...
        'Velocity', [0.8 0 0], 'Name', 'ProcessionCart');
    trajectory(cart, [85 2.8 0; 130 2.8 0], 0.8);
    
    % Oncoming vehicle waiting patiently at the other end of the choke point
    patientCar = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [145 -2.25 0], 'Velocity', [0 0 0], 'Yaw', 180, 'Name', 'YieldingCar');
end
