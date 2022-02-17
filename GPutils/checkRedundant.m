% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [x1,x2]=checkRedundant(ind1,ind2)
%returns a valid crosspoints x1 and x2
% if the crosspoint is of type double or rand, check if the crosspoints are
% the same
% if the crosspoint is of type logical, check if the crosspoint subtrees
% are the same
% option to check the levels length of the crosspoints
% return empty x2 if one of the two statements is true
    x2=[];
    ind1.nodes=nodes(ind1.tree);
    ind2.nodes=nodes(ind2.tree);
    x1=intrand(1,ind1.nodes); % crosspoint1
    subtree1=findnode(ind1.tree,x1);
    while subtree1.nodes>3 
        x1=intrand(1,ind1.nodes); % crosspoint1
        subtree1=findnode(ind1.tree,x1);
    end
    subtrees_type= subtree1.type;
    nodes_with_type=findNodesOfType(ind2.tree,subtrees_type); % returns the nodes in ind2 with same type as subtree1
    if strcmp(subtree1.type,'aexp') 
        ops2=getRootOp(ind2,nodes_with_type);
        % get the elements of op2 different from subtree1.op 
        [~,idx]= setdiff(ops2, subtree1.op); % idx the index of node_with_type different to subtree1.op
        % get nodes_with_type of ops2_excluding_subtree1_op
        nodes_with_type_excluding_subtree1_op=nodes_with_type(idx);
        if ~isempty(nodes_with_type_excluding_subtree1_op)
            nd=1;
            while isempty(x2) && nd<=size(nodes_with_type_excluding_subtree1_op,2)
                x=nodes_with_type_excluding_subtree1_op(nd); % crosspoint2: pick a random index from nodes_with_type with different op root than the op in subtree1
                subtree2=findnode(ind2.tree,x);
                % todo: 3 should be replaced with state.maxlevel
                if subtree2.nodes<=3 
                    x2=x;
                end
                nd=nd+1;
            end 
        else
                    
            disp('No choice! two crosspoints roots are equal. Trying another individual..')
        end
    else
        nd=1;
        while isempty(x2) && nd<=size(nodes_with_type,2)
            x=nodes_with_type(nd); % crosspoint2: pick a random index from nodes_with_type
            subtree=findnode(ind2.tree,x);            
            if ~strcmp(tree2str(subtree1),tree2str(subtree)) && subtree.nodes<=3 
                x2=x;
            end
            nd=nd+1;
        end
        
    end
end
