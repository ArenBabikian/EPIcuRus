% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
function [bestAssumption,bestA,pop]=gpGenAssum(tv,oldA,bestA,inputnames,state,filePath,categorical,opt,gp_opt)
% GPGENASSUM generates assumptions using Genetic Programming.
% INPUTS:   tv: new test suite
%           Olt: old test suite
%           inputnames: the list of the input names
%           state: contains the state of the GP and the variables
%           associated to GP
%           filePath: the path to the run folder
%           opt: Epicurus options
%           gp_opt: GP options
% OUTPUTS:  bestAssumptions: the best assumptions generated 
%           pop: the last population generated

    data = tv(:,1:end-1); % removing the fitness value from the data record
    if ~isempty(categorical) % if the categorical is set , make sure the inputs are booleans 
        data(:,categorical)=double(data>=0.5);
    end
     % ts_inputs contains the input values of the test cases in TS
     % Convert the data into a 3D array which contains:
     % dimension 1- test cases
     % dimension 2- the model inputs
     % dimension 3- the control point values
     cp_data=[];
     for c=1:opt.nbrControlPoints
         cp_data=[cp_data,data(:,c:opt.nbrControlPoints:end)];
     end
%     ts_inputs=permute(reshape(data,opt.nbrControlPoints,opt.testSuiteSize,size(inputnames,2)),[2,1,3]);
    ts_inputs=reshape(cp_data,opt.testSuiteSize,size(inputnames,2),[]);
    % map input names to test suite  
    keySet=inputnames;
%     cells = mat2cell(ts_inputs,size(ts_inputs,1),size(ts_inputs,2),ones(1,size(ts_inputs,3)));
%     valueSet =cells(:);
    valueSet=1:size(inputnames,2);
    tsinputsMap = containers.Map(keySet,valueSet);
    
    ts_fitness=tv(:,end);   % ts_fitness contains the fitness values of the test cases in TS

        
    ts_labels(:,1)=double(ts_fitness(:,1)>=opt.desiredFitness); % ts_labels contains the label of the test cases in TS (1: pass, 0 : fail)
    
        % write header to csv file of best assumptions
    
    fid = fopen([filePath,'.csv'],'w');
    fprintf(fid,'%s,%s,%s\n','AssumptionID','Assumption','Fitness');
    fclose(fid);
    pop_id=0; 
    assumptions=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
    bestAssumptions=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
    bestFitness=-inf;
    % initialize random number generator (see help on RAND):
    rand('state',sum(100*clock));
     
    %% Initial population
    state.init=1;
    
    % usage of old assumption with init_Ratio
    if strcmp(gp_opt.algorithm,'GP') && ~isempty(oldA)
        [pop,state]=initPop(state,floor(gp_opt.pop_size*(1-gp_opt.init_Ratio)),opt,gp_opt);      
        % w/o srting:
        % assumptions_selected_from_oldA=oldA(randperm(numel(oldA),floor(gp_opt.pop_size*gp_opt.init_Ratio)));
        % w sorting:
        % Sort old assumptions with fitness
        T = struct2table(oldA);
        sortedT = sortrows(T, 'fitness');
        sortedS = table2struct(sortedT);
        pop(floor(gp_opt.pop_size*(1-gp_opt.init_Ratio))+1:gp_opt.pop_size)=sortedS(floor(gp_opt.pop_size*(1-gp_opt.init_Ratio))+1:gp_opt.pop_size);
        if ~isempty(bestA.id)
            % record the fitness of bestA (the last iteration) on the TS (the current iteration) 
            % to see if the fitness improve during the current iteration 
            [~,~,bestA.fitness]= computeFitness(bestA,gp_opt.fitness,ts_labels,ts_inputs,tsinputsMap,state);
            pop(1)=bestA;
        end
    else
        [pop,state]=initPop(state,gp_opt.pop_size,opt,gp_opt);
        if ~isempty(oldA)
            pop(1)=bestA;
        end
    end
    % compute the fitness
    for i=1:gp_opt.pop_size            
        [pop(i).vsafe,pop(i).informative,pop(i).fitness]= computeFitness(pop(i),gp_opt.fitness,ts_labels,ts_inputs,tsinputsMap,state);
        pop(i).id=i;     
    end
    
    [assumptions,bestFitness,bestAssumptions]=saveAssumptions(assumptions,pop,pop_id,bestFitness,bestAssumptions,filePath,state,inputnames,gp_opt,opt);
    
    %% GP Loop
    while  pop_id < gp_opt.gen_size
        pop_id=pop_id+1; 
        
        %% fix IDs
        for i=1:gp_opt.pop_size
            pop(i).id=i;
        end
        % Random search
        if strcmp(gp_opt.algorithm,'RS')
            [pop,state]=initPop(state,gp_opt.pop_size,opt,gp_opt);
            % compute the fitness
            for i=1:gp_opt.pop_size            
                [pop(i).vsafe,pop(i).informative,pop(i).fitness]= computeFitness(pop(i),gp_opt.fitness,ts_labels,ts_inputs,tsinputsMap,state);
                pop(i).id=i;     
            end
        else
        % GP
            %% Selection
            Best=feval(gp_opt.sel_crt,pop,state,gp_opt); 
            state.init=0;
            % initialize random number generator (see help on RAND):
            rand('state',sum(100*clock));
            %% Genetic operators
            % Apply mutation and crossover to Best
            pop=genPop(Best,state,ts_labels,ts_inputs,tsinputsMap,opt,gp_opt);
        end
  
        % Add the new population to history in 'assumptions'
        % Add the best assumption of the population in 'bestAssumptions' if new
        % save the best fitness found so far in bestFitness
        % assumptions=history of all assumptions 
        % bestFitness= the best fitness 
        % bestAssumptions= the best assumptions history
        [assumptions,bestFitness,bestAssumptions]=saveAssumptions(assumptions,pop,pop_id,bestFitness,bestAssumptions,filePath,state,inputnames,gp_opt,opt);
        
    end 
   bestAssumption=bestAssumptions(end);
    
        
end
