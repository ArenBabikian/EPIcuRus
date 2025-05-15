% function genTestSuite(modelname, pre_phi, pre_preds, post_phi, post_preds, input_range)
function tv = genTestSuite(model,init_cond, phi, preds, sim_time,Oldt,input_range,interpolation_type,cp_array,cp,datasavefile,categorical,count,epicurus_opt)

    curPath=fileparts(which('GenSuite.m')); 
    addpath(genpath(curPath));
    cpf=repmat('%.3f,',1,size(cp,2));
%     cp{end+1}='label';
    controlPointNames=cp(1:end);


    
    switch epicurus_opt.policy
        case 'UR'
            isfalsification=0;      
            optimization_solver = 'UR_Taliro'; 
        case 'ART'
            isfalsification=0;        
            optimization_solver = 'AR_Taliro';
        case 'IFBT_ART'
            isfalsification=0;   
            optimization_solver = 'IFBT_ART';
        case 'IFBT_UR'
            isfalsification=0;   
            optimization_solver = 'IFBT_UR';
        otherwise    % uniform random by default
            error('Unknown policy');
            % isfalsification=0;   
            % optimization_solver = 'UR_Taliro';
    end

    epicurus_opt.optimization_solver = optimization_solver;  
    interpolation    = cell(size(cp_array,2), 1);
    interpolation(:) = {interpolation_type};
    epicurus_opt.interpolationtype = interpolation;
    epicurus_opt.falsification=isfalsification;
    % Setting the iteration size (we recommend a minimum value as 30 test cases)
    if epicurus_opt.testSuiteSize < epicurus_opt.iteration1Size
        epicurus_opt.optim_params.n_tests=epicurus_opt.iteration1Size;
    else
        epicurus_opt.optim_params.n_tests=epicurus_opt.testSuiteSize;
    end
    epicurus_opt.runs=1;
    disp(['Setting S-Taliro with ',optimization_solver]);
    disp('Running S-Taliro');
    tv=[];
    %% Running Staliro
    [results, history, epicurus_opt]=staliro(model,init_cond, input_range, cp_array,  phi, preds, sim_time, epicurus_opt, Oldt,controlPointNames,categorical,count);
    samples= vertcat(history.samples);
    robustness=vertcat(history.rob);
    tv=[samples robustness];
    % NOTE: resuls returns the best
    % NOTE: history returns the best of each iteration
    delete '*.slxc';


    % Check if the test falsifies the property

    % Save or return the falsifying tests



    
end