% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function parents = rouletteSelection(pop,state,gp_opt)
%% rouletteSelection selects the parents for the next population using Roulette selection mechanism
% Inputs:   pop: the population from which parents will be selected
%           state: GP state 
%           gpopt: GP options
% Outputs:  parents: the selected population to represents the parents
    % pop.Rank was replaced with pop.fitness
     parents=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
     if state.init==1
         parents=pop;
     else         
         probForMember=zeros(size(pop,2),2);
         for k=1:size(pop,2)
             % minimization: (1/pop(k).f)/invRanksSum
            probForMember(k,1)= pop(k).fitness/sum([pop.fitness]);
            probForMember(k,2)= pop(k).fitness;
         end
         probForMember_sorted=sortrows(probForMember,1);
         cumulative=probForMember_sorted;
         cumulative(:,1)=cumsum(probForMember_sorted(:,1));
         for i=1:gp_opt.pop_size
             r=rand;
             idx=find(cumulative(:,1)>=r);
             rank=cumulative(idx(1),2);
             parents_idx=find([pop.fitness]==rank);
             rr=randi(size(parents_idx,1));
             parents(i)=pop(parents_idx(rr)); % pick random ind from those who have rank of idx
         end
     end
 end
