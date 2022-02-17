% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [tree,lastnode,nbrConj,nbrDisj]=makeBooleanTree(level,oplist,lastnode,type,parentType,parentCP,maxNbrConj,maxNbrDisj,nbrConj,nbrDisj,cp,opt)
%MAKETREE    Creates a syntax tree for boolean input signals
% INPUTS:   level: the curent level
%           oplist: the list op operators declared by the user in state
%           lastnode: the id of the last node created 
%           maxNbrConj: the max number of conjunctions 
%           nbrConj: the current number of conjunctions 
%           cp: the control point associated to the tree
% OUTPUTS:  tree: the genrated tree
%           lastnode: the id of the last node
if ~exist('lastnode')
   lastnode=0; 
end
thisnode=lastnode+1;

typed_index=find(strcmp(oplist(:,4),type));
conj_index=find(strcmp(oplist(:,1),'and')); % find the index of the conjunction operator
disj_index=find(strcmp(oplist(:,1),'or'));

% check type 
if level==1 
   % we must choose a terminal because of the level limitation
   typed_index_excep_disj=setdiff(1:size(oplist,1),disj_index); 
   typed_index_excep_conj=setdiff(typed_index_excep_disj,conj_index);
    ind=intrand(1,size(typed_index_excep_conj,2));
    op=typed_index_excep_conj(ind);
    if rand>0.5
        % this is a non terminal: choose to add 'not' randomly 
        tree.op=['not ',oplist{op,1}];
    else
        tree.op=oplist{op,1};
    end
    tree.cp=cp;
else
    if strcmp(type,'conjunction')
        typed_index_excep_conj=setdiff(typed_index,conj_index);
        if ( nbrConj>=maxNbrConj || (level==1) )
            ind=intrand(1,size(typed_index_excep_conj,2));
            op=typed_index_excep_conj(ind);
            tree.op=oplist{op,1}; 
            tree.cp=cp;
        else
            ind=intrand(1,size(typed_index_excep_conj,2));
            op=typed_index_excep_conj(ind);
            % if a new conjuction is selected, increment nbrConj
            if op==conj_index
                nbrConj=nbrConj+1;
            end
            if oplist{op,2}==0
                if rand>0.5
                    % this is a non terminal: choose to add 'not' randomly 
                    tree.op=['not ',oplist{op,1}];
                else
                    tree.op=oplist{op,1};
                end
                tree.cp=cp;
            else
                tree.op=oplist{op,1};
                tree.cp=[];
            end
        end
    else
        if ( nbrDisj>=maxNbrDisj || (level==2) )
            typed_index_excep_disj=setdiff(1:size(oplist,1),disj_index);
            if ( nbrConj>=maxNbrConj || (level==1) )
                typed_index_excep_conj=setdiff(typed_index_excep_disj,conj_index);
                ind=intrand(1,size(typed_index_excep_conj,2));
                try
                op=typed_index_excep_conj(ind);
                catch
                    disp('no options of operators left..');
                end
                if oplist{op,2}==0
                    if rand>0.5
                        % this is a non terminal: choose to add 'not' randomly 
                        tree.op=['not ',oplist{op,1}];
                    else
                        tree.op=oplist{op,1};
                    end
                    tree.cp=cp;
                else
                    tree.op=oplist{op,1};
                    tree.cp=[];
                end
            else
                ind=intrand(1,size(typed_index_excep_disj,2));
                op=typed_index_excep_disj(ind);
                % if a new conjuction is selected, increment nbrConj
                if op==conj_index
                    nbrConj=nbrConj+1;
                end
                if oplist{op,2}==0
                    if rand>0.5
                        % this is a non terminal: choose to add 'not' randomly 
                        tree.op=['not ',oplist{op,1}];
                    else
                        tree.op=oplist{op,1};
                    end
                    tree.cp=cp;
                else
                    tree.op=oplist{op,1};
                    tree.cp=[];
                end
            end
        else
            nbrDisj=nbrDisj+1;
            ind=intrand(1,size(typed_index,1));
            op=typed_index(ind);
            tree.op=oplist{op,1};
            tree.cp=[];
        end
    end
end

        
a=oplist{op,2}; % a = arity of the chosen op

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
    typeind=intrand(1,size(oplist{op,3}{i},2));
    type=oplist{op,3}{i}{typeind};
    parentType=oplist{op,4};
    cp=randi([1,opt.nbrControlPoints]);
    parentCP=tree.cp;
    [t,lastnode,nbrConj,nbrDisj]=makeBooleanTree(newlevel,oplist,thisnode,type,parentType,parentCP,maxNbrConj,maxNbrDisj,nbrConj,nbrDisj,cp,opt);   
    tree.level=t.level+1;
    tree.kids{i}=t;
    tree.nbrConj=nbrConj;
    tree.nbrDisj=nbrDisj;
    thisnode=lastnode+1;
end   
tree.nbrConj=nbrConj;
tree.nbrDisj=nbrDisj;
tree.type=oplist{op,4};
tree.nodes=thisnode-tree.nodeid+1;
tree.maxid=lastnode+1;
end
