function [agg_fit_compliance, fit_size] = get_repair_heuristic(modelname, indiv, tv, phi, preds)

    % global staliro_mtlFormula;
    % global staliro_Predicate;
    global staliro_SimulationTime;
    global staliro_InputBounds; % TODO might want to add this to input params
    global temp_ControlPoints;
    
    global staliro_opt;
    global staliro_Polarity;
    
    all_fit_compliance = zeros(1, size(tv, 1));

    %% Given an individual, update requirement-under-test

    new_phi = phi;
    new_preds = preds;
    % disp('Contents of preds:');
    % for idx = 1:length(preds)
    %     disp(['Predicate ', num2str(idx), ':']);
    %     disp(preds(idx));
    % end
    
    start_ind = 1;
    for j = 1:length(preds)
        if isfield(new_preds(j), 'A')
            n = length(new_preds(j).A);
            new_preds(j).A = new_preds(j).A .* indiv(start_ind:start_ind+n-1);
            start_ind = start_ind + n; % Remove used elements
        end
        if isfield(new_preds(j), 'b')
            new_preds(j).b = new_preds(j).b * indiv(start_ind);
            start_ind = start_ind + 1;
        end
    end

    % disp('Contents of new_preds:');
    % for idx = 1:length(preds)
    %     disp(['Predicate ', num2str(idx), ':']);
    %     disp(new_preds(idx));
    % end
    % error('yaba')

    %% Run the simulation for each test case

    for i = 1:size(tv, 1)

        %% Prep Data
        data = tv(i,1:end-1);
        ts_fitness = tv(i,end); % ONLY FOR PRINING

        % TODO: if there are init_cond, need to modify this
        % check Compute_Robustness_Right.m:37 for inspiration
        XPoint = []; % initial conditions
        UPoint = data; % control points for this test case

        %% Run Simulation or Load Precomputed Trace
        % NOTE: this is a quick solution. Think about this more carefullys
        % TODO do this withoutan external file?
        save_filename = sprintf('yassou_evaluation/temp/hs_%d.mat', i);
        if exist(save_filename, 'file')
            loaded_data = load(save_filename, 'hs');
            hs = loaded_data.hs;
            rc = []; % rc is not used later, set as empty
        else
            [hs, rc] = systemsimulator(modelname, XPoint, UPoint, staliro_SimulationTime, staliro_InputBounds, temp_ControlPoints);
            save(save_filename, 'hs');
        end

        % NOTE: see Compute_Robustness_Right.m:75 for correct handling of the simulation data
        T = hs.T; % time stamps of simulated trajectory
        if ~isempty(hs.STraj)
            STraj = hs.STraj; % output trajectory
        elseif ~isempty(hs.XT)
            STraj = hs.XT;
        elseif ~isempty(hs.YT)
            STraj = hs.YT;
        else
            error('No output trajectory found.');
        end

        if ~isempty(staliro_opt.dim_proj)
            STraj = STraj(:,staliro_opt.dim_proj);
        end

        if staliro_opt.taliro_undersampling_factor ~= 1
            STraj = STraj(1:staliro_opt.taliro_undersampling_factor:end,:);
            T = T(1:staliro_opt.taliro_undersampling_factor:end,:);
        end

        %% Determine the new COMPLIANCE fitness value of the repair
        
        % check Compute_Robustness_Right.m:142 for generalisation
        cost = feval(staliro_opt.taliro, new_phi, new_preds, STraj,T);
        % fprintf('Test case: prev_cost=%.4f, curr_cost=%.4f\n', ts_fitness, cost);

        % Corner case handling:
        if isa(cost, 'hydis')
            error('Not implemented. check Compute_Robustness_Right.m:195');
        end
        
        % Corner case handling: paramter estimation
        if ~isempty(staliro_Polarity)
            error('Not implemented. check Compute_Robustness_Right.m:195');
        end

        % This is a quick solution. Think about this more carefully
        % TC_FIT_COMPLIANCE = cost-ts_fitness; % Improvement in fitness

        % NOTE: negative cost means falsified. We want positive
        if cost > 0
            tc_fit_compliance = 0;
        else
            tc_fit_compliance = -cost;
        end
        % disp(tc_fit_compliance)

        % Add it to the list of fitness values
        % this is a quick solution. Think about this more carefully
        all_fit_compliance(i) = tc_fit_compliance;

    end
    % disp('Contents of all_fit_compliance:');
    % for idx = 1:length(all_fit_compliance)
    %     if all_fit_compliance(idx) < 0
    %         disp(['Test case ', num2str(idx), ':']);
    %         disp(all_fit_compliance(idx));
    %     end
    % end

    % Aggregate the COMPLIANCE fitness values
    agg_fit_compliance = sum(all_fit_compliance);

    %% Determine the SIZE fitness value of the repair
    % This is a quick solution. Think about this more carefully
    fit_size = sum(abs(1 - indiv));
end