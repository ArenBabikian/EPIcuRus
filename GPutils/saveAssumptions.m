% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [assumptions,bestFitness,bestAssumptions]=saveAssumptions(assumptions,pop,pop_id,bestFitness,bestAssumptions,filePath,state,inputnames,gp_opt,opt)
%% saveAssumptions adds the assumptions of one population to the history of assumptions
% Inputs:   assumptions: the history of assumptions
%           pop: the new population
%           pop_id: the current id in assumptions 
%           bestAssumptions: the best assumptions history
%           bestFitness: the best fitness before  evaluating the new pop
%           gp_opt: GP options
% OUTPUT:   assumptions: the history of assumptions after evaluating the new pop
%           bestFitness: the best fitness after evaluating the new pop
%           bestAssumption: the best assumption after evaluating the new pop
    bestAssumption=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
    index=1;
    % Saving the assumptions of the population to the history of assumptions 
    % Saving the best assumption and best fitness found in the population
    for i = (pop_id*gp_opt.pop_size)+1 : (pop_id+1)*gp_opt.pop_size        
        assumptions(i)=pop(index);
        % check if the population's best assumption exists in bestAssumptions history      
%         bestAssumptionIdxInBest=find(arrayfun(@(bestAssumptions) ismember(pop(index).str,bestAssumptions.str,'rows'),bestAssumptions));
        % if the population's best assumption is new, and the fitness is
        % higher than the best fitness in bestFitness , then save the
        % assumption as bestAssumption and update bestFitness
        if pop(index).fitness >= bestFitness 
            % check if the population's best assumption exists in bestAssumptions history      
%             bestAssumptionIdxInBest=find(arrayfun(@(bestAssumptions) ismember(pop(index).str,bestAssumptions.str,'rows'),bestAssumptions));
            history_contains_assumption=contains({bestAssumptions.str},pop(index).str);
            if  all(~history_contains_assumption)
                bestFitness=pop(index).fitness;
                bestAssumption=pop(index);
                bestAssumption.id=pop_id;
            end
        end
        index=index+1;
    end  
    % Saving the best assumption to the history of best assumptions 
    % The best assumption found in the population is then simplified
    if opt.nbrControlPoints>1
        cp=[];
        bestAssumption.assum=simplifyAssumption(bestAssumption.assum);
        bestAssumption.qct=bestAssumption.assum;
        if ~state.isboolean
            % for reals
           elements=strsplit(bestAssumption.assum,' ');
            for el = 1:size(elements,2)
                iscontains=0;
                for input = 1 : size(inputnames,2)                  
                    if contains(elements{el},inputnames{input}) && iscontains==0
                        iscontains=1;
                        cp_idx=strfind(elements{el},inputnames{input})+length(inputnames{input});
                        cp=[cp,str2double(elements{el}(cp_idx))];
                        element=[elements{el}(1:cp_idx-1),'of_k',elements{el}(cp_idx+1:end)];
                        input_idx=strfind(bestAssumption.qct,elements{el});
                        if ~isempty(input_idx)
                          location = input_idx(1);
                        end
                        bestAssumption.qct=[bestAssumption.qct(1:location-1),element,bestAssumption.qct(location+length(elements{el}):end)];
                    end
                end
            end
            bestAssumption.cp=cp;
        else
%for booleans
            B=regexp(bestAssumption.assum,'\d*','Match');
            for ii= 1:length(B)
                if ~isempty(B{ii})
                  cp(1,ii)=str2double(B{ii}(end));
                else
                  cp(1,ii)=NaN;
                end
            end
            bestAssumption.qct=bestAssumption.assum;
            for c=1:opt.nbrControlPoints
                bestAssumption.qct=replace(bestAssumption.qct,num2str(c),'of_k');
            end
            bestAssumption.cp=cp;
        end
    else
        bestAssumption.assum=simplifyAssumption(bestAssumption.assum);
        bestAssumption.qct=simplifyAssumption(bestAssumption.qct);
    end
    % if empty simplifiedAssumption it means the assumption is evaluated
    % as TRUE or FALSE
    % Save the simplified assumption to the best assumptions history
    % bestAssumptions if it is new and v-safe
    if ~isempty(bestAssumption.assum)
        bestAssumptions=saveBestAssumptions(bestAssumptions,bestAssumption,filePath);   
    end   
    
end
