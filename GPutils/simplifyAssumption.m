% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function simplifiedAssumption=simplifyAssumption(assumption)
%SIMPLIFYASSUMPTION  converts an assumption into symbolic
%expression, simplifies the expression 
% INPUTS:
%   assumption: an assumption string
%   simplifiedAssumption: the simplified assumption string
    simplifiedAssumption=assumption;
    if ~isempty(assumption)
        % replace and with & for strsym 
        editedAssumption=replace(assumption, ' and ', ' & ');
        editedAssumption=replace(editedAssumption, ' or ', ' | ');
        editedAssumption=replace(editedAssumption, ' not ', ' ~ ');
        editedAssumption=replace(editedAssumption, 'not ', '~ ');
        simplified=char(vpa(simplify(str2sym(editedAssumption)),5));
        symbolic=replace(simplified, ' & ', ' and ');
        symbolic=replace(symbolic, ' | ', ' or ');
        symbolic=replace(symbolic, '~', ' not ');
        if contains(symbolic,'''real''')
            simplifiedAssumption='';
        % Check if the simplification returns neither TRUE nor FALSE
        elseif strcmp(symbolic,'TRUE') || strcmp(symbolic,'FALSE')
            simplifiedAssumption='';
        else
            simplifiedAssumption=symbolic;
        end
    end
end
