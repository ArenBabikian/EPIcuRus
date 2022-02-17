% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [x1,x2]= chooseCrosspoints(ind1,ind2,common_cps,gp_opt,opt)
% CHOOSECROSSPOINTS takes two individuals and chooses the crosspoints that
% are allowed in the crossover
% returns the nodes ids to be swapped in both individuals ind1 and ind2
% INPUTS:   ind1: the tree of the Parent1
%           ind2: the tree of the Parent2
%           opt: GP options
% OUTPUTS:  x1: the root node index of the selected subtree from parent1
%           x2: the root node index of the selected subtree from parent2
    if ~isempty(common_cps)
        ind1.nodes=nodes(ind1.tree); 
        ind2.nodes=nodes(ind2.tree);
        nodes_with_max_nodes=1:ind1.nodes;
        % Remove the nodes of type 0. We don't apply genetic operators on
        % them        
        nodes_with_type_0=findNodesOfType(ind1.tree,'0');
        nodes_with_max_nodes_except_0=setdiff(nodes_with_max_nodes,nodes_with_type_0);
        
        if opt.nbrControlPoints>1
            % for multiple control points:
            % randomly select a control point from the common control
            % points of the two parents, then find all the nodes associated to that control point
            nodes_with_max_nodes_and_cp=nodes_with_max_nodes_except_0;
        else
            % for single control points, there is no constraint on control points.
            % only constrain maximum number of nodes
            nodes_with_max_nodes_and_cp=nodes_with_max_nodes_except_0;
        end
        % choose the root node randomly from the constrained nodes 
        x1=nodes_with_max_nodes_and_cp(randi(size(nodes_with_max_nodes_and_cp,2))); % crosspoint1

        subtree1=findnode(ind1.tree,x1);
        subtrees_type= subtree1.type;
        
         if opt.nbrControlPoints>1
             parentcp1=subtree1.parentCP;
         end

        if strcmp(subtree1.type,'aexp')
           
            % Types double and rand can be swapped
            nodes_with_type=findNodesOfType(ind2.tree,'aexp');
            
            if opt.nbrControlPoints>1 && ~isempty(parentcp1)
                nodes_with_different_cp=[];
                for c=1:opt.nbrControlPoints
                    nodes_with_different_cp=[nodes_with_different_cp,findNodesOfCP(ind2.tree,c)];
                end
                nodes_with_no_cp=setdiff(nodes_with_type,nodes_with_different_cp); 
                nodes_with_type_cp=findNodesOfCP(ind2.tree,parentcp1);
                if ~isempty(nodes_with_no_cp) && ~isempty(nodes_with_type_cp)
                    nodes_with_type_and_cp=union(nodes_with_no_cp,nodes_with_type_cp);
                elseif isempty(nodes_with_no_cp)
                    nodes_with_type_and_cp=nodes_with_type_cp;
                elseif isempty(nodes_with_type_cp)
                    nodes_with_type_and_cp=nodes_with_no_cp;
                else
                    nodes_with_type_and_cp=[];
                end
                    
               
            else
               
                nodes_with_type_and_cp=nodes_with_type;
            end

        else
           if strcmp(subtrees_type,'conjunction') % tree1 is conjunction =>
               if strcmp(subtree1.parentType,'conjunction')
                   %only allowed nodes from tree2 are: node of (type conjunction)
                                    
                   nodes_with_type_and_cp= findNodesOfType(ind2.tree,'conjunction');
                   % if maxNbrConj is reached => nodes with op 'and' are not allowed  
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
                            % Max conj exceeded ! remove the node from allowed nodes
                            nodes_with_type_and_cp=setdiff(nodes_with_type_and_cp,nodes_with_type_and_cp_original(node));
                        end
                   end
               else
                   %strcmp(subtrees_parent_type,'disjunction')
               % allowed nodes from tree2 are: (type disjunction) OR (type conjunction) 
                   conjunctions2= findNodesOfType(ind2.tree,'conjunction');
                   disjunctions2= findNodesOfType(ind2.tree,'disjunction');
                   nodes_with_type_and_cp=[disjunctions2,conjunctions2];
                   % if maxNbrConj is reached => nodes with op 'and' are not allowed 
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
                            % Max disj exceeded ! remove the node from alloed nodes
                            nodes_with_type_and_cp=setdiff(nodes_with_type_and_cp,nodes_with_type_and_cp_original(node));
                        end
                   end
               end
               % get the nodes from tree2 of type conjunction OR (type disjunction and psrent type disjunction)
           else %strcmp(subtrees_type,'disjunction')
                % only allowed nodes from tree2 are: node of (type disjunction) OR (type conjunction AND parent2 type disjunction)
              disjunctions2= findNodesOfType(ind2.tree,'disjunction');
              
              conjunctions2=findNodesOfType_ParentType(ind2.tree,'conjunction','disjunction');
              nodes_with_type_and_cp=[disjunctions2,conjunctions2];
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
        end 
        % ~strcmp(subtree1.type,'logical') has been replaced with more generic condition to private + - * from entering if 
        % subtree1 isempty(subtree1.kids)
        if isempty(subtree1.kids)
            % get roots op of nodes_with_type
            %ops2={'a','b'} . cp2={'1','2'} . => ops={'a1'}    {'b2'}
            ops2=getRootOp(ind2,nodes_with_type_and_cp); 
            cp2=getRootCP(ind2,nodes_with_type_and_cp);
            ops=strcat(ops2,cp2);
            % idx: all ops from ops2 <> subtree1.op (including the control point)
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
    else
        x1=[];
        x2=[];
    end
end
