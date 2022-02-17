% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function input=getInputsfromTree(tree,state)
% GETINPUTSFROMTREE returns the list of inputs generated in the tree
% INPUTS:
%   tree: the assumption tree 
%   state:  contains the operators list used for GP and other
%           GP items(i.e., the root type, the last id generated in a tree..) 
% OUTPUTS:
%   input: the list of inputs extracted from the tree
    input={};
    if isempty(tree)
        input={};
    else
        if state.isboolean==1
            if isempty(tree.kids)
                input={[tree.op,num2str(tree.cp)]};
            end
        else
            if  strcmp(tree.type,'aexp') && isempty(tree.kids)&& ~all(ismember(tree.op, '0123456789+-.eEdD')) % if it is an input signal 
                %concatenates the signal point with the control point.
                input={[tree.op,num2str(tree.cp)]};
            end
        end
        for k=1:length(tree.kids)
           input=union(input,getInputsfromTree(tree.kids{k},state));
        end
    end
end
