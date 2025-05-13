% This script is used to define all the variables needed to run the AT
% benchmark on Hecate

% Call the global variables
global init_cond;
global simulationTime;
global model_num; 

% Choose the model
if model_num == 0
    model = 'Autotrans_shift';
elseif model_num == 1
    model = 'Autotrans_shift1';
elseif model_num == 2
    model = 'Autotrans_shift2';
elseif model_num == 3
    model = 'Autotrans_shift3';
end

% Write requirements in STL
at1 = '[]_[0,20] speed120';
at2 = '[]_[0,10] rpm4750';

preds(1).str = 'speed120';
preds(1).A = [1 0 0];
preds(1).b = 120;

preds(2).str = 'rpm4750';
preds(2).A = [0 1 0];
preds(2).b = 4750;

% Hecate parameters
    % Original range: [5, 100]
    % Modified range: [50, 85]
input_param(1).Name = 'Hecate_throttle1';
input_param(1).LowerBound = 5;  % It should be 5 to avoid errors
input_param(1).UpperBound = 100;

    % Original range: [0, 325]
    % Modified range: [0, 150]
input_param(2).Name = 'Hecate_brake1';
input_param(2).LowerBound = 0;
input_param(2).UpperBound = 325;

    % Original range: [5, 100]
    % Modified range: [50, 90]
input_param(3).Name = 'Hecate_throttle2';
input_param(3).LowerBound = 5;  % It should be 5 to avoid errors
input_param(3).UpperBound = 100;

    % Original range: [0, 325]
    % Modified range: [0, 150]
input_param(4).Name = 'Hecate_brake2';
input_param(4).LowerBound = 0;
input_param(4).UpperBound = 325;

    % Original and Modified range: [0, 35]
input_param(5).Name = 'Hecate_trans';
input_param(5).LowerBound = 0;
input_param(5).UpperBound = 35;

% Name of active scenarios
activeScenarioTA = 'AT1';
activeScenarioTS = '';
phi = at1;

% Define options
staliro_opt = staliro_options;
% staliro_opt.optimization_solver = 'UR_Taliro';
staliro_opt.optimization_solver = 'SA_Taliro'; 
staliro_opt.optim_params.n_tests = 1500;
staliro_opt.SampTime = 0.01;

% Define other parameters
simulationTime = 35;
init_cond = [];

% Define S-Taliro parameters
staliro_InputBounds = [0 100; 0 325];
staliro_cp_array = [7, 3];
staliro_SimulationTime = simulationTime;
staliro_opt.interpolationtype={'pchip','pchip'};

input_data.range = staliro_InputBounds;
input_data.name = {'$Throttle~[\%]$', '$Brake~torque~[lb-ft]$'};
output_data.range = [0, 160; 0, 5000; 1, 4];
output_data.name = {'$Vehicle~speed~[mph]$', '$Engine~speed~[rpm]$', '$Gear~[/]$'};