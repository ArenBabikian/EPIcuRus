function runyassou(casestudyid)

%% Set up the Environment

close all;
clearvars -except casestudyid;
addpath(genpath("C:\git\EPIcuRus"));
cd('C:\git\EPIcuRus');

%% Get case study

modelsFolder = "yassou_evaluation/lm_challenges/original_models";
% RTsFolder = "yassou_evaluation\LM_Challenges_rt";
% dataFolder = "yassou_evaluation\lm_challenges_json";

switch casestudyid
    case 'demo'
        model = 'demo';
        modelDataPath = fullfile('EpicurusMain/Tutorial/demo.mat');
        rt_file = "demo_v1";
    case 'NN'
        % model = modelsFolder + "\FRET_CoCoSim\7_autopilot\ap_12B.slx";
        model = 'nn_12B';
        modelDataPath = fullfile(modelsFolder, '5_nn', [model '_data.mat']);
        rt_file = "NN_v1";
    otherwise
        error('Unknown case study ID');
end

rt_data = feval(rt_file);

disp('##################################################');
disp(['Running Yassou on the ', casestudyid, ' case study'])
disp('##################################################');

%% Set up Yassou options
% TODO

yassou_opt = yassou_options();

% Approach config
yassou_opt.overallApproach = 'iterative'; % 'iterative' | 'direct' | 'epicurus'
yassou_opt.repairMethod = 'todo';
yassou_opt.reqIdToRepair = 1; % ID of the requirement to repair. If -1, repair all of them

% Run Config options
yassou_opt.runsStartId = 1; % Start ID for runs
yassou_opt.runsEndId = 2;   % End ID for runs

% staliro calling options
yassou_opt.policy='UR'; % staliro optimization policy; UR | ART | IFBT_UR | IFBT_ART
yassou_opt.nbrControlPoints=1;

yassou_opt.runs=1; % number of staliro iterations. This is hard-coded to 1 in [genSuite.m:168]
yassou_opt.testSuiteSize=100; % number of test cases per staliro iteration (defaults to larger of the 2)
yassou_opt.iteration1Size=100; % number of test cases in the first iteration (defaults to larger of the 2)



% staliro native options
yassou_opt.dispinfo=100;
yassou_opt.SampTime=0.01;
yassou_opt.ode_solver='ode3'; % ode solver

%% Set up Epicurus options
% TODO

% TODO manage common options between Yassou and Epicurus.
% Basically, the staliro stuff

% Creates the options of EPIcuRus. Further details are described under
% extends staliro_options
% epicurus_options.m



% EPICURUS options
yassou_opt.assumeIterations= 10; % number of iterations
yassou_opt.assumeStartRun=1; % see below
yassou_opt.assumeEndRun=1; % Set number of Epicurus runs in total

% Within each Epicurus Run...

% staliro options

% if learning method == "DT"

% Assumption generation options
yassou_opt.writeInternalAssumptions=1; % write assumptions to file
yassou_opt.desiredFitness=0;
yassou_opt.exploit=0;
yassou_opt.epsilon=10;
yassou_opt.qvtraceenabled=false;
yassou_opt.learningMethod='DT'; %"GP", "DT"

% ARCHIVE. For when i was running with HECATE examples
% if ~strcmp(model, 'demo')
    % yassou_opt.SimulinkSingleOutput=1;
% end

%% Set up GP options

% Set up GP state
state.lastid=0;
state.init=1;
% Specifies if the assumption contains disjunctions
state.disjunctionsExist=1;
state.depthnodes='1';
state.isboolean=0;
% Specifies the list of GP operators
state.oplist={...
            'plus',[2],{{'aexp'},{'aexp'}},'aexp';...
            'minus',[2],{{'aexp'},{'aexp'}},'aexp';...
            'times',[2],{{'aexp'},{'aexp'}},'aexp';...
            'le',[2],{{'aexp'},{'0'}},'conjunction';...
            'ge',[2],{{'aexp'},{'0'}},'conjunction';...
            'and',[2],{{'conjunction'},{'conjunction'}},'conjunction';...
            'or',[2],{{'disjunction','conjunction'},{'disjunction','conjunction'}},'disjunction';...
            '0',[0],{{''},{''}},'0'};
            
            % 'rollCmd_',[0],{{''},{''}},'aexp'; ...
            % 'yawCmd',[0],{{''},{''}},'aexp';...
            % 'beta_deg',[0],{{''},{''}},'aexp'; ...
            % 'vtas_kts',[0],{{''},{''}},'aexp';...


% Creates the GP options. Further details are described under
% gp_epicurus_options.m
gp_epicurus_opt=gp_epicurus_options();
gp_epicurus_opt.gen_size=250;
gp_epicurus_opt.pop_size=50;
gp_epicurus_opt.max_depth=5;
gp_epicurus_opt.maxNbrConj=4;
gp_epicurus_opt.maxNbrDisj=3;
gp_epicurus_opt.sel_crt='tournamentSelection';
gp_epicurus_opt.t_size=7;
gp_epicurus_opt.init_Ratio=0.5;
gp_epicurus_opt.algorithm='RS'; % 'RS','GP'

%% Set up QVTrace options

% Loading the model in QVtrace if enabled
% Make sure to write 'Matlab' into the turn.txt
% cd ..;
if  yassou_opt.qvtraceenabled==1
    modelPath=fullfile(fileparts(which([model,'qv.mdl'])),[model,'qv.mdl']);
    matPath=fullfile(fileparts(which([model,'.mat'])),[model,'.mat']);
    copyfile(modelPath,'./model.mdl');
    copyfile(matPath,'./model.mat');
    turn='LoadModel';
    turnfile=fopen('turn.txt', 'w'); 
    fprintf(turnfile,turn); 
    fclose(turnfile);
    disp('Waiting that QVtrace loads the model');
    while(~strcmp(turn,'Matlab'))
        pause(1)
        turnfile=fopen('turn.txt', 'r'); 
        turn=fgetl(turnfile); 
        fclose(turnfile);
    end
    disp('Model loaded');
end

%% Run Yassou
yassou(model, modelDataPath, rt_data, yassou_opt, gp_epicurus_opt, state);
% epicurus(model,property,init_cond, phi, preds, sim_time,input_names,categorical,input_range,epicurus_opt,gp_epicurus_opt,scriptname,resultfilename,algorithmFolder,state);
disp('############################################################################');
disp(['Yassou finished running and results are saved under: ',algorithmFolder]);
disp('############################################################################');

% % TODO get this from RT
% % Defines of the requirement of interest.
% phi='<>_[0,100](p1)';
% preds(1).str='p1';
% preds(1).A=[1 0];
% preds(1).b=50;

% if demo == 0 || demo == 1
%     cmd = load('-mat', 'demo.mat');
%     vars = fieldnames(cmd);
%     for i = 1:length(vars)
%         assignin('base', vars{i}, cmd.(vars{i}));
%     end
% end

% Extract 1 Req from RT


% run EPICURUS on the 1 RT

% disp outcome
%