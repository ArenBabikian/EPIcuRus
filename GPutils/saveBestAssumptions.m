% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function bestAssumptions=saveBestAssumptions(bestAssumptions,bestAssumption,bestAssumption_filename)
% SAVEBESTASSUMPTIONS takes the best assumption found and save it in the
% array/ csv file of the history best assumptions only is it does no exist in the array
%INPUTS:    bestAssumptions: the array of old best assumptions
%           bestAssumption: the new best assumption found
%           bestAssumption_filename: the name of the best assumptions csv
%           file
%OUTPUTS:
%   bestAssumptions: the array of old best assumptions + the new best assumption found
    emptyIndex = find(arrayfun(@(bestAssumptions) isempty(bestAssumptions.id),bestAssumptions));
    if ~isempty(emptyIndex)
        best_idx=0;
    else
        best_idx=numel(bestAssumptions);
    end
    % a condition on the value vsafe=1 is added: only v-safe assumptions
    % are saved as best
    if ~isempty(bestAssumption)
        bestAssumptionIdxInBest=find(arrayfun(@(bestAssumptions) ismember(bestAssumption.assum,bestAssumptions.assum,'rows'),bestAssumptions));
        if isempty(bestAssumptionIdxInBest) && bestAssumption.vsafe==1
            best_idx=best_idx+1;
            bestAssumptions(best_idx)=bestAssumption;
            disp(['Best assumption so far: ',bestAssumption.assum]);
            disp(['Best fitness so far: ', num2str(bestAssumption.fitness)]);
            % save to csv
            fid = fopen([bestAssumption_filename,'.csv'],'a');
            fprintf(fid,'%d,%s,%.4f\n',bestAssumption.id, bestAssumption.assum, bestAssumption.fitness);
            fclose(fid);
        end
    end
end
