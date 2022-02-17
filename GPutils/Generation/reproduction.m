% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function [currentsize,pop]=reproduction(pop,Best,currentsize)
%% reproduction selects a random individual from the previous population and copies it in the current population 
% Inputs:   Best: the best indivividuals selected from previous population
%           currentsize: the current index in the current population 
% Outputs:  pop: The current population after adding the individual
    rep=Best(1:end-1);
    pop(currentsize)=rep(randi(size(Best(1:end-1),2)));
end  
