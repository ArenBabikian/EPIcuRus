% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function root_op = getRootOp(ind,node_index)
% GETROOTOP takes the individual ind and an array of the node indexes and returns the
% names of the root functions of the nodes
    root_op ={};
    for i=1:size(node_index,2)
       node=findnode(ind.tree,node_index(i)); 
       root_op{i}=node.op;
    end

end
