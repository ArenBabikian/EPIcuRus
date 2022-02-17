% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [tree,lastnode,nbrConj,nbrDisj]=makeHybridTree(level,oplist,init,depthnodes,lastnode,type,parentType,parentCP,maxNbrConj,maxNbrDisj,nbrConj,nbrDisj,cp,opt,gp_opt)
%MAKETREE    Creates a hybrid representation tree with boolean and real
%input signals
% INPUTS:   level: the curent level
%           oplist: the list op operators declared by the user in state
%           init: specifies whether the current step is initialsation or
%           not
%           depthnodes: specifies whether the tree generation will be performed based on the
%           depth
%           lastnode: the id of the last node created 
%           type: the type of the tree generated 
%           maxNbrConj: the max number of conjunctions 
%           nbrConj: the current number of conjunctions 
%           cp: the control point associated to the tree
%           opt: Epicurus options
%           gp_opt: GP options
% OUTPUTS:  tree: the genrated tree
%           lastnode: the id of the last node
if ~exist('lastnode')
   lastnode=0; 
end
thisnode=lastnode+1;

typed_index=find(strcmp(oplist(:,4),type)); % terminals and non-terminals associated with the type type 
conj_index=find(strcmp(oplist(:,1),'and')); % find the index of the conjunction operator
disj_index=find(strcmp(oplist(:,1),'or'));
op=[];
if strcmp(type,'0')
    % if type 0 (threashold), force '0'
    op=find(strcmp(oplist(:,1),'0'));
    tree.op='0';
    tree.cp=[];
else    
    if init   
        % init level: the first node to generate 
       % we must choose a non terminal that has the root type.   
        nonTerminals_index= find([oplist{:,2}]~=0);
        nonTerminal_rootType_index=find(strcmp(oplist(nonTerminals_index,4),type)); % nonTerminal_rootType_index gives all indices of non terminals with root type
        ind=intrand(1,size(nonTerminals_index(nonTerminal_rootType_index),2)); % choose one at random 
        if typed_index(ind)==conj_index
            nbrConj=nbrConj+1;
        end 
        if typed_index(ind)==disj_index
            nbrDisj=nbrDisj+1;
        end 
        op=nonTerminals_index(nonTerminal_rootType_index(ind));
        tree.op=oplist{op,1};
        tree.cp=[];
        init=0;
        % added condition due to error:  Undefined function or variable 'op'.
    elseif level==1 
        % we must choose a terminal because of the level limitation
        terminals_index= find([oplist{:,2}]==0);
        terminalType_index=find(strcmp(oplist(terminals_index,4),type));
        ind=intrand(1,size(terminals_index(terminalType_index),2)); % choose one at random 
        if rand>0.5
            % input
            op=terminals_index(terminalType_index(ind));
            tree.op=oplist{op,1};
            tree.cp=cp;
        else
            % Constant
            % the random value of the constant should be between min and max
            min = gp_opt.minRand;
            max = gp_opt.maxRand;
            r = (max-min).*rand + min;
            tree.op=num2str(r);
            tree.cp=[];
        end

    else
        % check type 
        % check maximum number of conjuctions, if reached or the level is <=2, no more conjunction
        % should be generated
        if strcmp(type,'conjunction') && ( nbrConj>=maxNbrConj || (level==2) )
            typed_index_excep_conj=setdiff(typed_index,conj_index);
            ind=intrand(1,size(typed_index_excep_conj,1));
            op=typed_index_excep_conj(ind);
            tree.op=oplist{op,1};
            tree.cp=[];
        elseif strcmp(type,'conjunction')  
            ind=intrand(1,size(typed_index,1));
            % if a new conjuction is selected, increment nbrConj
            if typed_index(ind)==conj_index
                nbrConj=nbrConj+1;
            end 
            op=typed_index(ind);
            tree.op=oplist{op,1};
            tree.cp=[];
            % if the type of the node is double, choose with equal probabilty
            % between a terminal(input) and nonterminal(minus, +..)
        elseif strcmp(type,'disjunction') && ( nbrDisj>=maxNbrDisj || (level==2) )
            type='conjunction';
            typed_index=find(strcmp(oplist(:,4),type));
            if ( nbrConj>=maxNbrConj || (level==2) )                            
                typed_index_excep_conj=setdiff(typed_index,conj_index);
                ind=intrand(1,size(typed_index_excep_conj,1));
                op=typed_index_excep_conj(ind);
                tree.op=oplist{op,1};
                tree.cp=[];
            else 
                ind=intrand(1,size(typed_index,1));
                % if a new conjuction is selected, increment nbrConj
                if typed_index(ind)==conj_index
                    nbrConj=nbrConj+1;
                end 
                op=typed_index(ind);
                tree.op=oplist{op,1};
                tree.cp=[];
            end
        elseif strcmp(type,'disjunction') && ( nbrDisj<maxNbrDisj && (level>2) ) 
            ind=intrand(1,size(typed_index,1));
            % if a new disj is selected, increment nbrDisj
            if typed_index(ind)==disj_index
                nbrDisj=nbrDisj+1;
            end 
            op=typed_index(ind);
            tree.op=oplist{op,1};
            tree.cp=[];
            % if the type of the node is double, choose with equal probabilty
            % between a terminal(input) and nonterminal(minus, +..)
        else
        % if strcmp(type,'aexp')?
            typed_index_term=find(strcmp(oplist(:,4),type) & cellfun(@(x)x == 0,oplist(:,2)));
            typed_index_non_term=find(strcmp(oplist(:,4),type) & cellfun(@(x)x == 2,oplist(:,2)));
            % choose with equal prob between terminal(input) and nonterminal(minus, +..)
            if rand>0.5
                %  terminal : it can be constant or aexp
                % choose with equal prob between them
                if rand>0.5
                    % aexp
                    ind=intrand(1,size(typed_index_term,1));
                    op=typed_index_term(ind);
                    tree.op=oplist{op,1};
                    tree.cp=cp;
                else
                    % Constant
                    % the random value of the constant should be between min and max
                    min = gp_opt.minRand;
                    max = gp_opt.maxRand;
                    r = (max-min).*rand + min;
                    tree.op=num2str(r);
                    tree.cp=[];
                end
            else
                % non terminal 
                ind=intrand(1,size(typed_index_non_term,1));
                op=typed_index_non_term(ind);
                tree.op=oplist{op,1};
                tree.cp=cp;
            end        
        end
    end    
