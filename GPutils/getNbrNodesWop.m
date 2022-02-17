% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function nodes=getNbrNodesWop(tree,op)
% FINDNODEOFTYPE_ParentType is a recursive function which returns the number of nodes of the
%  op = op in a tree
    if isempty(tree)
        return;
    end
    if strcmp(tree.op,op)
        nodes=1;
    else
        nodes=0;
    end
    node=[];
    if ~isempty(tree.kids)
        node{1}=getNbrNodesWop(tree.kids{1},op);
        node{2}=getNbrNodesWop(tree.kids{2},op);
    end
    for i=1:size(node,2)
        if ~isempty(node{i})
            nodes=nodes+node{i};
        end
    end


end
