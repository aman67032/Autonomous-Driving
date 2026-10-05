function [scenario, egoVehicle] = scenario4_market_area()
    % SCENARIO4_MARKET_AREA Scenario 4: Dense Indian Market Street Swarm
    % Models an overcrowded bazaar street with pedestrians, vegetable pushcarts,
    % weaving two-wheelers, stopping autos, and a partially parked delivery truck.
    % Uses Left-Hand Drive and deterministic seeded pedestrian trajectories.
    
    cfg = scenarioConfig();
    scenario = drivingScenario('StopTime', 40, 'SampleTime', 0.1);
    
    % Deterministic random seed for reproducible benchmark metrics
    rng(cfg.defaultSeed);
    
    % Road: 150m long, 8m wide (Left lane: y in [0, 4], Right lane: y in [-4, 0])
    roadCenters = [0 0 0; 150 0 0];
    road(scenario, roadCenters, 8);
    
    % Permanent roadside stalls / wooden shop awnings on both boundaries
    for x = 10:20:140
        actor(scenario, 'ClassID', cfg.classes.HAZARD, 'Length', 4, 'Width', 1.8, ...
            'Height', 2.0, 'Position', [x 4.8 0], 'Name', 'ShopLeft');
        actor(scenario, 'ClassID', cfg.classes.HAZARD, 'Length', 4, 'Width', 1.8, ...
            'Height', 2.0, 'Position', [x -4.8 0], 'Name', 'ShopRight');
    end
    
    % Ego vehicle crawls in left lane (y=+1.8m) at 4 m/s (~14 km/h)
    % Reaches end of 150m street at t ~ 37s (well within StopTime=40s)
    egoVehicle = vehicle(scenario, 'ClassID', cfg.classes.CAR, ...
        'Position', [0 1.8 0], 'Velocity', [4 0 0], 'Name', 'Ego');
    trajectory(egoVehicle, [0 1.8 0; 150 1.8 0], 4);
    
    % Partially Parked Delivery Truck at x=85m, y=2.2m (blocks half of Ego's lane)
    vehicle(scenario, 'ClassID', cfg.classes.TRUCK, ...
        'Length', 8.0, 'Width', 2.4, 'Height', 3.0, 'Position', [85 2.2 0], ...
        'Velocity', [0 0 0], 'Name', 'ParkedDeliveryTruck');
    
    % 8 Crossing pedestrians with seeded deterministic positions
    for p = 1:8
        px = 15 + p * 14;
        yStart = 3.5 * (mod(p, 2)*2 - 1); % Alternate sides
        yEnd   = -yStart;
        ped = actor(scenario, 'ClassID', cfg.classes.PEDESTRIAN, ...
            'Length', cfg.dimensions.PEDESTRIAN(1), 'Width', cfg.dimensions.PEDESTRIAN(2), ...
            'Height', cfg.dimensions.PEDESTRIAN(3), 'Position', [px yStart 0], ...
            'Velocity', [0.3 sign(yEnd)*0.8 0], 'Name', sprintf('MarketPed%d', p));
        trajectory(ped, [px yStart 0; px+2 yEnd 0], 0.8);
    end
    
    % 2 Wooden Pushcarts moving slowly along the kerbs at 0.6 m/s
    pc1 = actor(scenario, 'ClassID', cfg.classes.PUSHCART, ...
        'Length', cfg.dimensions.PUSHCART(1), 'Width', cfg.dimensions.PUSHCART(2), ...
        'Height', cfg.dimensions.PUSHCART(3), 'Position', [25 3.0 0], ...
        'Velocity', [0.6 0 0], 'Name', 'FruitPushcart');
    trajectory(pc1, [25 3.0 0; 150 3.0 0], 0.6);
    
    pc2 = actor(scenario, 'ClassID', cfg.classes.PUSHCART, ...
        'Length', cfg.dimensions.PUSHCART(1), 'Width', cfg.dimensions.PUSHCART(2), ...
        'Height', cfg.dimensions.PUSHCART(3), 'Position', [60 -3.0 0], ...
        'Velocity', [-0.6 0 0], 'Yaw', 180, 'Name', 'TeaPushcart');
    trajectory(pc2, [60 -3.0 0; 0 -3.0 0], 0.6);
    
    % 1 Stopping/Starting Auto-Rickshaw ahead in left lane (at x=35m)
    auto1 = actor(scenario, 'ClassID', cfg.classes.AUTO, ...
        'Length', cfg.dimensions.AUTO(1), 'Width', cfg.dimensions.AUTO(2), ...
        'Height', cfg.dimensions.AUTO(3), 'Position', [35 1.8 0], 'Name', 'StoppingAuto');
    trajectory(auto1, [35 1.8 0; 55 2.8 0; 75 2.8 0; 150 1.8 0], [3; 0.5; 1.5; 3.5]);
    
    % 1 Weaving Motorcycle avoiding the parked truck on the right
    moto1 = actor(scenario, 'ClassID', cfg.classes.MOTORCYCLE, ...
        'Length', cfg.dimensions.MOTORCYCLE(1), 'Width', cfg.dimensions.MOTORCYCLE(2), ...
        'Height', cfg.dimensions.MOTORCYCLE(3), 'Position', [20 -0.5 0], 'Name', 'WeavingMoto');
    % Trajectory passes safely around the parked truck (swerves to y=-1.5m at x=85m)
    trajectory(moto1, [20 -0.5 0; 60 0.5 0; 85 -1.5 0; 110 0 0; 150 0 0], 5);
end
