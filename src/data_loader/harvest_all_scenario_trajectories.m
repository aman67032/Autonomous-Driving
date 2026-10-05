% harvest_all_scenario_trajectories.m
% Extracts ground-truth dynamic trajectories from ALL 10 Indian driving scenarios
% (+ Scenario 11 Real Delhi OSM) and saves them into a consolidated CSV dataset
% for deep learning training on the GPU.

function harvest_all_scenario_trajectories()
    clc;
    fprintf('=========================================================================\n');
    fprintf('   Harvesting Trajectories Across ALL 10 Scenarios for GPU Training      \n');
    fprintf('=========================================================================\n\n');

    baseDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(fullfile(baseDir, 'config'));
    addpath(fullfile(baseDir, 'scenarios'));
    addpath(fullfile(baseDir, 'src', 'data_loader'));

    scenarioFuncs = {
        @scenario1_village_road,          'Scenario 1: Village Road';
        @scenario2_urban_intersection,    'Scenario 2: Urban Intersection';
        @scenario3_highway_merge,         'Scenario 3: Highway Merge';
        @scenario4_market_area,           'Scenario 4: Market Area';
        @scenario5_cattle_crossing,       'Scenario 5: Cattle Crossing';
        @scenario6_wrong_way_traffic,     'Scenario 6: Wrong-Way Traffic';
        @scenario7_monsoon_waterlogging,  'Scenario 7: Monsoon Waterlogging';
        @scenario8_sudden_auto_pickup,    'Scenario 8: Sudden Auto Pickup';
        @scenario9_night_fog_fusion,      'Scenario 9: Night/Fog Fusion';
        @scenario10_procession_diversion, 'Scenario 10: Procession Diversion';
        @scenario11_real_delhi_osm_replay,'Scenario 11: Real Delhi OSM'
    };

    allRecords = []; % [timestamp, global_agent_id, class_id, x, y, vx, vy, length, width, height, scenario_id]

    globalAgentCounter = 1;

    for sIdx = 1:size(scenarioFuncs, 1)
        fn = scenarioFuncs{sIdx, 1};
        sName = scenarioFuncs{sIdx, 2};
        fprintf('[%02d/11] Simulating & harvesting: %s...\n', sIdx, sName);

        try
            [scenario, egoVehicle] = fn();
        catch ME
            warning('Failed to load %s: %s', sName, ME.message);
            continue;
        end

        dt = scenario.SampleTime;
        actors = scenario.Actors;
        numActors = length(actors);

        % Map each actor to a unique global ID
        actorMap = containers.Map('KeyType', 'double', 'ValueType', 'double');
        for a = 1:numActors
            actorMap(actors(a).ActorID) = globalAgentCounter;
            globalAgentCounter = globalAgentCounter + 1;
        end

        % Advance scenario and log state at each timestep
        while advance(scenario)
            t_curr = scenario.SimulationTime;
            for a = 1:numActors
                act = actors(a);
                if act == egoVehicle, continue; end % Ego is the autonomous agent

                gId = actorMap(act.ActorID);
                cid = act.ClassID;
                pos = act.Position;
                vel = act.Velocity;
                len = act.Length;
                wid = act.Width;
                hgt = act.Height;

                rec = [t_curr, gId, cid, pos(1), pos(2), vel(1), vel(2), len, wid, hgt, sIdx];
                allRecords = [allRecords; rec]; %#ok<AGROW>
            end
        end
    end

    % Convert to table and export
    outCsv = fullfile(baseDir, 'data', 'real_traces', 'all_10_scenarios_harvested.csv');
    T = array2table(allRecords, 'VariableNames', ...
        {'timestamp', 'agent_id', 'class_id', 'x', 'y', 'vx', 'vy', 'length', 'width', 'height', 'scenario_id'});

    writetable(T, outCsv);
    fprintf('\n  ✅ Successfully harvested %d total trajectory timesteps across all 10 scenarios!\n', height(T));
    fprintf('  ✅ Exported consolidated dataset to: %s\n', outCsv);
end
