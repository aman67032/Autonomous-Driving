function cfg = scenarioConfig()
    % SCENARIOCONFIG Centralized configuration for all Indian Driving Scenarios
    % Standardizes Actor Class IDs, vehicle dimensions, road conventions,
    % weather conditions (friction, visibility), and scenario timing.
    
    cfg = struct();
    
    % Driving Convention: India drives on the LEFT (LHD)
    % Along +x road heading:
    % Left Lane (Ego lane)   : y > 0 (e.g. +1.75m)
    % Right Lane (Oncoming) : y < 0 (e.g. -1.75m)
    cfg.drivingSide = 'LEFT';
    
    % UNIFIED HETEROGENEOUS CLASS ID MAP (Strictly consistent across all modules)
    cfg.classes = struct();
    cfg.classes.CAR         = 1;  % Passenger cars, taxis, hatchbacks
    cfg.classes.TRUCK       = 2;  % Heavy trucks, state transport buses
    cfg.classes.AUTO        = 3;  % Auto-rickshaws (3-wheelers)
    cfg.classes.MOTORCYCLE  = 4;  % Motorcycles, scooters, mopeds
    cfg.classes.BICYCLE     = 5;  % Bicycles, cycle-rickshaws
    cfg.classes.PEDESTRIAN  = 6;  % Pedestrians, children, street vendors
    cfg.classes.CATTLE      = 7;  % Stray cows, bullocks, buffaloes
    cfg.classes.PUSHCART    = 8;  % Wooden pushcarts, agricultural trolleys
    cfg.classes.HAZARD      = 9;  % Potholes, cones, waterlogged patches, barriers
    
    % Standard Dimensions [Length, Width, Height] in meters
    cfg.dimensions = struct();
    cfg.dimensions.CAR         = [4.7, 1.8, 1.5];
    cfg.dimensions.TRUCK       = [10.0, 2.5, 3.4];
    cfg.dimensions.AUTO        = [2.6, 1.4, 1.7];
    cfg.dimensions.MOTORCYCLE  = [2.0, 0.8, 1.4];
    cfg.dimensions.BICYCLE     = [1.8, 0.6, 1.5];
    cfg.dimensions.PEDESTRIAN  = [0.5, 0.5, 1.7];
    cfg.dimensions.CATTLE      = [2.2, 0.9, 1.4];
    cfg.dimensions.PUSHCART    = [2.8, 1.4, 1.8];
    cfg.dimensions.HAZARD      = [1.5, 1.5, 0.5];
    
    % Surface Friction Coefficients (mu)
    cfg.friction = struct();
    cfg.friction.DRY_ASPHALT   = 0.85;
    cfg.friction.WET_ASPHALT   = 0.55;
    cfg.friction.MONSOON_FLOOD = 0.35;
    cfg.friction.UNPAVED_MUD   = 0.40;
    
    % Environmental Visibility & Sensor Range Modifiers
    cfg.environment = struct();
    cfg.environment.DAY_CLEAR = struct('cameraRange', 150, 'lidarRange', 100, 'radarRange', 120);
    cfg.environment.NIGHT_FOG = struct('cameraRange', 15,  'lidarRange', 80,  'radarRange', 110);
    
    % Deterministic Random Seed for reproducible simulation
    cfg.defaultSeed = 42;
    
    % Metric Evaluation Schema
    cfg.metrics = {'minTTC', 'collisions', 'completionRate', 'smoothnessScore', 'replanTime'};
end
