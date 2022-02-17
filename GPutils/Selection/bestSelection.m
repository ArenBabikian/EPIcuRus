% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function selectedPop=bestSelection(pop,~,gp_opt)
% bestselection selects individuals with best selectionrate fitness f
% selecty the best individual in pop
    selectionrate=0.5;
    currentPop=pop;
    P = struct2table(currentPop);
    sortedP = sortrows(P, 'fitness');
    current_sorted_Pop = table2struct(sortedP);
    indexbest=current_sorted_Pop(end).id;
    % remove the best individual from currentPop
    currentPop=currentPop(setdiff(1:size(currentPop,2), indexbest));
    popsize = gp_opt.pop_size;
    % Select at random 
    randomRows=currentPop(randperm(numel(currentPop),selectionrate*popsize));
    T = struct2table(randomRows);
    sortedT = sortrows(T, 'fitness');
    sortedS = table2struct(sortedT);
    selectedPop=sortedS(size(sortedS,1)*selectionrate+1:size(sortedS,1))'; 
    selectedPop(1)=current_sorted_Pop(end);
end
