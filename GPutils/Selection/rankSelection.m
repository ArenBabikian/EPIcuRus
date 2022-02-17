% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function  SelectedPop= rankSelection(CurrentPop,~,gp_opt)
%% rankSelection selects the parents for the next population using Rank selection mechanism
% Inputs:   CurrentPop: the population from which parents will be selected
%           gp_opt: GP options
% Outputs:  SelectedPop: the selected population to represents the parents
    popSize=gp_opt.pop_size;
    Fitness=[CurrentPop.f];
    SelectedPop=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
    T = struct2table(CurrentPop);
    sortedT = sortrows(T, 'fitness');
    CurrentPop = table2struct(sortedT);

    ProbSelection=zeros(popSize,1);
    CumProb=zeros(popSize,1);

    for i=1:popSize
        ProbSelection(i)=i/popSize;
        if i==1
            CumProb(i)=ProbSelection(i);
        else
            CumProb(i)=CumProb(i-1)+ProbSelection(i);
        end
    end
    index=0;
    SelectInd=rand(popSize,1);
    for j=1:popSize
        if(CumProb(j)<SelectInd(i) && CumProb(j+1)>=SelectInd(i))
            index=index+1;
            SelectedPop(index)=CurrentPop(j+1);
        end
    end
    
end
