function str=tree2assum(tree,state)
% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
%TREE2ASSUM    Translates a tree into an assumption by considereing control points.
% INPUTS:
%   tree: the assumption tree to translate
%   state: the state of GP settings
% OUTPUTS
%   str: the assumption statement 
    args=[];
    if isempty(tree)
        return;
    end
    if ~isempty(tree.kids)
        args{1}=tree2assum(tree.kids{1},state);
    end
        str=convert2QCT(tree.op);
        if state.isboolean==1
            if isempty(tree.kids)
                str=[str,num2str(tree.cp)];
            end
        else
            if strcmp(tree.type,'aexp') && isempty(tree.kids)&& ~all(ismember(str, '0123456789+-.eEdD')) % if it is an input signal 
                str=[str,num2str(tree.cp)];
            end
        end
    if ~isempty(tree.kids) 
        args{2}=tree2assum(tree.kids{2},state);
    end
    if ~isempty(args)
         str=['( ',args{1},' ',str,' ',args{2},' )'];
    end
end
