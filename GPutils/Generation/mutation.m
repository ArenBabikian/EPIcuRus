% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function ind=mutation(ind,id,state,ts_labels,ts,tsinputsMap,opt,gp_opt)
% MUTATION creates a new subtree and replaces a selected subtree with the
% new subtree
% INPUTS:   ind: the individual tree selected to mutate one of its subtrees
%           id: the current ID of the individual
%           state: contains the operators list used for GP and other
%           items(i.e.,root type)
%           tsinput: the test suite values
%           ts_labels: the verdicts associated to the test suite
%           inputnames: the list of input names
%           opt: Epicurus options
%           gp_opt: GP options
% Output:   ind: the new individual after mutation 
    x=intrand(1,nodes(ind.tree)); % mutation point
    subtree=findnode(ind.tree,x);
    % UPDATE: the subtree op is counted in the number of conjunction and
    % disjunctions:
    % conjunction => change nbrConj=subtree.nbrConj; to
    % nbrConj=subtree.nbrConj-1; of the the subtree op is AND
    % disjunctions => change nbrDisj=subtree.nbrDisj; to
    % nbrDisj=subtree.nbrDisj-1; of the the subtree op is OR
    if strcmp(subtree.op,'and')
        nbrConj=subtree.nbrConj; % the number of conjunctions from root until the subtree excep the subtree op
    else
       nbrConj=subtree.nbrConj; % the number of conjunctions from root until the subtree 
    end
    if strcmp(subtree.op,'or')
        nbrDisj=subtree.nbrDisj;
    else
        nbrDisj=subtree.nbrDisj;% the number of disjunctions from root until the subtree 
    end
    % Adding constraints on control points for type double
    if opt.nbrControlPoints>1
        if strcmp(subtree.type,'aexp') && ~isempty(subtree.parentCP)
            cp=subtree.parentCP;
        else
           cp=randi([1,opt.nbrControlPoints]);
        end
    else 
        if  all(ismember(subtree.op, '0123456789+-.eEdD'))
            cp=subtree.parentCP;
        elseif strcmp(subtree.type,'aexp') % record the cp of aexp exept constant
            cp=subtree.cp;
        else
            cp=randi([1,opt.nbrControlPoints]);
        end 
    end
    parentCP=subtree.parentCP;
    parentType=subtree.parentType;
    if strcmp(subtree.type,'conjunction') && strcmp(parentType,'conjunction')
            type='conjunction';
    elseif strcmp(subtree.type,'conjunction') || strcmp(subtree.type,'disjunction')
        if rand<0.5
             type='conjunction';
        else
             type='disjunction';
        end
    else
        type=subtree.type;
    end
    
    % generate new subtree
    if state.isboolean==1
        newtree=makeBooleanTree(subtree.level,state.oplist,x-1,type,parentType,parentCP,gp_opt.maxNbrConj,gp_opt.maxNbrDisj,nbrConj,nbrDisj,cp,opt);
    else
        newtree=maketree(subtree.level,state.oplist,state.init,state.depthnodes,x-1,type,parentType,parentCP,gp_opt.maxNbrConj,gp_opt.maxNbrDisj,nbrConj,nbrDisj,cp,opt,gp_opt);
    end
    nind.tree=newtree;
    ind.tree=swapnodes(ind.tree,nind.tree,x,1);
    ind.tree=bfs(ind.tree,gp_opt.max_depth);
    ind.str=tree2str(ind.tree,state);
    ind.assum=tree2assum(ind.tree,state);
    [ind.qct,ind.cp]= tree2qct(ind.tree,[],state);
    [ind.vsafe,ind.informative,ind.fitness]=computeFitness(ind,gp_opt.fitness,ts_labels,ts,tsinputsMap,state);
    ind.id=id;
    ind.depth=getDepth(ind.tree);
    ind.origin='mutation';
     % get new nbr of conjunctions 
    ind.tree.nbrConj=getNbrNodesWop(ind.tree,'and');
 % get new nbr of conjunctions 
    ind.tree.nbrDisj=getNbrNodesWop(ind.tree,'or');
end 
