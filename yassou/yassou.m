% function yassou(modelname, rtname, yassou_opt, epicurus_opt, gp_epicurus_opt, state)
function yassou(modelname, modeldatapath, rt_data, yassou_opt, gp_epicurus_opt, state)

% Coming from epicurus.m
% global hFeatures;


%% Prepare Yassou
input_names = {rt_data.inputs.name};
input_types = {rt_data.inputs.type};

% TODO: this is very temporary
input_range = zeros(length(input_types), 2);
for i = 1:length(input_types)
    if strcmpi(input_types{i}, 'Bool')
        input_range(i, :) = [0 1];
    elseif strcmpi(input_types{i}, 'Real')
        input_range(i, :) = [0 50]; % TODO tweak this, based on the case study
    else
        error(['Unknown input type: ', input_types{i}]);
    end
end

% TODO: Will likely need to work with this
init_cond = []; % [0 50;0 50;0 10;0 10;0 50;0 50]; % ANSWER: this is the range of initial value (at t=0) of each input traces

% TODO: this is temp, but will likely stay the same
epicurus_add_to_oplist = input_names;
% error('a');

% NOTE: STALIRO Options - Unsure about these
activeScenarioTS = ''; % TODO: what is this?
property = 'R'; % TODO: what is this?
categorical = []; % TODO: what is this?

policy='UR'; % Standard policy
sim_time=1; % QUESTION: what is this?
learningMethod='GP'; %"GP", "DT"
GPalgorithm='GP'; % 'RS','GP'

% originalqctPath=fullfile(fileparts(which([scriptname,'original.qct'])),[scriptname,'original.qct']);

reqIdToRepair = yassou_opt.reqIdToRepair;
if reqIdToRepair == -1
    % Repair all requirements
    startId = 1;
    endId = length(rt_data.requirements);
else
    % Repair only the requirement of interest
    startId = reqIdToRepair;
    endId = reqIdToRepair;
end

% % OBSOLETE START - Gather RT data from Simulink model
% % Note that all this stuff will likely not be necessary, since we (most probably) no longer need the RTs that are embedded in the simulink model

% % Load model
% load_system(modelname);
% reqPath = modelname + "/" + rtname;
% set_param(reqPath, "Commented","off") % TODO is this nescessary?

% % Extract the requirements table
% [req_table_path, o2] = extractReqTable(modelname, activeScenarioTS, []);
% % disp(req_table_path);
% % disp(o2);
% % error('a');

% % Read RT, store in memory
% [reqTable, symbTable, assTable] = testReadTable(modelname, req_table_path);
% % writetable(reqTable, 'reqTableOutput.csv');
% % disp(reqTable);
% % disp(symbTable);
% % disp(assTable);

% % OBSOLETE END - Gather RT data from Simulink model

%% Prepare the model for simulation

% Load data to complete the model
    % From Federico: I believe that demo.mat contains some parameters
    % needed by the Simulink model, so she is loading all the variables in
    % the base workspace. This should be equivalent to:
    % evalin('base','load("demo.mat");');
cmd = load('-mat', modeldatapath);
vars = fieldnames(cmd);
for i = 1:length(vars)
    assignin('base', vars{i}, cmd.(vars{i}));
end

