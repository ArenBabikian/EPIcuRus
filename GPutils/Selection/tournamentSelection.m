% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function selectedPop=tournamentSelection(pop,~,gp_opt)
%% tournamentSelection selects the parents for the next population using tournament selection mechanism
% Inputs:   pop: the population from which parents will be selected
%           gpopt: GP options
% Outputs:  selectedPop: the selected population to represents the parents
    
    selectedPop=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
    currentPop=pop;
    P = struct2table(currentPop);
    sortedP = sortrows(P, 'fitness');
    current_sorted_Pop = table2struct(sortedP);
    indexbest=current_sorted_Pop(end).id;
    % remove the best individual from currentPop
    currentPop=currentPop(setdiff(1:size(currentPop,2), indexbest));
    popsize = gp_opt.pop_size;
    for i = 1: popsize*gp_opt.sel_rate
        % Select at random t_size individuals
        randomRows=currentPop(randperm(numel(currentPop),gp_opt.t_size));
        T = struct2table(randomRows);
        sortedT = sortrows(T, 'fitness');
        sortedS = table2struct(sortedT);
        % Select the best among t_size individuals
        selectedPop(i)=sortedS(end); 
        indexbest=sortedS(end).id;
        currentPop=currentPop(setdiff(1:size(currentPop,2), indexbest));
    end
    % select the best individual in pop
    selectedPop(1)=current_sorted_Pop(end);
 end
        
