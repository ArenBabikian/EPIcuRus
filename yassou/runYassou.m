function runYassou(model)

%% Setup the environment

% Clean up
% setenv('PATH', '/Library/Frameworks/Python.framework/Versions/3.7/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/TeX/texbin:/opt/X11/bin')
close all;
% clear;
% addpath(genpath("C:\git\EPIcuRus"));
addpath(genpath("staliro"))
addpath(genpath("yassou"))
addpath(genpath("EpicurusMain"))
addpath("DTutils")
% cd('C:\git\EPIcuRus');


% Default values for parameters
if nargin < 1 || isempty(model), model = 'Observer_mode_model9'; end
reqTable = "EpicurusMain" + filesep + "Tutorial" + filesep + "demo.mat";

% % Define folder name based on model name
% if strcmp(modelname, 'demo')
%     folder = 'Demo';
% elseif startsWith(modelname, 'Observer_mode_model')
%     folder = 'OMM';
% elseif strcmp(modelname, 'CCModel')
%     folder = 'CC';
% elseif strcmp(modelname, 'Autotrans_shift')
%     folder = 'AT';
% elseif strcmp(modelname, 'stc')
%     folder = 'RunningExample';
% else
%     error('Model not recognized.')
% end

disp('##################################################');
disp(['Running Yassou on the model ', model, '.slx'])
disp('##################################################');

%% Set up the environment parameters
% TODO : Clean up

%% Set up Yassou options

yassou_opt = yassou_options();
yassou_opt.runsStartId = 1; % Start ID for runs
yassou_opt.runsEndId = 2;   % End ID for runs

yassou_opt.overallApproach = 'iterative'; % 'iterative' | 'direct' | 'epicurus'
yassou_opt.repairMethod = 'todo';
yassou_opt.nbrControlPoints=1;

%% Set up Epicurus options

% TODO manage common options between Yassou and Epicurus.
% Basically, the staliro stuff


% Creates the options of EPIcuRus. Further details are described under
% extends staliro_options
% epicurus_options.m
epicurus_opt=epicurus_options();

epicurus_opt.dispinfo=100;

epicurus_opt.SampTime=0.01;

% EPICURUS options
epicurus_opt.assumeIterations= 10; % number of iterations
epicurus_opt.assumeStartRun=1; % see below
epicurus_opt.assumeEndRun=1; % Set number of Epicurus runs in total

% Within each Epicurus Run...
epicurus_opt.runs=1; % number of staliro iterations. This is hard-coded to 1 in [genSuite.m:168]
epicurus_opt.testSuiteSize=30; % number of test cases per staliro iteration (defaults to larger of the 2)
epicurus_opt.iteration1Size=30; % number of test cases in the first iteration (defaults to larger of the 2)

% staliro options
epicurus_opt.policy='UR'; % staliro optimization policy

% if learning method == "DT"

% Assumption generation options
epicurus_opt.writeInternalAssumptions=1; % write assumptions to file
epicurus_opt.nbrControlPoints=yassou_opt.nbrControlPoints;
epicurus_opt.desiredFitness=0;
epicurus_opt.exploit=0;
epicurus_opt.epsilon=10;
epicurus_opt.qvtraceenabled=false;
epicurus_opt.learningMethod='DT'; %"GP", "DT"

if ~strcmp(model, 'demo')
    epicurus_opt.SimulinkSingleOutput=1;
end

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
if  epicurus_opt.qvtraceenabled==1
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

% Load requirements from .m file
reqFile = "demo_v1";
reqPath = "yassou_evaluation" + filesep + "lm_challenges_json";
addpath(reqPath)
eval(sprintf("reqStruct = %s;",reqFile))

%% Run Yassou
yassou(model, reqTable, reqStruct, yassou_opt, gp_epicurus_opt, state);
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