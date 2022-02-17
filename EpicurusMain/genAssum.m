function [assumptionArray,parent_constraints,interAssum] = genAssum(tv,Olt,oldA,bestA,inputnames,categorical,state,filePath,assume_options,gp_epicurus_options)
% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
%   genAssum learns an assumption such that the model restricetd by the assumption is likely to satisfy the requirement using the test suite.
%   The assumption generation is performed using either genetic programming, provided with a grammar to learn conditions that relate multiple 
%   signals by both arithmetic and relational operators, or using decision trees to learn simple conditions that relate multiple signals by only relational operators. 
% INPUTS
%   tv: the generated test suite 
%
%   Oldt: the previously generated test suite. if the search technique is DT, tv and Oldt will be merged and used for assumption generation
%   OldA: the prviously generated assumptions, used if the search technique
%   is GP or RS
%   inputnames: a string array of the input control points names. 
%               it serves as the parameter predictors names during the decision tree building 
% 
%   categorical: an array of the categorical inputs indexes
%               it serves as the parameter predictors names during the decision tree building 
%
% state: used when the search technique is GP or RS to set the state of the
% learning algorithm
%   - assume_options : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.
% OUTPUTS
%   assumptionArray: a cell array that contains the selected assumptions + information:
%                       C | probability estimate | leaf size | Parent node index | the Mean fitness at the leaf | importantFeature(if exists)
%                       Each row contains the information of one constraint C={c1 ^ c2 ^.. cn} where ci is a condition on one input
%                       Example of constraint C: ‘(input1 < 1) and (input2>= 10)’
%
%   parent_constraints: The parent constraints of the leaves associated with the selected assumptions assumptionArray.
%                       It can serve as a parameter in the function getRanges (genSuite) to get the next candidate input ranges
%                       on which the next test generation will be based. 
%
%   interAssum: a cell array of the intemediate assumptions generated + information
%               It serves as history
    assume_opt=assume_options();
    if strcmp(assume_opt.learningMethod,'DT')
        % Generate Assumptions using decision trees
        [assumptionArray,parent_constraints,interAssum] = dtGenAssum(tv,Olt,inputnames,categorical,assume_opt);
    else
        % Generate Assumptions using Gnetic Programming
        [assumptionArray,parent_constraints,interAssum]=gpGenAssum(tv,oldA,bestA,inputnames,state,filePath,categorical,assume_opt,gp_epicurus_options);
    end
    
end
