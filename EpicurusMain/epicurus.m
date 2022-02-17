% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.

function epicurus(M,P,init_cond, phi, preds, sim_time,input_names,categorical,input_range,assume_opt,gp_epicurus_opt,scriptname,resultfilename,policyFolder,state)

% EPICURUS iteratively performs the test case generation and the assumption generation for one model, one property one policy and one learning algorithm. 
% When QVtrcae check is enabled, it stops when a sound assumption is found.
% Otherwise,
% When Epicurus is set with 'DT', it stops when the number of iterations reaches the maximum number of
% iterations set. When it is set with 'GP', it stops when the Timeout is
% reached.
% Then it writes the results of each assume run into the
% results folder. the results contain a .qct file containing the assumption
% and a .txt file containing the total time required to generate the assumption.
%
% INPUTs
%   - M: the simulink model name. 
%   - P: the property name.
%   - init_cond : a hyper-rectangle that holds the range of the initial 
%       conditions (or more generally, constant parameters) and it should be a 
%       Matlab n x 2 array, where 
%			n is the size of the vector of initial conditions.
%		In the case of a Simulink model or a Blackbox model:
%			The array can be empty indicating no search over initial conditions 
%			or constant parameters. For Simulink models in particular, an empty 
%			array for initial conditions implies that the initial conditions in
%			the Simulink model will be used. 
%
%       Format: [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_n UpperBound_n];
%
%       Examples: 
%        % A set of initial conditions for a 3D system
%        init_cond = [3 6; 7 8; 9 12]; 
%        % An empty set in case the initial conditions in the model should be 
%        % used
%        init_cond = [];
%
%       Additional constraints on the initial condition search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%   - phi : The formula to falsify. It should be a string. For the syntax of MTL 
%       formulas type "help dp_taliro" (or see staliro_options.taliro for other
%       supported options depending on the temporal logic robustness toolbox 
%       that you will be using).
%                               
%       Example: 
%           phi = '!<>_[3.5,4.0] b)'
%
%       Note: phi can be empty in case the model is a hybrid automaton 
%       object. In this case, an unsafe set must be provided in the hybrid
%       automaton.
%
%   - preds : contains the mapping of the atomic propositions in the formula to
%       predicates over the state space or the output space of the model. For 
%       help defining predicate mappings type "help dp_taliro" (or see 
%       staliro_options.taliro for other supported options depending on the 
%       temporal logic robustness toolbox that you will be using).
%
%       In case of parameter mining:
%           If staliro is run for specification parameter mining, then set the 
%           staliro option parameterEstimation to 1 (the default value is 0):
%               opt.parameterEstimation = 1;
%           and read the instructions under staliro_options.parameterEstimation 
%           on how to define the mapping of the atomic propositions.	
%
%   - sim_time : The simulation time.
%
%   - input_names: An array with the input names
%
%   - categorical: the index of the categorical inputs in input_name. if none write []
%
%   - input_range : 
%       The constraints for the parameterization of the input signal space.
%       The following options are supported:
%
%          * an empty array : no input signals.
%              % Example when no input signals are present
%              input_range = [];
%
%          * a hyper-rectangle that holds the range of possible values for 
%            the input signals. This is a Matlab m x 2 array, where m is the  
%            number of inputs to the model. Format:
%               [LowerBound_1 UpperBound_1; ...
%                          ...
%                LowerBound_m UpperBound_m];
%            Examples: 
%              % Example for two input signals (for example for a Simulink model 
%              % with two input ports)
%              input_range = [5.6 7.8; 8 12]; 
%
%          * a cell vector. This is a more advanced option. Each input signal is 
%            parameterized using a number of parameters. Each parameter can 
%            range within a specific interval. The cell vector contains the
%            ranges of the parameters for each input signal. That is,
%                { [p_11_min p_11_max; ...; p_1n1_min p_1n1_max];
%                                    ...
%                  [p_m1_min p_m1_max; ...; p_1nm_min p_1nm_max]}
%            where m is the number of input signals and n1 ... nm is the number
%                  of parameters (control points) for each input signal.
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%       Additional constraints on the input signal search space can be defined 
%       using the staliro option <a href="matlab: doc staliro_options.search_space_constrained">staliro_options.search_space_constrained</a>. 
%            Example: 
%               See staliro_demo_constraint_input_signal_space_01.m
%
%   - assume_opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.
%   - scriptname: the script of running a model requirement. the script is
%   saved under Benchmark in .m. The label of the script is in the form 'model name'+'property name'
%   _ resultfilename: the result file name used to save the data for each experiment.
%   - policyFolder: the folder that should contain all the results of one policy
%   - state: contains the operators list used for GP and other items(i.e.,root type)

    global hFeatures;
    assume_res(assume_opt.assumeEndRun)=struct('assumption','','isValid',[],'executiontime',[],'iteration',[]);
    originalqctPath=fullfile(fileparts(which([scriptname,'original.qct'])),[scriptname,'original.qct']);
    pol=assume_opt.policy;
    % Setting the interpolation function: it is either const or pconst
    if (assume_opt.nbrControlPoints==1) 
        interpolation_type='const';
    else
        interpolation_type='pconst';
    end
    numberOfInputs=size(input_names,2); % the number of inputs 
    % cp_array: the vector contains the number of control points of each input
    cp_array=assume_opt.nbrControlPoints*ones(1,numberOfInputs);
    % categorical and cp_names in terms of control points
    [categorical,cp_names]=getListOfFeatures(categorical,assume_opt.nbrControlPoints,input_names,cp_array); 
    % the total simulation time in QCT : the total number of steps
    kmax=(sim_time/assume_opt.SampTime);
    
    % Sanity check
    sanity=-1;
    if assume_opt.qvtraceenabled
        sanity=snCheck(scriptname,kmax,assume_opt);
    end
    % if Sanity check is valid, Run EPIcurus
    if sanity==-1
        % start EPIcuRus Runs
        for run=assume_opt.assumeStartRun:assume_opt.assumeEndRun
            hFeatures=[];
            RunFolder=[policyFolder,filesep,'Run',num2str(run)];
            filePath=[RunFolder,filesep,resultfilename];
            % Create the run folder
            if ~exist(RunFolder, 'dir')
                mkdir(RunFolder);
            end
            disp('-------------------------------');
            disp(['Run: ',num2str(run),'/',num2str(assume_opt.assumeEndRun)])
            Oldt=[];   % previously generated test cases
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
            % Start EPIcuRus iterations of the run
            %% GP
            executiontimetic=tic; 
            if strcmp(assume_opt.learningMethod,'GP')
                % TODO after cgtcg
                % if valid = 0 => counter example => generate new Test suite
                % if valid = 1 or valid = 2 => new test suite = empty 
                % reiterate
                EpicurusTime=tic;
                while toc(EpicurusTime) < 100
                    % the path to the iteration file 
                    filePath=[RunFolder,filesep,resultfilename];                 
                    iteariontimetic=tic;                     
                    % Start Test case generation time
                    tstimetic=tic;
                    % Test case generation 
                    tv= genSuite(M,init_cond, phi, preds, sim_time,Oldt,input_range,interpolation_type,cp_array,input_names,[filePath,'iteration_',num2str(count)],categorical,count,assume_opt);
                    % End Test case generation time
                    tstime=toc(tstimetic);
                    % Start assumption generation time
                    gptimetic=tic;
                    % Assumption generation
                    [bestA,oldBestA,oldA]=genAssum(tv,Oldt,oldA,bestA,input_names,categorical,state,[filePath,'iteration_',num2str(count)],assume_opt,gp_epicurus_opt);
                    % End assumption generation time
                     gptime=toc(gptimetic);
                    
                    % fitness plateau: count the number of consequtuve iterations in which the best fitness of the last iteration is equal to
                    % the best fitness of the current iteration.
                    % oldBestA: the best assumption of the previous iteration
                    % bestA: the best assumption of the current iteration
                    % Model checking
                    valid=modelCheck(assumption,scriptname,assume_opt,sim_time);
                    iterationtime=toc(iteariontimetic);
                    % display time
                    disp(['Model:', M,P,', method:', assume_opt.learningMethod,', iteration: ',num2str(count)]);
                    disp(['GP time : ', num2str(gptime), 's']);
                    disp(['TS time : ', num2str(tstime), 's']);

                    disp(['Total iteration time : ', num2str(iterationtime), 's']);
                    % Convert the best assumption to qct 
                    assumption=assumption2Qct(bestA,kmax,input_names,state,assume_opt);                     
                    % save the iteration time into a text file
                    writetime([filePath,'iteration_',num2str(count),'time.txt'],iterationtime);
                    % add the assumption to the text file
                    writeAssumptionsOfRun(bestA.assum,filePath);
                    % Save the best assumption into qct file
                    copyfile(originalqctPath,[filePath,'iteration_',num2str(count),'.qct']);
                    assumption=replace(assumption,'_x','(1)');
                    assumption=replace(assumption,'_y','(2)');
                    assumption=replace(assumption,'_z','(3)');
                    assumption=replace(assumption,'_w','(4)');
                    writeQCT(assumption,[filePath,'iteration_',num2str(count),'.qct'],kmax,assume_opt); 
                    % this part was added to allow the computation of inf
                    % index for multiple control points
                    fid=fopen([filePath,'iteration_',num2str(count),'.txt'],'wt');
                    fprintf(fid,'%s',bestA.assum);
                    count=count+1;
                end
                disp(['the fitness has evolved in the iterations: ', num2str(iteration_idx_with_fitness_jumps)]);
                disp(['the fitness didn''t evolved in the iterations: ', num2str(iteration_idx_with_no_fitness_jumps)]);
                writetime([filePath,'iteration_',num2str(count),'jumps.txt'],iteration_idx_with_fitness_jumps);
                writetime([filePath,'iteration_',num2str(count),'nojumps.txt'],iteration_idx_with_no_fitness_jumps);
            %% Decision Trees
            else
               
                       
                while  ((valid==0) || (valid==2))&& (count<=assume_opt.assumeIterations)

                    iterationtimetic=tic;
                    if count==1
                        assume_opt.first=1;
                    else
                        assume_opt.first=0;
                    end

                    disp(['Assume run: ',num2str(run)]);
                    disp(['Assume iteration: ',num2str(count)]);

                    tv= genSuite(M,init_cond, phi, preds, sim_time,Oldt,input_range,interpolation_type,cp_array,cp_names,[filePath,'iteration_',num2str(count)],categorical,count,assume_opt);
