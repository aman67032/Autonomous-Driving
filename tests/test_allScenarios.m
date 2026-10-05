function test_allScenarios()
    % TEST_ALLSCENARIOS Validates all 10 Indian driving scenarios compile and initialize
    
    scenarioFunctions = {
        @scenario1_village_road,
        @scenario2_urban_intersection,
        @scenario3_highway_merge,
        @scenario4_market_area,
        @scenario5_cattle_crossing,
        @scenario6_wrong_way_traffic,
        @scenario7_monsoon_waterlogging,
        @scenario8_sudden_auto_pickup,
        @scenario9_night_fog_fusion,
        @scenario10_procession_diversion,
        @scenario11_real_delhi_osm_replay
    };
    
    numScenarios = length(scenarioFunctions);
    fprintf('  Testing %d Indian Driving Scenarios initialization...\n', numScenarios);
    
    failCount = 0;
    for i = 1:numScenarios
        fn = scenarioFunctions{i};
        fnName = func2str(fn);
        
        try
            [scenario, egoVehicle] = fn();
            
            assert(~isempty(scenario), sprintf('%s returned empty scenario', fnName));
            assert(~isempty(egoVehicle), sprintf('%s returned empty egoVehicle', fnName));
            assert(length(scenario.Actors) >= 1, sprintf('%s has no actors', fnName));
            
            fprintf('    [Scenario %02d] %-30s -> [PASS] (%d actors, StopTime: %.1fs)\n', ...
                i, fnName, length(scenario.Actors), scenario.StopTime);
        catch ME
            failCount = failCount + 1;
            fprintf('    [Scenario %02d] %-30s -> ❌ [FAIL]: %s\n', i, fnName, ME.message);
        end
    end
    
    if failCount > 0
        error('test_allScenarios:FailedScenarios', '%d of %d scenarios failed initialization.', failCount, numScenarios);
    else
        fprintf('  All %d scenarios verified successfully!\n', numScenarios);
    end
end
