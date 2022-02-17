% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [pop,state]=initPop(state,size,opt,gp_opt)
%INITPOP    Creates the initial population
% INputs:   tsinput: the test suite values
%           ts_labels: the verdicts associated to the test suite
%           inputnames: the list of input names 
%           state: contains the operators list used for GP and other
%           size: the size of the population
%           GP items(i.e., the root type, the last id generated in a tree..)
%           gp_opt: GP options
% Outputs:  pop: the initial population
%           state: state modified - the last individual's id is updated 
    pop=struct('id',[],'tree',[],'str','','assum','','qct','','cp',[],'vsafe',[],'informative',[],'fitness',[],'depth',[],'origin','');
    nbrConj=0;
    nbrDisj=0;
    for i=1:size
        % generate a new individual
        [pop(i),~]=newind(state,nbrConj,nbrDisj,opt,gp_opt);
        pop(i).origin='init';
    end
    state.lastid=state.lastid+1;
end
