% function genTestSuite(modelname, pre_phi, pre_preds, post_phi, post_preds, input_range)
function tv = genTestSuite(model,init_cond, phi, preds, sim_time,Oldt,input_range,interpolation_type,cp_array,cp,datasavefile,categorical,count,yasou_opt)

    TS_loadpath = yasou_opt.testSuiteLoadPath;
    TS_savepath = yasou_opt.testSuiteSavePath;
    if ~isempty(TS_loadpath)
        if exist(TS_loadpath, 'file')
            load(TS_loadpath, 'tv');
            disp(['Loaded test suite from ', TS_loadpath]);
            return;
        elseif strcmp(TS_loadpath, TS_savepath)
            warning('Loading and saving test suite from the same path. This may overwrite the saved test suite.');
        else
            error('Tried to load test suite from %s, but file does not exist.', TS_loadpath);
        end
    end

    curPath=fileparts(which('GenSuite.m')); 
    addpath(genpath(curPath));
    cpf=repmat('%.3f,',1,size(cp,2));
%     cp{end+1}='label';
    controlPointNames=cp(1:end);

    switch yasou_opt.policy
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

    yasou_opt.optimization_solver = optimization_solver;  
    interpolation    = cell(size(cp_array,2), 1);
    interpolation(:) = {interpolation_type};
    yasou_opt.interpolationtype = interpolation;
    yasou_opt.falsification=isfalsification;
    % Setting the iteration size (we recommend a minimum value as 30 test cases)
    if yasou_opt.testSuiteSize < yasou_opt.iteration1Size
        yasou_opt.optim_params.n_tests=yasou_opt.iteration1Size;
    else
        yasou_opt.optim_params.n_tests=yasou_opt.testSuiteSize;
    end
    yasou_opt.runs=1;
    disp(['Setting S-Taliro with ',optimization_solver]);
    disp('Running S-Taliro');
    tv=[];
    %% Running Staliro
    [results, history, yasou_opt]=staliro(model,init_cond, input_range, cp_array,  phi, preds, sim_time, yasou_opt, Oldt,controlPointNames,categorical,count);
    samples= vertcat(history.samples);
    robustness=vertcat(history.rob);
    tv=[samples robustness];
    % NOTE: resuls returns the best
    % NOTE: history returns the best of each iteration
    delete '*.slxc';


    % Check if the test falsifies the property

    % Save or return the falsifying tests
    if TS_savepath
        save(TS_savepath, 'tv');
        disp(['Test suite saved to ', TS_savepath]);
    end

end 