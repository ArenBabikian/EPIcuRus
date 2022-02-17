% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function nodes=findNodesOfType(tree,type)
% FINDNODEOFTYPE is a recursive function to return the nodes ids of the
% same input type in a tree
    if isempty(tree)
        return;
    end
    if strcmp(tree.type,type)
        nodes=tree.nodeid;
    else
        nodes=[];
    end
    node=[];
    if ~isempty(tree.kids)
        node{1}=findNodesOfType(tree.kids{1},type);
        node{2}=findNodesOfType(tree.kids{2},type);
    end
    for i=1:size(node,2)
        if ~isempty(node{i})
            nodes=[nodes,node{i}];
        end
    end
end
