function yassou(modelname, rtname, yassou_opt, epicurus_opt, gp_epicurus_opt, state)

    
% Coming from epicurus.m
global hFeatures;


%% Handle the Requirements Table

activeScenarioTS = ''; % TODO: probably delete this

% Temp
if strcmp(modelname, 'demo')
% This is Temp 
    % TODO Replace phi and preds, maybe even input_bounds, with the ones from the RT, then also replace them in the code below
    % Defines of the requirement of interest.
    % constraint is over the output, so we need A to have as many entries as there are outputs
    phi='<>_[0,100](p1)';
    % constraints in the form Ax<=b
    preds(1).str='p1';
    preds(1).A=[1 0];
    preds(1).b=50;

    % WHY IS GAALOUL DOING THIS?
    % From Federico: I believe that demo.mat contains some parameters
    % needed by the Simulink model, so she is loading all the variables in
    % the base workspace. This should be equivalent to:
    % evalin('base','load("demo.mat");');
    if ~strcmp(modelname, '')
        cmd = load('-mat', 'demo.mat');
        vars = fieldnames(cmd);
        for i = 1:length(vars)
            assignin('base', vars{i}, cmd.(vars{i}));
        end
    end

    % disp(cmd);
else

% TEMP START
% Note that all this stuff will likely not be necessary, since we (most probably) no longer need the RTs that are embedded in the simulink model

% Load model
load_system(modelname);
reqPath = modelname + "/" + rtname;
set_param(reqPath, "Commented","off") % TODO is this nescessary?

% Extract the requirements table
[req_table_path, o2] = extractReqTable(modelname, activeScenarioTS, []);
% disp(req_table_path);
% disp(o2);
% error('a');

% Read RT, store in memory
[reqTable, symbTable, assTable] = testReadTable(modelname, req_table_path);
% writetable(reqTable, 'reqTableOutput.csv');
% disp(reqTable);
% disp(symbTable);
% disp(assTable);

% TEMP END

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

% TEMPORAY: Done manually for now

% phi='<>_[0,100](p1->p2)';
% preds(1).str='p1';
% preds(1).A=[1 0];
% preds(1).b=50;
% preds(2).str='p2';
% preds(2).A=[0 1];
% preds(2).b=50;
% disp(preds)

phi='[]_[0,100](p1)';
preds(1).str='p1';
preds(1).A=[-1 0];
preds(1).b=0;

end

%% TEMP

% coming from tutorial.m
if strcmp(modelname, 'demo')
    % Load the model and the requirement of interest
    property='R'; % QUESTION: what is this?
                    % From Federico: Not entirely sure, but it seems it is
                    % used only to define the file names and print strings.
    input_names={'rollCmd_','yawCmd', 'beta_deg', 'vtas_kts','roll','yaw'};
    % input_names={};
    categorical=[]; % QUESTION: what is this?
    input_range=[0 50;0 50;0 10;0 10;0 50;0 50];
    add_vars_to_oplist = {'rollCmd_','yawCmd', 'beta_deg', 'vtas_kts'};
else
    % Load the model and the requirement of interest
    property='R';
    input_names={'u1', 'u2'}; % hard-coded for now
    % input_names={};
    categorical=[];
    input_range=[0 100;0 100]; % unsure
    add_vars_to_oplist = {'u1', 'u2'};
    % input_names={'Hecate_u1','Hecate_u2','Hecate_u3','Hecate_u4'};
    % input_range=[-2 5;-2 5;-2 5;-2 5];
end

% Coming from tutorial.m
policy='UR'; % Standard policy
% init_cond = [0 50;0 50;0 10;0 10;0 50;0 50]; % ANSWER: this is the range of initial value (at t=0) of each input traces
init_cond = [];
sim_time=1; % QUESTION: what is this?
            % This should be the simulation time for Simulink in seconds.
            % The demo model will be run only for the timesteps between 0s
            % and 1s.
learningMethod='GP'; %"GP", "DT"
GPalgorithm='GP'; % 'RS','GP'

% Coming from epicurus.m, modified slightly
% TODO adjsut below
yassou_results(yassou_opt.runsEndId) = struct( ...
    'repair', '', ...
    'isValid', [], ...
    'executiontime', [], ...
    'iteration', [] ...
);
% originalqctPath=fullfile(fileparts(which([scriptname,'original.qct'])),[scriptname,'original.qct']);

% Setting the interpolation function: it is either const or pconst
nControlPoints=epicurus_opt.nbrControlPoints;
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
for i = 1:length(add_vars_to_oplist)
    var_name = add_vars_to_oplist{i};
    state.oplist(end+1, :) = state.oplist(end, :); % Shift the last element by one
    state.oplist(end-1, :) = {var_name, [0], {{''}, {''}}, 'aexp'};... % Add to before-last index
end
% disp(state.oplist);
% error('a');

% Setup environment
% TODO: move this much earlier

[resultfilename, scriptname, algorithmFolder] = prepResultsFolder(modelname,property,policy,GPalgorithm);

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
        testSuite = genTestSuite(modelname,init_cond, phi, preds, sim_time,Oldt,input_range,interpolation_type,cp_array,cp_names,'temp',categorical,count,epicurus_opt); % TODO: implement this function
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
        epicurus(modelname,property,init_cond, phi, preds, sim_time,input_names,categorical,input_range,epicurus_opt,gp_epicurus_opt,scriptname,resultfilename,algorithmFolder,state);

    else
        error('Invalid repair approach specified.');


end



% Extract 1 Req from RT


% run EPICURUS on the 1 RT

% disp outcome
% 
end