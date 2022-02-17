% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [x1,x2]= chooseCrosspointsForBooleans(ind1,ind2,gp_opt)
% CHOOSECROSSPOINTS takes two individuals and chooses the crosspoints that
% are allowed in the crossover
% returns the nodes ids to be swapped in both individuals ind1 and ind2
% INPUTS:   ind1: the tree of the Parent1
%           ind2: the tree of the Parent2
%           opt: GP options
% OUTPUTS:  x1: the root node index of the selected subtree from parent1
%           x2: the root node index of the selected subtree from parent2

        ind1.nodes=nodes(ind1.tree); 
        ind2.nodes=nodes(ind2.tree);

        nodes_with_max_nodes_and_cp=1:ind1.nodes;
        % choose the root node randomly from the constrained nodes 
        x1=nodes_with_max_nodes_and_cp(randi(size(nodes_with_max_nodes_and_cp,2))); % crosspoint1

        subtree1=findnode(ind1.tree,x1);
        subtrees_type= subtree1.type;
       
       if strcmp(subtrees_type,'conjunction') % tree1 is conjunction =>
           if strcmp(subtree1.parentType,'conjunction')
               %only allowed nodes from tree2 are: node of (type conjunction)
               nodes_with_type_and_cp= findNodesOfType(ind2.tree,'conjunction');
                % if maxNbrConj is reached => remove node with op 'and' from list of allowed nodes 
                   % constraints on maxNbrConj
                   nodes_with_type_and_cp_original=nodes_with_type_and_cp;
                   for node=1 : size(nodes_with_type_and_cp_original,2)
                        subtree2=findnode(ind2.tree,nodes_with_type_and_cp_original(node));
                        nbrConj_Subtree2=getNbrNodesWop(subtree2,'and');
                        nbrConj_Subtree1=getNbrNodesWop(subtree1,'and');
                        nbrConj_tree2=getNbrNodesWop(ind2.tree,'and');
                        nbrConj_tree1=getNbrNodesWop(ind1.tree,'and');
                        nbrConj_NewSubtree1=nbrConj_Subtree2+(nbrConj_tree1-nbrConj_Subtree1);
                        nbrConj_NewSubtree2=nbrConj_Subtree1+(nbrConj_tree2-nbrConj_Subtree2);
                        if nbrConj_NewSubtree1 > gp_opt.maxNbrConj || nbrConj_NewSubtree2 > gp_opt.maxNbrConj
                            % Max conj exceeded ! remove the node from alloed nodes
                            nodes_with_type_and_cp=setdiff(nodes_with_type_and_cp,nodes_with_type_and_cp_original(node));
                        end
                   end
           else

               nodes_with_type_and_cp=1:ind2.nodes;
               
               % if maxNbrConj is reached => remove node with op 'and' from list of allowed nodes 
                   % constraints on maxNbrConj
                   nodes_with_type_and_cp_original=nodes_with_type_and_cp;
                   for node=1 : size(nodes_with_type_and_cp_original,2)
                        subtree2=findnode(ind2.tree,nodes_with_type_and_cp_original(node));
                        nbrConj_Subtree2=getNbrNodesWop(subtree2,'and');
                        nbrConj_Subtree1=getNbrNodesWop(subtree1,'and');
                        nbrConj_tree2=getNbrNodesWop(ind2.tree,'and');
                        nbrConj_tree1=getNbrNodesWop(ind1.tree,'and');
                        nbrConj_NewSubtree1=nbrConj_Subtree2+(nbrConj_tree1-nbrConj_Subtree1);
                        nbrConj_NewSubtree2=nbrConj_Subtree1+(nbrConj_tree2-nbrConj_Subtree2);
                        if nbrConj_NewSubtree1 > gp_opt.maxNbrConj || nbrConj_NewSubtree2 > gp_opt.maxNbrConj
                            % Max conj exceeded ! remove the node from alloed nodes
                            nodes_with_type_and_cp=setdiff(nodes_with_type_and_cp,nodes_with_type_and_cp_original(node));
                        end
                   end
                   % if maxNbrDisj is reached => remove node with op 'or' from list of allowed nodes 
                   % constraints on maxNbrDisj
                   nodes_with_type_and_cp_original=nodes_with_type_and_cp;
                   for node=1 : size(nodes_with_type_and_cp_original,2)
                        subtree2=findnode(ind2.tree,nodes_with_type_and_cp_original(node));
                        nbrDisj_Subtree2=getNbrNodesWop(subtree2,'or');
                        nbrDisj_Subtree1=getNbrNodesWop(subtree1,'or');
                        nbrDisj_tree2=getNbrNodesWop(ind2.tree,'or');
                        nbrDisj_tree1=getNbrNodesWop(ind1.tree,'or');
                        nbrDisj_NewSubtree1=nbrDisj_Subtree2+(nbrDisj_tree1-nbrDisj_Subtree1);
                        nbrDisj_NewSubtree2=nbrDisj_Subtree1+(nbrDisj_tree2-nbrDisj_Subtree2);
                        if nbrDisj_NewSubtree1 > gp_opt.maxNbrDisj || nbrDisj_NewSubtree2 > gp_opt.maxNbrDisj
                            % Max conj exceeded ! remove the node from alloed nodes
                            nodes_with_type_and_cp=setdiff(nodes_with_type_and_cp,nodes_with_type_and_cp_original(node));
                        end
                   end

           end
           % get the nodes from tree2 of type conjunction OR (type disjunction and psrent type disjunction)
       else %strcmp(subtrees_type,'disjunction')
            % only allowed nodes from tree2 are: node of (type disjunction) OR (type conjunction AND parent2 type disjunction)
          % REMOVED 14 AUG
               %nodes_with_type_and_cp=nodes_with_max_nodes2;
               %REPLACED by
               nodes_with_type_and_cp=1:ind2.nodes;
            % if maxNbrConj is reached => remove node with op 'and' from list of allowed nodes 
                   % constraints on maxNbrConj
                   nodes_with_type_and_cp_original=nodes_with_type_and_cp;
                   for node=1 : size(nodes_with_type_and_cp_original,2)
                        subtree2=findnode(ind2.tree,nodes_with_type_and_cp_original(node));
                        nbrConj_Subtree2=getNbrNodesWop(subtree2,'and');
                        nbrConj_Subtree1=getNbrNodesWop(subtree1,'and');
                        nbrConj_tree2=getNbrNodesWop(ind2.tree,'and');
                        nbrConj_tree1=getNbrNodesWop(ind1.tree,'and');
                        nbrConj_NewSubtree1=nbrConj_Subtree2+(nbrConj_tree1-nbrConj_Subtree1);
                        nbrConj_NewSubtree2=nbrConj_Subtree1+(nbrConj_tree2-nbrConj_Subtree2);
                        if nbrConj_NewSubtree1 > gp_opt.maxNbrConj || nbrConj_NewSubtree2 > gp_opt.maxNbrConj
                            % Max conj exceeded ! remove the node from alloed nodes
                            nodes_with_type_and_cp=setdiff(nodes_with_type_and_cp,nodes_with_type_and_cp_original(node));
                        end
                   end
                   % if maxNbrDisj is reached => remove node with op 'or' from list of allowed nodes 
                   % constraints on maxNbrDisj
                   nodes_with_type_and_cp_original=nodes_with_type_and_cp;
                   for node=1 : size(nodes_with_type_and_cp_original,2)
                        subtree2=findnode(ind2.tree,nodes_with_type_and_cp_original(node));
                        nbrDisj_Subtree2=getNbrNodesWop(subtree2,'or');
                        nbrDisj_Subtree1=getNbrNodesWop(subtree1,'or');
                        nbrDisj_tree2=getNbrNodesWop(ind2.tree,'or');
                        nbrDisj_tree1=getNbrNodesWop(ind1.tree,'or');
                        nbrDisj_NewSubtree1=nbrDisj_Subtree2+(nbrDisj_tree1-nbrDisj_Subtree1);
                        nbrDisj_NewSubtree2=nbrDisj_Subtree1+(nbrDisj_tree2-nbrDisj_Subtree2);
                        if nbrDisj_NewSubtree1 > gp_opt.maxNbrDisj || nbrDisj_NewSubtree2 > gp_opt.maxNbrDisj
                            % Max conj exceeded ! remove the node from alloed nodes
                            nodes_with_type_and_cp=setdiff(nodes_with_type_and_cp,nodes_with_type_and_cp_original(node));
                        end
                   end
       end
                
       
        if isempty(subtree1.kids)
            % get roots op of nodes_with_type
             %ops2={'a','b'} . cp2={'1','2'} . => ops={'a1'}    {'b2'}
            ops2=getRootOp(ind2,nodes_with_type_and_cp); 
            cp2=getRootCP(ind2,nodes_with_type_and_cp);
            ops=strcat(ops2,cp2);
            % idx: all ops from ops2 <> subtree1.op
            [~,idx]= setdiff(ops, [subtree1.op,subtree1.cp]);
            % nodes inexes refer to idx
            nodes_with_type_excluding_subtree1_op=nodes_with_type_and_cp(sort(idx));
            candidate_nodes=nodes_with_type_excluding_subtree1_op;
        else
            candidate_nodes=nodes_with_type_and_cp;
        end
        x2=[];
        if ~isempty(candidate_nodes)   
            nd=1;   
            % pick the first random subtree allowed  
            shuffled_candidate_nodes=shuffle(candidate_nodes);
            while nd <= size(shuffled_candidate_nodes,2) && isempty(x2)
                x=shuffled_candidate_nodes(nd); 
                subtreeX=findnode(ind2.tree,x);
                if getDepth(subtreeX) <= subtree1.level && getDepth(subtree1) <= subtreeX.level
                    x2=x;
                end
                nd=nd+1;
            end

        end        

end
