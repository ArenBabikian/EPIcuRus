% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function refinedBestAssumptions=removeAssumption(bestAssumptions,as)
% REFINEBRSTASSUMPTIONS removes the assumptions that are simplified to true
% from bestAssumptions array. These assumption are usually the
% simplification of constant1 < constant2
% it also removes the assumption as in the parameters
% INPUTS:
%   bestAssumptions: the array of best assumptions found
%   as: the assumption to be removed
% OUTPUTS: 
%   refinedBestAssumptions: the array of best assumptions after the updates
    true_idx=find(arrayfun(@(bestAssumptions) ismember('TRUE',bestAssumptions.assum,'rows'),bestAssumptions));
    v = setdiff(1:size(bestAssumptions,2), [as,true_idx]);
    refinedBestAssumptions=bestAssumptions(v);
end