for i = startId:endId

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % TASK DESCRIPTION

    % INPUT:
    % (1) a MATLAB file, such as /yassou_evaluation/lm_challenges_json/AP_v1.m. 
    % This is manually (LLM-asisted) created from a corresponding .rt file in yassou_evaluation/LM_Challenges_rt/*/

    % MAJOR QUESTIONS:
    % (1) How to integrate preconditions (boolean constraints over the inputs)?
        % From Federico: Look at Q3.
    % (2) How to transform the postcondition into a phi and a set of predicates?
        % ANSWER: this will be done manually for now.
    % (3) How to support systems that have both real and boolean inputs and outputs?
        % From Federico: the quick and dirty answer is that we turn them in two
        % inequalities:
        % a == true ===> (a <= 1) & (a >= 1)
        % Since the equal is always included, these are equivalent and we
        % pretend that the boolean variable is a real variable. Otherwise, it
        % get's a bit harder to make the code run.
    % (4) How to support quadratic requirements?
        % From Federico: Non-linear requirements are not supported by dp-taliro
        % (the main trace-checker for S-Taliro). I believe they should be
        % supported by the Hecate trace checker, but I haven't tested it
        % thoroughly.
    % (5) Where do we get the input bounds (aside from the preconditions)?
        % From Federico: we could assume that the user specifies the input
        % range in the Assumption tab of the Requirements Table. We briefly
        % considered it for Hecate, but then decided against since the Test
        % Sequence block gives more freedom in designing the signals.
    % (6) How to correctly set up the staliro integration (in genTestSuite.m)?
        % From Federico: Is there a specific problem here that you are worried
        % about? The hardest part seems to be converting the requirements, but
        % that should be already handled.

    % TASK:
    % (1) Feed the preconditions, 'phi', 'preds', 'input_bounds', ... into STaliro (see genTestSuite.m)
    % (2) get a set of falsifying and non-falsifying test cases

    %%%%%%%%%%%%%%%%%%%%%%%%%%%



    %% Extract the requirement of interest
    req = rt_data.requirements(i);
    precondition = req.precondition;
    phi = req.phi;
    preds = req.preds;
    % input_bounds = rt_data.input_bounds;

    % phi='<>_[0,100](p1->p2)';
    % preds(1).str='p1';
    % preds(1).A=[1 0];
    % preds(1).b=50;
    % preds(2).str='p2';
    % preds(2).A=[0 1];
    % preds(2).b=50;
    % disp(preds)

    % phi='[]_[0,100](p1)';
    % preds(1).str='p1';
    % preds(1).A=[-1 0];
    % preds(1).b=0;

    % % For 'demo' model
    % phi='<>_[0,100](p1)';
    % % constraints in the form Ax<=b
    % preds(1).str='p1';
    % preds(1).A=[1 0];
    % preds(1).b=50;
    


    %%



end


% Setting the interpolation function: it is either const or pconst
nControlPoints=yassou_opt.nbrControlPoints;
if (nControlPoints==1) 
    interpolation_type='const';
else
    interpolation_type='pconst';
end

numberOfInputs=size(input_names,2); % the number of inputs 
% cp_array: the vector contains the number of control points of each input
cp_array=nControlPoints*ones(1,numberOfInputs);

% categorical and cp_names in terms of control points.
% if nControlPoints==1, then size(cp_names) == size(input_names)
[categorical,cp_names]=getListOfFeatures(categorical,nControlPoints,input_names,cp_array); 
% % the total simulation time in QCT : the total number of steps
% kmax=(sim_time/assume_opt.SampTime);

% Add to operation list
% disp(state.oplist);
for i = 1:length(epicurus_add_to_oplist)
    var_name = epicurus_add_to_oplist{i};
    state.oplist(end+1, :) = state.oplist(end, :); % Shift the last element by one
    state.oplist(end-1, :) = {var_name, [0], {{''}, {''}}, 'aexp'};... % Add to before-last index
end
% disp(state.oplist);
% error('a');

% Setup environment
% TODO: move this much earlier

% [resultfilename, scriptname, algorithmFolder] = prepResultsFolder(modelname,property,policy,GPalgorithm);

%% END TEMP

%% Begin running Yassou
for run=yassou_opt.runsStartId:yassou_opt.runsEndId

    if strcmp(yassou_opt.overallApproach, 'iterative')

        %% Set up the S-Taliro options

        % From epicurus.m
        Oldt=[];
        oldA={};
        bestA={}; % last assumptions
        count=1; % iteration counter
        valid=0; % valid assumption is initialized to false
        hFeatures=[];
        assumption=''; % the best assumption of the GP
        iteration_idx_with_fitness_jumps=[];
        iteration_idx_with_no_fitness_jumps=[];
        disp(['Epicurus run: ',num2str(run)]);
        disp(['Epicurus iteration: ',num2str(count)]);

        % TODO add budget checks

        %% TEST SUITE GEN with some staliro configuration
        staliroTimeTic=tic;
        % TODO MAJOR TASK, see in genTestSuite.m
        % disp(phi);
        % disp(preds);
        % disp(input_names);
        % error('eikfbiedsk')
        testSuite = genTestSuite(modelname,init_cond, phi, preds, sim_time,Oldt,input_range,interpolation_type,cp_array,cp_names,'temp',categorical,count,yassou_opt); % TODO: implement this function
        % disp(testSuite);
        % NOTE: testSuite will contain a list of falsifying test cases 
        staliroTime=toc(staliroTimeTic);

        % Q: Did we find a counterexample?
        % error('Iterative repair approach is not yet implemented.');

        %% FIND REPAIR
        repairTimeTic=tic;
        % TODO MAJOR TASK, see in findRepair.m
        bestRepair = findRepair(modelname, phi, preds, testSuite, yassou_opt);
        repairTime = toc(repairTimeTic);
        error('Completeness check is not yet implemented.');

        %% CHECK COMPLETENESS. FIX IF NOT COMPLETE
        completenessCheckTimeTic=tic;
        % TODO MAJOR TASK, see in checkAndFixCompleteness.m
        completenessCheck = checkAndFixCompleteness(); % TODO: implement this function
        completenessCheckTime=toc(completenessCheckTimeTic);


        % while we have not reached the budget
        % apply repair, regenrate fitness functions


    elseif strcmp(yassou_opt.overallApproach, 'direct')
        error('Direct repair approach is not yet implemented.');
    elseif strcmp(yassou_opt.overallApproach, 'epicurus')
        % TODO: this is working, but needs cleanup
        epicurus(modelname,property,init_cond, phi, preds, sim_time,input_names,categorical,input_range,yassou_opt,gp_epicurus_opt,scriptname,resultfilename,algorithmFolder,state);

    else
        error('Invalid repair approach specified.');


end



% Extract 1 Req from RT


% run EPICURUS on the 1 RT

% disp outcome
% 
end