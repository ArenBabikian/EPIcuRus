% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [ind1,ind2]=crossover(ind1,ind2,x1,x2,id,ts_labels,ts,tsinputsMap,state,gp_opt)
%CROSSOVER    Creates new individuals for the GPLAB algorithm by crossover. returns two new
%   individuals created by swaping subtrees of the two PARENTS 
%
%   Input arguments:
%       ind1 -  the parent 1
%       ind2 - parent2
%       x1 - the root node of the subtree of parent1 to be swapped 
%       x2 - the root node of the subtree of parent2 to be swapped 
%       id - the current node id in ind1
%       tsinput: the test suite values
%       ts_labels: the verdicts associated to the test suite
%       inputnames: the list of input names 
%       gp_opt: GP options
       
%   Output arguments:
%      ind1,ind2 - the two newly created individuals 


    % swap nodes in only one step:
    [ind1.tree,ind2.tree]=swapnodes(ind1.tree,ind2.tree,x1,x2);
    ind1.tree=bfs(ind1.tree,gp_opt.max_depth);
    ind2.tree=bfs(ind2.tree,gp_opt.max_depth);
    % get new nbr of conjunctions 
    ind1.tree.nbrConj=getNbrNodesWop(ind1.tree,'and');
    ind2.tree.nbrConj=getNbrNodesWop(ind2.tree,'and');
 % get new nbr of conjunctions 
    ind1.tree.nbrDisj=getNbrNodesWop(ind1.tree,'or');
    ind2.tree.nbrDisj=getNbrNodesWop(ind2.tree,'or');
    
    ind1.str=tree2str(ind1.tree,state);
    ind1.assum=tree2assum(ind1.tree,state);
    [ind1.qct,ind1.cp]=tree2qct(ind1.tree,[],state);
    [ind1.vsafe,ind1.informative,ind1.fitness]=computeFitness(ind1,gp_opt.fitness,ts_labels,ts,tsinputsMap,state);
    ind1.id=id;
    ind1.origin='crossover';
    ind1.depth=getDepth(ind1.tree);

    ind2.str=tree2str(ind2.tree,state);
    ind2.assum=tree2assum(ind2.tree,state);
    [ind2.qct,ind2.cp]=tree2qct(ind2.tree,[],state);
    [ind2.vsafe,ind2.informative,ind2.fitness]=computeFitness(ind2,gp_opt.fitness,ts_labels,ts,tsinputsMap,state);
    
    ind2.id=id+1;
    ind2.origin='crossover';
    ind2.depth=getDepth(ind2.tree);
end
