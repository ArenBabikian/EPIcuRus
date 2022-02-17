% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function refinedBestAssumptions=refineAssumptions(bestAssumptions,inputnames)
% REFINEBESTASSUMPTIONS refines the assumptions in bestassumptions by removing the less informative among the comparable assumptions 
% and keeping only the non comparable ones
% INPUTS:
%   best Assumptions: the array that contains the best assumptions found
%   inputnames: the list of the input names
% OUTPUTS:
%   refinedBestAssumptions: the array of the best assumptions after the
%   refinement

    refinedBestAssumptions= bestAssumptions;
    for as1 = 1: numel(bestAssumptions)        
        % declare variable inputs
        for tc_input=1:size(inputnames,2)
            if contains(bestAssumptions(as1).str,inputnames{tc_input}(1:end-1))
                syms(inputnames{tc_input}(1:end-1));
            end
        end
        % convert contr from string into expression
        expr1=str2sym(replace(bestAssumptions(as1).assum, ' and ', ' & '));
        for as2 = as1+1: numel(bestAssumptions)            
            % declare variable inputs
            for tc_input=1:size(inputnames,2)
                if contains(bestAssumptions(as2).str,inputnames{tc_input}(1:end-1))
                    syms(inputnames{tc_input}(1:end-1));
                end
            end
            % convert contr from string into expression
            expr2=str2sym(replace(bestAssumptions(as2).assum, ' and ', ' & '));
            assume(expr1,'clear'); %clears all assumptions on all variables in expr2.
            assume(expr2,'clear');
            assume(expr1);
            if isAlways(expr2,'Unknown','false')
                disp('two comparable assumptions found.. Proceding refinement');
                % as2 is more informative than as1 => remove as1
                % todo: consider refinedBestAssumptions in the for loop
                refinedBestAssumptions=removeAssumption(bestAssumptions,as1);
            else
                assume(expr1,'clear');
                assume(expr2,'clear');
                assume(expr2);
                if isAlways(expr1,'Unknown','false')
                    disp('two comparable assumptions found.. Proceding refinement');
                    % as1 is more informative than as2 => remove as2
                    refinedBestAssumptions=removeAssumption(bestAssumptions,as2);
                end
            end
        end
    end
                    
end
