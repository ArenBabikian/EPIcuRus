% This script is used to define all the variables needed to run the SC
% benchmark on Hecate

% Call the global variables
global init_cond;
global simulationTime;

% Choose the model
model = 'stc_Screenshot';

% Hecate parameters
input_param(1).Name = 'Hecate_flow1';
input_param(1).LowerBound = 3.985;
input_param(1).UpperBound = 4.015;

input_param(2).Name = 'Hecate_delay';
input_param(2).LowerBound = 5;
input_param(2).UpperBound = 30;

input_param(3).Name = 'Hecate_Amp';
input_param(3).LowerBound = 0;
input_param(3).UpperBound = 0.015;

input_param(4).Name = 'Hecate_Freq';
input_param(4).LowerBound = 0.2;
input_param(4).UpperBound = 0.3;

% Name of active scenarios
activeScenarioTS = '';

% Define options
staliro_opt = staliro_options;
staliro_opt.optim_params.n_tests = 100;
staliro_opt.SampTime=0.01;

% Define other parameters
simulationTime = 35;
init_cond = [];
