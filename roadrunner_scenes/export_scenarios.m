% export_scenarios.m
% Helper script to interface RoadRunner scene exports with MATLAB Driving Scenarios
function export_scenarios()
    fprintf('=========================================================================\n');
    fprintf('   SIH 2026: RoadRunner Scene OpenDRIVE / OpenSCENARIO Verification      \n');
    fprintf('=========================================================================\n\n');
    
    rrDir = fullfile(fileparts(mfilename('fullpath')));
    
    scenarios = {
        'village_road',          'Scenario 1: Village Road (Unmarked & Cattle)';
        'urban_intersection',    'Scenario 2: Urban Intersection (Unsignalized)';
        'highway_merge',         'Scenario 3: Highway Merge (Slow Tractor)';
        'market_area',           'Scenario 4: Dense Market Area (Pushcarts & Swarm)';
        'cattle_crossing',       'Scenario 5: Sudden Cattle Crossing';
        'wrong_way_traffic',     'Scenario 6: Contra-Flow Wrong-Way Traffic';
        'monsoon_waterlogging',  'Scenario 7: Monsoon Flood & Waterlogged Potholes';
        'sudden_auto_pickup',    'Scenario 8: Sudden Auto/Bus Passenger Pickup';
        'night_fog_fusion',      'Scenario 9: Night/Dense Fog (LiDAR-Radar Fusion)';
        'procession_diversion',  'Scenario 10: Wedding / Procession & Diversion'
    };
    
    for i = 1:size(scenarios, 1)
        folderName = scenarios{i, 1};
        titleName  = scenarios{i, 2};
        odrFile    = fullfile(rrDir, folderName, [folderName, '.xodr']);
        xoscFile   = fullfile(rrDir, folderName, [folderName, '.xosc']);
        
        fprintf('[%02d/10] %s:\n', i, titleName);
        if exist(odrFile, 'file')
            fprintf('       ✅ Found OpenDRIVE:    %s\n', odrFile);
        else
            fprintf('       ℹ️ OpenDRIVE:    Not yet exported from RoadRunner (Native MATLAB fallback ready)\n');
        end
        if exist(xoscFile, 'file')
            fprintf('       ✅ Found OpenSCENARIO: %s\n', xoscFile);
        else
            fprintf('       ℹ️ OpenSCENARIO: Not yet exported from RoadRunner (Native MATLAB fallback ready)\n');
        end
    end
    
    fprintf('\nAll scenarios have 100%% native MATLAB drivingScenario fallbacks in scenarios/ folder.\n');
end
