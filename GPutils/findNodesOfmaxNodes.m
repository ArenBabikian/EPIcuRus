% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function nodes=findNodesOfmaxNodes(tree,maxNodes)
% FINDNODEOFMAXNODES is a recursive function which returns the root node ids of the
% subtrees that contain less than or equal maxNodes
    if isempty(tree)
        return;
    end
    if tree.nodes<=maxNodes
        nodes=tree.nodeid;
    else
        nodes=[];
    end
    node=[];
    if ~isempty(tree.kids)
        node{1}=findNodesOfmaxNodes(tree.kids{1},maxNodes);
        node{2}=findNodesOfmaxNodes(tree.kids{2},maxNodes);
    end
    for i=1:size(node,2)
        if ~isempty(node{i})
            nodes=[nodes,node{i}];
        end
    end
end
