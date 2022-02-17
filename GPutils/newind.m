function [ind,lastid]=newind(state,nbrConj,nbrDisj,opt,gp_opt)  
% NEWIND generates a new individual assumption
% Inputs:   state: contains the operators list used for GP and other
%           GP items(i.e., the root type, the last id generated in a tree..) 
%           nbrConj: Current number of conjuctions
%           Epicurus options
%           gp_opt: GP options
% Outputs:  
%   ind: the new individual generated
%   lastid: the id associated to the new individual
%   Copyright (C) 2003-2015 Sara Silva (sara@fc.ul.pt)
%   This file is part of the GPLAB Toolbox
% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.

    lastnode=0;
    lastid=state.lastid;
    level=gp_opt.max_depth;
    oplist=state.oplist;
    exactlevel=state.init;
    depthnodes=state.depthnodes;
    
    if state.disjunctionsExist==0
        roottype='conjunction';
    else
        if rand<0.5
            roottype='conjunction';
        else
            roottype='disjunction';
        end
    end
    parentType='';
    parentCP=[];
    maxNbrConj=gp_opt.maxNbrConj;
    maxNbrDisj=gp_opt.maxNbrDisj;
    ind=struct('id',lastid,'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',gp_opt.max_depth,'origin','');
    cp=randi([1,opt.nbrControlPoints]); 
    if state.isboolean==1
        [ind.tree,~,~,~]=makeBooleanTree(level,oplist,lastnode,roottype,parentType,parentCP,maxNbrConj,maxNbrDisj,nbrConj,nbrDisj,cp,opt);
    else
        [ind.tree,~,~,~]=maketree(level,oplist,exactlevel,depthnodes,lastnode,roottype,parentType,parentCP,maxNbrConj,maxNbrDisj,nbrConj,nbrDisj,cp,opt,gp_opt);
    end
    ind.tree=bfs(ind.tree,gp_opt.max_depth);
    ind.str=tree2str(ind.tree,state);
    ind.assum=tree2assum(ind.tree,state);
    [ind.qct,ind.cp]=tree2qct(ind.tree,[],state);
    ind.depth=getDepth(ind.tree);
end
