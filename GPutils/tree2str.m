function str=tree2str(tree,state)
% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
%TREE2STR Translates a tree into a string.
% INPUTS:
%   tree: the assumption tree
%   state: the GP state settings
% OUTPUTS:
%   str: the assumption extracted from the tree
    str=tree.op;
    if state.isboolean==1
        if isempty(tree.kids)
            str=[str,num2str(tree.cp)];
        end
    else
        if strcmp(tree.type,'aexp') && isempty(tree.kids) && ~all(ismember(str, '0123456789+-.eEdD')) % if it is an input signal 
            str=[str,num2str(tree.cp)];
        end
    end
    args=[];
    for k=1:length(tree.kids)
       args{k}=tree2str(tree.kids{k},state);
    end
    if ~isempty(args)
        str=[str,'( ',implode(args,' , '),' )'];
    end
end


