% function [assumptionArray,parent_constraints,interAssum] = genAssum(tv,Olt,oldA,bestA,inputnames,categorical,state,filePath,assume_options,gp_epicurus_options)
function bestRepair = findRepair(modelname, phi, preds, tv, yassou_opt)

    % global staliro_SimulationTime;
    % global staliro_InputBounds; % TODO might want to add this to input params
    % global temp_ControlPoints;

    % % global staliro_dimX;
    % global staliro_opt;
    % % global staliro_ParameterIndex;
    % global staliro_Polarity;
    % % global staliro_parameter_list;
    % % global staliro_inpRangeUnscaled;
    % % global strlCov_locationHistory;

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
    % disp(['Size of indiv: ', num2str(indiv_size)]);

    % TESTING
    if false
        % TEMP: this is a dummy individual
        % indiv = [0.99 0.98 0.97 0.92 ...
        %         1.5 0.99 1 1.2]; % comes from preds
        indiv = [0.46074     0.96466]; % comes from preds

        consider_n_rows = size(tv,1);
        % consider_n_rows = 10; % TEMP
        tv = tv(1:consider_n_rows, :);
        [fit_compliance, fit_size] = get_repair_heuristic(modelname, indiv, tv, phi, preds)
        fit_global = get_global_heuristic(modelname, indiv, tv, phi, preds)
        error('kdhfbkejfbc')
    end

    %% GENETIC ALGORITHM

    % Set up genetic algorithm parameters
    nvars = indiv_size;
    lb = 0.1 * ones(1, nvars);
    ub = 1.9 * ones(1, nvars);

    function fit_global = get_global_heuristic(modelname, indiv, tv, phi, preds)
        [fit_compliance, fit_size] = get_repair_heuristic(modelname, indiv, tv, phi, preds);
        % This is a quick solution. Think about this more carefully
        if fit_compliance > 0
            fit_global = fit_compliance;
        else
            fit_global = -1/fit_size;
        end
    end

    % Define the fitness function for the GA
    fitnessFcn = @(indiv) get_global_heuristic(modelname, indiv, tv, phi, preds);

    % Set GA options with verbose output
    ga_opts = optimoptions('ga', ...
        'Display', 'iter', ... % Verbose output
        'MaxGenerations', 5, ...
        'PopulationSize', 30);

    % Run the genetic algorithm
    [bestRepair, ~] = ga(fitnessFcn, nvars, [], [], [], [], lb, ub, [], ga_opts);

    disp(['Best repair found: ', num2str(bestRepair)]);


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

end

