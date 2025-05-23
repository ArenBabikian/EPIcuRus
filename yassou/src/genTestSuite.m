% function genTestSuite(modelname, pre_phi, pre_preds, post_phi, post_preds, input_range)
function tv = genTestSuite(model, init_cond, rt_data, sim_time, Oldt, input_range, cp_array, controlPointNames, categorical, count, yasou_opt)
% This function generates the test suite (ToDo: specify what a test suite
% is exactly) for the requirement under consideration.
% A test suite is a set of test cases and the corresponding results from
% the test oracle.

% Questions:
    % 1 - What is Oldt? It is hardcoded to be an empty variable, so do we
    % actually need it? Can't we remove it?
    % Same count which is hardcoded to 1.
    % 2 - categorical is also an empty variable, but it can be changed by
    % the function DTutils/getListOfFeatures.

    % >> Federico: What is this part doing? Why are we loading and saving a
    % test suite? If we use S-Taliro, then we don't actually need all of
    % this.
    % TS_loadpath = yasou_opt.testSuiteLoadPath;
    % TS_savepath = yasou_opt.testSuiteSavePath;
    % if ~isempty(TS_loadpath)
    %     if exist(TS_loadpath, 'file')
    %         load(TS_loadpath, 'tv');
    %         disp(['Loaded test suite from ', TS_loadpath]);
    %         return;
    %     elseif strcmp(TS_loadpath, TS_savepath)
    %         warning('Loading and saving test suite from the same path. This may overwrite the saved test suite.');
    %     else
    %         error('Tried to load test suite from %s, but file does not exist.', TS_loadpath);
    %     end
    % end

    %% Define options field for S-Taliro

    % Define optimization algorithm for S-Taliro
    switch yasou_opt.policy
        case 'UR'
            yasou_opt.optimization_solver = 'UR_Taliro'; 
        case 'ART'     
            yasou_opt.optimization_solver = 'AR_Taliro';
        case 'IFBT_ART'  
            yasou_opt.optimization_solver = 'IFBT_ART';
        case 'IFBT_UR'  
            yasou_opt.optimization_solver = 'IFBT_UR';
        otherwise    % uniform random by default
            error('Unknown policy'); 
            % optimization_solver = 'UR_Taliro';
    end

    % Set the search mode to minimization (the search process does not stop
    % after finding a failure-revealing test case).
    yasou_opt.falsification = 0;

    % Define interpolation function for input signals. Currently it is
    % either constant (const) or piecewise constant (pconst) signals.
    interpolationTemp = cell(length(cp_array),1);
    for ii = 1:length(interpolationTemp)
        if cp_array(ii) == 1
            interpolationTemp{ii} = 'const';
        else
            interpolationTemp{ii} = 'pconst';
        end
    end
    yasou_opt.interpolationtype = interpolationTemp;

    % Setting the number of iterations (we recommend a minimum value of 30
    % test cases)
    % NOTE: Remember to set the n_tests always after choosing
    % the optimization_solver.
    if yasou_opt.testSuiteSize < yasou_opt.iteration1Size
        yasou_opt.optim_params.n_tests=yasou_opt.iteration1Size;
    else
        yasou_opt.optim_params.n_tests=yasou_opt.testSuiteSize;
    end

    % Perform a single run of S-Taliro
    yasou_opt.runs=1;

    % Display message when S-Taliro starts
    disp("Setting S-Taliro with " + yasou_opt.optimization_solver);
    disp("Running S-Taliro");

    %% Create requirements in S-Taliro format
    
    % Define requirement by concatenating (conjunction) all the requirement
    % rows.
    phi = strcat('(',join({rt_data.requirements.phi},') /\ ('),')');
    phi = phi{1};

    % Define atomic predicates.
    preds = [];
    for ii = 1:length(rt_data.requirements)
        preds = [preds, rt_data.requirements(ii).preds];
    end

    % Check that the A field of the preds variable has length equal to
    % n_inputs (preconditions) + n_outputs (postconditions).
    % if length(preds(1).A) ~= length(rt_data.inputs) + length(rt_data.outputs)
    %     error("The A field of the atomic predicates does not match the expected length." + ...
    %         "Make sure that A has as many elements as the input and output signals.")
    % end

    %% Running Staliro

    % Execute S-Taliro
    [~, history, ~] = staliro(model, init_cond, input_range, cp_array,  phi, preds, ...
        sim_time, yasou_opt, Oldt, controlPointNames, categorical, count);

    % Extract all generated samples and related robustness values.
    % NOTE: results returns the best overall.
    % NOTE: history returns the result of each iteration.
    samples = vertcat(history.samples);
    robustness = vertcat(history.rob);
    tv = [samples robustness];
    
    % Delete Simulink cache file
    delete(model + ".slxc");

    % Check if the test falsifies the property
    if any(robustness <= 0)
        disp("Requirements falsified by at least one test case.")
    else
        disp("None of the test cases falsified one of the requirements.")
    end

    % Save or return the falsifying tests
    TS_savepath = yasou_opt.testSuiteSavePath;
    if ~isempty(TS_savepath)
        save(TS_savepath, 'tv');
        disp("Test suite saved to " + TS_savepath);
    end

end 