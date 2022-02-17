% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function nodes=findNodesOfType_ParentType(tree,type,parentType)
% FINDNODEOFTYPE_ParentType is a recursive function to return the nodes IDs of the
%  a given type and a given parent type
    if isempty(tree)
        return;
    end
    if strcmp(tree.type,type) && strcmp(tree.parentType,parentType)
        nodes=tree.nodeid;
    else
        nodes=[];
    end
    node=[];
    if ~isempty(tree.kids)
        node{1}=findNodesOfType_ParentType(tree.kids{1},type,parentType);
        node{2}=findNodesOfType_ParentType(tree.kids{2},type,parentType);
    end
    for i=1:size(node,2)
        if ~isempty(node{i})
            nodes=[nodes,node{i}];
        end
    end


end
