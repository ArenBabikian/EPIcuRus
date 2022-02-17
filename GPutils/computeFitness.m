% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [vsafe,informative,fitness]=computeFitness(ind,fitness,ts_labels,ts,Map,state)
% Compute fitness of an individual
% INPUTS 	tsinput: the test suite values
%           ts_labels: the verdicts associated to the test suite
%           inputnames: the list of input names
%           ind: the individual assumption
% OUTPUTS:  vsafe: the vsafe fitness value
%           informative: the informative fitness value
%           fitness: the fitness function value
        inputs=getInputsfromTree(ind.tree,state);
        assumption_holds=[];
        if ~isempty(inputs)
            evaluation_statement=ind.assum;
           
            if state.isboolean==1
                for in = 1 : numel(inputs)
                    inp=split(inputs{in},' ');
                    
                    input_index=Map(inp{end}(1:end-1));                    

                    cp=inp{end}(end);
                    evaluation_statement=replace(evaluation_statement,['not ',inp{end}],['ts(:,',num2str(input_index),',',num2str(cp),')==0'] );
                    evaluation_statement=replace(evaluation_statement,inp{end},['ts(:,',num2str(input_index),',',num2str(cp),')==1'] );
                end
            else
                for in = 1 : numel(inputs)
                    input_index=Map(inputs{in}(1:end-1));
                    cp=inputs{in}(end);
                    evaluation_statement=replace(evaluation_statement,inputs{in},['ts(:,',num2str(input_index),',',num2str(cp),')'] );            
                end
            end
%              evaluation_statement='abs((2590614620851585*tv(:,2,1))/576460752303423488 - (5469*tv(:,1,1))/10000 + (5754231229492773*tv(:,3,1))/1152921504606846976 - (713*tv(:,1,1)*tv(:,2,1))/10000 + (321*tv(:,1,1)*tv(:,3,1))/5000 - (5979*tv(:,2,1)*tv(:,3,1))/10000 + tv(:,2,1)*tv(:,6,1) - tv(:,3,1)*tv(:,5,1) - (69*tv(:,2,1)^2)/2500 + (69*tv(:,3,1)^2)/2500)<0.001';
            % evaluation_statement='ts(:,1,1)>2';
            evaluation_statement=replace(evaluation_statement,'^','.^');
            evaluation_statement=replace(evaluation_statement,') *',') .*');
            evaluation_statement=replace(evaluation_statement,')*',') .*');
            evaluation_statement=replace(evaluation_statement,'and','&');
            evaluation_statement=replace(evaluation_statement,'or','|');
            % the assumption holds and the test case passes the
            % property
            try
                assumption_holds=eval(evaluation_statement); % a boolean array evaluating the assumption on each test case
            catch
                disp(evaluation_statement);
                TP=0;
                FN=0;
            end
            if ~isempty(assumption_holds)
                TP=sum(ts_labels(assumption_holds)==1);
                % the assumption holds and the test case violates the
                % property
                FN=sum(ts_labels(assumption_holds)==0);
            end
            
            % avoid /0 cases
            if TP==0 && FN==0
                vsafe=0;
            else
                vsafe=TP/(TP+FN);
            end
            % when, there is no(or a minority of) number of the test cases where the assumption holds
            % ( meaning There is only(or a majority of) number the test cases where
            % assumption holds),
            % in this case, we should penalize the informative fitness. otherwise,
            % the informativeness will be high which is not a good indicator.
            informative=(TP+FN)/size(ts_labels,1);
        else
            vsafe=0;
            informative=0;
        end
        % compute the fitness function value
        fitness=fitness(vsafe,informative);
end
