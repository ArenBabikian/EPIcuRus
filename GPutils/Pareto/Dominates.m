% This file is part of GP-utils
% Copyright © [2020] – [2021] University of Luxembourg.
function b=Dominates(ind1,ind2)
    if (ind1.f1 > ind2.f1) 
        b=true;
    elseif (ind1.f1==ind2.f1) && (ind1.f2>ind2.f2)
        b=true;
    else
        b=false;
    end
end
