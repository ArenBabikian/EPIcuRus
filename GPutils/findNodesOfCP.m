% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function nodes=findNodesOfCP(tree,cp)
% FINDNODEOFCP is a recursive function which returns the nodes ids of the
% same input type and control points in a tree    
    if isempty(tree)
        return;
    end
    if tree.cp==cp
        nodes=tree.nodeid;
    else
        nodes=[];
    end
    node=[];
    if ~isempty(tree.kids)
        node{1}=findNodesOfCP(tree.kids{1},cp);
        node{2}=findNodesOfCP(tree.kids{2},cp);
    end
    for i=1:size(node,2)
        if ~isempty(node{i})
            nodes=[nodes,node{i}];
        end
    end
end