%                     [bestA,oldBestA,oldA]=genAssum(tv,Oldt,oldA,bestA,input_names,categorical,state,[filePath,'iteration_',num2str(count)],assume_opt,gp_epicurus_opt)
                    [A,~,~]=genAssum(tv,Oldt,oldA,bestA,cp_names,categorical,state,[filePath,'iteration_',num2str(count)],assume_opt,gp_epicurus_opt); 
                    if ~isempty(A)&& ~strcmp(A{1},'(NaN)')                        
                        assumption=DT2QCT(A(:,1),input_names,kmax,assume_opt);
                        valid=modelCheck(assumption,scriptname,assume_opt,sim_time);
                        if assume_opt.writeInternalAssumptions 
                            filePath=[RunFolder,filesep,resultfilename];
                            copyfile(originalqctPath,[filePath,'iteration_',num2str(count),'.qct']);
                            assumption=replace(assumption,'_x','(1)');
                            assumption=replace(assumption,'_y','(2)');
                            assumption=replace(assumption,'_z','(3)');
                            assumption=replace(assumption,'_w','(4)');
                            writeQCT(assumption,[filePath,'iteration_',num2str(count),'.qct'],kmax,assume_opt);
                        end 

                    end
                     Oldt=cat(1,Oldt,tv); 

                    iterationtime=toc(iterationtimetic);

                    writetime([filePath,'iteration_',num2str(count),'time.txt'],iterationtime);
                    count=count+1;
                end                       
            end
            executiontime=toc(executiontimetic);
            assume_res(run).assumption=assumption;
            assume_res(run).isValid=valid;
            assume_res(run).executiontime=executiontime;
            assume_res(run).iteration=count-1;
            fid = fopen([policyFolder,filesep,resultfilename,'.csv'],'a');
            fprintf(fid,'%s,%s,%s,%d,%d,%s,%d,%.4f,%d\n',M,P,pol,assume_opt.nbrControlPoints,run,assume_res(run).assumption,assume_res(run).isValid,assume_res(run).executiontime,assume_res(run).iteration);
            fclose(fid); 
        end
    else
        disp('Exit');
    end
end
