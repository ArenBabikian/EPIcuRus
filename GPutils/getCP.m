% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function cps=getCP(tree)
% GETCP is a recursive function to return the nodes IDs of the
% same input type and control points in a tree    
    if isempty(tree)
        return;
    end
    % changed cps=tree.cp to if else
    if isempty(tree.kids)
        cps=tree.cp;
    else
        cps=[];
    end
    cp=[];
    if ~isempty(tree.kids)
        cp{1}=getCP(tree.kids{1});
        cp{2}=getCP(tree.kids{2});
    end
    for i=1:size(cp,2)
        if ~isempty(cp{i})
            cps=[cps,cp{i}];
        end
    end
end
