function [str,cp]=tree2qct(tree,cp,state)
% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
%TREE2QCT    Translates a tree into an assumption statment without considereing control points.
% INPUTS:
%   tree: the assumption tree to translate
%   cp: the control points associated to the input signals 
% OUTPUTS
%   str: the assumption statement 
%   cp: the control points associated to each conjunction in the assumption

    args=[];
    if isempty(tree)
        return;
    end
    if ~isempty(tree.kids)
        [args{1},cp]=tree2qct(tree.kids{1},cp,state);
    end
        str=convert2QCT(tree.op);
        if state.isboolean==1
            if isempty(tree.kids)
                str=[str,'of_k'];
                control_point=tree.cp;
                cp=[cp,control_point];
            end
            %str=[num2str(control_point),str]; % example : 2<
            
        else
            if strcmp(tree.type,'aexp') && isempty(tree.kids) && ~all(ismember(str, '0123456789+-.eEdD')) % if it is an input signal 
                str=[str,'of_k'];
            end          
            if strcmp(tree.type,'conjunction') && ~strcmp(tree.op,'and') % the node has inequality
                if ~isempty(tree.kids{1}.cp)
                    control_point=tree.kids{1}.cp;
                elseif ~isempty(tree.kids{2}.cp)
                    control_point=tree.kids{2}.cp;
                else
                    % in case: constant <= constant
                    control_point=-1;
                end
                %str=[num2str(control_point),str]; % example : 2<
                cp=[cp,control_point];
            end
         end
    if ~isempty(tree.kids) 
        [args{2},cp]=tree2qct(tree.kids{2},cp,state);
    end
    if ~isempty(args)
         str=['( ',args{1},' ',str,' ',args{2},' )'];
    end
end
