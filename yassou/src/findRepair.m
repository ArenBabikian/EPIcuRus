% function [assumptionArray,parent_constraints,interAssum] = genAssum(tv,Olt,oldA,bestA,inputnames,categorical,state,filePath,assume_options,gp_epicurus_options)
function bestRepair = findRepair(modelname, phi, preds, tv, yassou_opt)

    % global staliro_mtlFormula;
    % global staliro_Predicate;
    global staliro_SimulationTime;
    global staliro_InputBounds; % TODO might want to add this to input params
    global temp_ControlPoints;

    % global staliro_dimX;
    global staliro_opt;
    % global staliro_ParameterIndex;
    global staliro_Polarity;
    % global staliro_parameter_list;
    % global staliro_inpRangeUnscaled;
    % global strlCov_locationHistory;

    bestRepair = []; % TODO

    % in Epicurus-GP, an assumption is modeled as an individual of the following form:
    % ind=struct('id',lastid,'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',gp_opt.max_depth,'origin','');

    % Input: rut, test cases + fitness values

    % 1. Get some representation of the requirement-under-test (fixed for a single Yassou run)
    % (hint at 3 here)
    % will be coming directly from preds, since our repair is strucure-presenving

    % WIP
    % represented as multipliers for
    % [preds(1).A(1), preds(1).A(2), ..., preds(1).A(n), preds(1).b,
    % preds(2).A(1), preds(2).A(2), ..., preds(2).A(m), preds(2).b,
    % ...]
    % preds(4).A(1), preds(4).A(2), ..., preds(4).A(p), preds(n).b]

    % Compute the required size of indiv based on preds
    indiv_size = 0;
    for j = 1:length(preds)
        if isfield(preds(j), 'A')
            indiv_size = indiv_size + length(preds(j).A);
        end
        if isfield(preds(j), 'b')
            indiv_size = indiv_size + 1;
        end
    end
    
    % TEMP: this is a dummy individual
    
    % indiv = [0.99 0.98 0.97 0.92 ...
    %         1.5 0.99 1 1.2]; % comes from preds
    indiv = [0.99 0.98 0.97]; % comes from preds

    consider_n_rows = size(tv,1);
    consider_n_rows = 10; % TEMP

    all_tc_fit_compliance = zeros(1, consider_n_rows);
    all_tc_fit_size = zeros(1, consider_n_rows);

    for i = 1:consider_n_rows

        %% Prep Data
        data = tv(i,1:end-1);
        ts_fitness = tv(i,end);

        % TODO: if there are init_cond, need to modify this
        % check Compute_Robustness_Right.m:37 for inspiration
        XPoint = []; % initial conditions
        UPoint = data; % control points for this test case

        %% Run Simulation
        % TODO if trace is precomputed, don't rerun the sim
        [hs, rc] = systemsimulator(modelname, XPoint, UPoint, staliro_SimulationTime, staliro_InputBounds, temp_ControlPoints);

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

        %% Given an individual, update requirement-under-test

        % phi='<>_[0,100](p1->p2)';
        % preds(1).str='p1';
        % preds(1).A=[10 10 10];
        % preds(1).b=100;
        % preds(2).str='p2';
        % preds(2).A=[10 10 10];
        % preds(2).b=50;

        % disp(preds);

        new_phi = phi;
        new_preds = preds;
        % disp('Contents of preds:');
        % for idx = 1:length(preds)
        %     disp(['Predicate ', num2str(idx), ':']);
        %     disp(preds(idx));
        % end

        %% Update the preds acording to the individual
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

        %% Determine the new COMPLIANCE fitness value of the repair
        
        % check Compute_Robustness_Right.m:142 for generalisation
        cost = feval(staliro_opt.taliro, new_phi, new_preds, STraj,T);

        % Corner case handling:
        if isa(cost, 'hydis')
            error('Not implemented. check Compute_Robustness_Right.m:195');
        end
        
        % Corner case handling: paramter estimation
        if ~isempty(staliro_Polarity)
            error('Not implemented. check Compute_Robustness_Right.m:195');
        end

        % This is a quick solution. Think about this more carefully
        TC_FIT_COMPLIANCE = cost-ts_fitness; % Improvement in fitness
        all_tc_fit_compliance(i) = TC_FIT_COMPLIANCE;

        %% Determine the SIZE fitness value of the repair

        % This is a quick solution. Think about this more carefully
        TC_FIT_SIZE = sum(abs(1 - indiv));
        all_tc_fit_size(i) = TC_FIT_SIZE;


        %% Determine overall fitness value of the repair
        TC_FITNESS = TC_FIT_COMPLIANCE + TC_FIT_SIZE;
        
        % disp(TC_FIT_COMPLIANCE);
        % disp(ts_fitness)

        %% TODO: do some aggregation over all the TCs

    end


    


    % % if ~isempty(categorical) % if the categorical is set , make sure the inputs are booleans 
    % %     data(:,categorical)=double(data>=0.5);
    % % end
    %  % ts_inputs contains the input values of the test cases in TS
    %  % Convert the data into a 3D array which contains:
    %  % dimension 1- test cases
    %  % dimension 2- the model inputs
    %  % dimension 3- the control point values
    %  cp_data=[];
    %  for c=1:yassou_opt.nbrControlPoints
    %      cp_data=[cp_data,data(:,c:yassou_opt.nbrControlPoints:end)];
    %  end

    % % Compute robustness for each entry in data
    % robustness = zeros(size(data,1),1);
    % for i = 1:size(data,1)
    %     % NOTE: model_type may be unnecessary, if we are not re-simulating everything
    %     model_type = determine_model_type(modelname);
    %     [a b c d] = Compute_Robustness_Right(modelname, model_type, data(i,:));
    %     % disp([a b c d])
    %     robustness(i) = a;
    %     assert(a == ts_fitness(i), 'Robustness value does not match expected fitness at index %d.', i);
    % end


    % individual (cp vals)
    % 

    % maybe run it one time, then save the hs?



    
    % 4. Define the fitness function (given rut, repair, test case execution trace).
    % Fitness function considers
    % (1) SIZE size of repair,
    % (2) COMPLIANCE how wll does the repair actually repair the rut
    % all this  aggregated over the set of test cases given as input


    
    % 4. Given the repair individual, and its application to the requirement-under-test, how to determine 


    


