% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function maxDepth = getDepth(tree)
    maxDepth = 1; 
    for k=1:length(tree.kids)
        depthChild = 1 + getDepth(tree.kids{k});
        if depthChild > maxDepth
            maxDepth = depthChild;
        end
    end
 end
