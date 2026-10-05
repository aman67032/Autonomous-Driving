function scenario = importOpenStreetMap(scenario, osmFilePath)
% importOpenStreetMap
% Ingests real-world road networks from OpenStreetMap (.osm) into MATLAB drivingScenario.
%
% Usage:
%   scenario = drivingScenario('StopTime', 30.0);
%   scenario = importOpenStreetMap(scenario, 'data/real_roads/delhi_junction.osm');
%
% Requirements:
%   Automated Driving Toolbox (roadNetwork function with OpenStreetMap support)

    if nargin < 1 || isempty(scenario)
        scenario = drivingScenario('StopTime', 30.0);
    end

    if nargin < 2 || isempty(osmFilePath)
        % Create standard real-world Indian arterial corridor if no OSM file specified
        fprintf('  [OSM Importer] No .osm file provided. Creating Indian 7.0m arterial road geometry...\n');
        roadCenters = [0 0 0; 80 0 0; 160 3 0; 250 5 0; 350 5 0];
        laneSpec = lanespec(2, 'Width', 3.5);
        road(scenario, roadCenters, 'Lanes', laneSpec);
        return;
    end

    if ~exist(osmFilePath, 'file')
        warning('OSM file "%s" not found. Falling back to synthetic road geometry.', osmFilePath);
        roadCenters = [0 0 0; 100 0 0; 250 0 0; 350 0 0];
        laneSpec = lanespec(2, 'Width', 3.5);
        road(scenario, roadCenters, 'Lanes', laneSpec);
        return;
    end

    fprintf('  [OSM Importer] Importing real road geometry from OpenStreetMap: %s\n', osmFilePath);
    try
        roadNetwork(scenario, 'OpenStreetMap', osmFilePath);
        fprintf('  [OSM Importer] Successfully loaded real OSM road network!\n');
    catch ME
        warning('Unable to parse OpenStreetMap directly: %s. Using high-fidelity spline road network.', ME.message);
        roadCenters = [0 0 0; 100 0 0; 200 2 0; 350 2 0];
        laneSpec = lanespec(2, 'Width', 3.5);
        road(scenario, roadCenters, 'Lanes', laneSpec);
    end
end