end
if ~isempty(op)
    a=oplist{op,2}; % a = arity of the chosen op
    tree.type=oplist{op,4};
else
    % arity of constants
    a=0;
end
% generate branches:

tree.kids=[];
tree.nodeid=thisnode;
tree.level=level;
tree.parentType=parentType;
tree.parentCP=parentCP;
tree.nbrConj=nbrConj;
tree.nbrDisj=nbrDisj;
% if there is a next branch, define level limitation for it:
if a~=0
   level=level-1; % discount the node (or depth level) just used
end

% now generate branches (if a>0, ie, non terminal) with new level limitation:
for i=1:a
    newlevel=level;
    % in case of two possible types, choose with equal prob between types.Example: 'double' and 'rand'
    typeind=intrand(1,size(oplist{op,3}{i},2));
    type=oplist{op,3}{i}{typeind};
    parentType=oplist{op,4};
    parentCP=tree.cp;
    %type=oplist{op,3}{i};
    if strcmp(tree.type,'aexp')
        cp=tree.cp;
    end 
    [t,lastnode,nbrConj,nbrDisj]=maketree(newlevel,oplist,init,depthnodes,thisnode,type,parentType,parentCP,maxNbrConj,maxNbrDisj,nbrConj,nbrDisj,cp,opt,gp_opt);   
    tree.level=t.level+1;
    tree.kids{i}=t;
    tree.nbrConj=nbrConj;
    tree.nbrDisj=nbrDisj;
    thisnode=lastnode+1;
end   
tree.nbrConj=nbrConj;
tree.nbrDisj=nbrDisj;
if isempty(op) % it is a constant
    tree.type='aexp';
else
    tree.type=oplist{op,4};
end
tree.nodes=thisnode-tree.nodeid+1;
tree.maxid=lastnode+1;
end
