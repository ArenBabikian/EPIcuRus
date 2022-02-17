% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function op=convert2QCT(mfct)
%CONVERT2QCT converts a matlab operator function name into the corresponding operator symbol
    if (strcmp(mfct,'plus'))
        op='+';
    elseif (strcmp(mfct,'minus'))
        op='-';
    elseif (strcmp(mfct,'times'))
        op='*';
    elseif (strcmp(mfct,'le'))
        op='<=';
    elseif (strcmp(mfct,'ge'))
        op='>=';
    else
        op=mfct;
    end
end
