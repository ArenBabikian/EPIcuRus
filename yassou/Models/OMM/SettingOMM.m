% This script is used to define all the variables needed to run the OMM
% benchmark on Hecate

% Call the global variables
global init_cond;
global simulationTime;
global model_num;

% Choose the model
if model_num == 0
    model = 'Observer_mode_model0';
elseif model_num == 1
    model = 'Observer_mode_model1';
elseif model_num == 2
    model = 'Observer_mode_model2';
elseif model_num == 3
    model = 'Observer_mode_model3';
end

% Hecate parameters
input_param(1).Name = 'Hecate_u1';
input_param(1).LowerBound = -2;
input_param(1).UpperBound = 5;

input_param(2).Name = 'Hecate_u2';
input_param(2).LowerBound = -2;
input_param(2).UpperBound = 5;

input_param(3).Name = 'Hecate_u3';
input_param(3).LowerBound = -2;
input_param(3).UpperBound = 5;

input_param(4).Name = 'Hecate_u4';
input_param(4).LowerBound = -2;
input_param(4).UpperBound = 5;

input_param(5).Name = 'Hecate_time';
input_param(5).LowerBound = 2;
input_param(5).UpperBound = 7;

% Name of active scenarios
activeScenarioTS = '';

% Define options
staliro_opt = staliro_options;
staliro_opt.optimization_solver = 'UR_Taliro';
% staliro_opt.optimization_solver = 'SA_Taliro'; 
staliro_opt.optim_params.n_tests = 15;
staliro_opt.SampTime = 0.01;

% Define other parameters
simulationTime = 10;
init_cond = [];

% Define S-Taliro parameters
staliro_InputBounds = [-2 5; -2 5];
staliro_cp_array = 6;
staliro_SimulationTime = simulationTime;
staliro_opt.interpolationtype={'pchip'};

input_data.range = staliro_InputBounds;
input_data.name = {'$u1$', '$u2$'};
output_data.range = [0, 500; 0, 500];
output_data.name = {'$y1$', '$y2$'};