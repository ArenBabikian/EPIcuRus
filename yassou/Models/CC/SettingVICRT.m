% This script is used to define all the variables needed to run the CC
% benchmark on Hecate
addpath_vicrt_19;

% Call the global variables
global init_cond;
global simulationTime;
global model_num;

% Choose the model
if model_num == 0
    model = 'CCModel_61';
elseif model_num == 1
    model = 'CCModel_62';
elseif model_num == 2
    model = 'CCModel_71';
elseif model_num == 3 || model_num == 4 || model_num == 5
    model = 'CCModel_73';
end

%Input ranges:
%Steering angle: -700, 700
%Throttle: 0, 100
%Brake: 0, 100

% Hecate parameters
    % Original and Modified range: [30, 40]
input_param(1).Name = 'Hecate_Transition1';
input_param(1).LowerBound = 30;
input_param(1).UpperBound = 40;

    % Original and Modified range: [0, 20]
input_param(2).Name = 'Hecate_Transition2';
input_param(2).LowerBound = 0;
input_param(2).UpperBound = 20;

    % Original range: [120, 150]
    % Modified range: [100, 150]
input_param(3).Name = 'Hecate_desVel1';
input_param(3).LowerBound = 100;
input_param(3).UpperBound = 150;

    % Original range: [120, 150]
    % Modified range: [100, 150]
input_param(4).Name = 'Hecate_desVel2';
input_param(4).LowerBound = 100;
input_param(4).UpperBound = 150;

    % Original and Modified range: [0, 20]
input_param(5).Name = 'Hecate_desVel3';
input_param(5).LowerBound = 120;
input_param(5).UpperBound = 150;

    % Original range: [-4, 4]
    % Modified range: [-2.5, 2.5]
input_param(6).Name = 'Hecate_slope';
input_param(6).LowerBound = -2.5;
input_param(6).UpperBound = 2.5;

    % Original and Modified range: [-1, 1]
input_param(7).Name = 'Hecate_verShift';
input_param(7).LowerBound = -1;
input_param(7).UpperBound = 1;

    % Original and Modified range: [30, 200]
input_param(8).Name = 'Hecate_period';
input_param(8).LowerBound = 30;
input_param(8).UpperBound = 200;

    % Original and Modified range: [0, pi]
input_param(9).Name = 'Hecate_horShift';
input_param(9).LowerBound = 0;
input_param(9).UpperBound = pi;

% Name of active scenarios
% activeScenarioTA = 'Func';
if model_num <= 3
    activeScenarioTS = 'TS4';
elseif model_num == 4
    activeScenarioTS = 'TS5';
elseif model_num == 5
    activeScenarioTS = 'TS6';
else
    error("Invalid Requirements Table version number. Select an integer between 0 and 5.")
end

% Define options
staliro_opt = staliro_options;
% staliro_opt.optimization_solver = 'UR_Taliro';
staliro_opt.optimization_solver = 'SA_Taliro';
staliro_opt.optim_params.n_tests = 50;
staliro_opt.SampTime = 0.01;

% Define other parameters
simulationTime = 100;
init_cond = [];