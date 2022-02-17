% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
% dtGenAssumtpion generates assumption using machine learning decision trees.

function [assumptionArray,parent_constraints,interAssum] = dtGenAssumtpion(tv,Olt,inputnames,categorical,assume_options)
    assume_opt=assume_options();
    data = [Olt;tv]; 
    X=data(:,1:end-1);     % X contains the input predictors
    if ~isempty(categorical) % if the categorical is set , make sure the inputs are booleans 
        X(:,categorical)=double(X>=0.5);
    end
    Y1=data(:,end);       % Y contains the fitness values
    Y(:,1)=double(Y1(:,1)>=assume_opt.desiredFitness);

    classificationTree =  fitctree(X,Y,...
                     'PredictorNames',inputnames,...
                     'CategoricalPredictors',categorical,...
                     'ClassNames',[0,1]);
    as=getNodes(classificationTree); % as: a cell array of all ci
    interAssum=getAssumption(classificationTree,as);
    % Select assumptions associated with fitness>0
    if classificationTree.NumNodes==1
        assumptionArray=[];
        parent_constraints=[];
    else
        [parent_constraints,assumptionArray]= selectA(interAssum,'>',assume_opt.desiredFitness,assume_opt.exploit,1);
    end
end
