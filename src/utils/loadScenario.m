function simState = loadScenario(scenarioNumber)
    % LOADSCENARIO Initializes scenario and configures sensors/planners
    
    simState = struct();
    
    % Load configuration
    simState.config = simulationParams();
    
    % Load chosen scenario
    names = {
        'Scenario 1: Village Road (Unmarked & Cattle)', ...
        'Scenario 2: Urban Intersection (Unsignalized)', ...
        'Scenario 3: Highway Merge (Slow Tractor)', ...
        'Scenario 4: Dense Market Area (Pushcarts & Swarm)', ...
        'Scenario 5: Sudden Cattle Crossing', ...
        'Scenario 6: Contra-Flow Wrong-Way Traffic', ...
        'Scenario 7: Monsoon Flood & Waterlogged Potholes', ...
        'Scenario 8: Sudden Auto/Bus Passenger Pickup', ...
        'Scenario 9: Night/Dense Fog (LiDAR-Radar Fusion)', ...
        'Scenario 10: Wedding / Religious Procession & Diversion', ...
        'Scenario 11: Real-World Delhi OpenStreetMap & TraPHic Replay'
    };

    switch scenarioNumber
        case 1
            [simState.scenario, simState.ego] = scenario1_village_road();
        case 2
            [simState.scenario, simState.ego] = scenario2_urban_intersection();
        case 3
            [simState.scenario, simState.ego] = scenario3_highway_merge();
        case 4
            [simState.scenario, simState.ego] = scenario4_market_area();
        case 5
            [simState.scenario, simState.ego] = scenario5_cattle_crossing();
        case 6
            [simState.scenario, simState.ego] = scenario6_wrong_way_traffic();
        case 7
            [simState.scenario, simState.ego] = scenario7_monsoon_waterlogging();
        case 8
            [simState.scenario, simState.ego] = scenario8_sudden_auto_pickup();
        case 9
            [simState.scenario, simState.ego] = scenario9_night_fog_fusion();
        case 10
            [simState.scenario, simState.ego] = scenario10_procession_diversion();
        case 11
            [simState.scenario, simState.ego] = scenario11_real_delhi_osm_replay();
        otherwise
            error('Invalid scenario number. Choose 1 to 11.');
    end
    
    simState.scenarioName = names{scenarioNumber};
    
    % Initialize Mock Sensors
    simState.sensors.vision = struct('range', 150, 'fov', 60);
    simState.sensors.lidar = struct('range', 100, 'fov', 360);
    
    % Initialize Planner State
    simState.planner.state = 'initialized';
    
    % Initialize Metrics
    simState.metrics = struct();
    metricList = {'minTTC', 'collisions', 'completionRate', 'smoothnessScore', 'replanTime'};
    for m = metricList
        simState.metrics.(m{1}) = 0;
    end
    simState.metrics.completionRate = 100;
end
