Copyright © [2020] – [2021] University of Luxembourg.
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg.
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg.
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg.
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg.
function assumption=DT2QCT(assumToCheck,input_names,kmax,opt)
    refined={};
    count=0;
    for as = 1:size(assumToCheck,1)
        x=refineConstr(assumToCheck{as},opt.nbrControlPoints);
        if ~isempty(x)
            count=count+1;
            if contains(x,'and')
                refined{count}=strcat('(',x,')');
            else
                refined{count}=x;
            end
            if (opt.nbrControlPoints>1)
                mult_control_point_clause=Constr2QCT(refined(count),input_names,kmax,opt);
                refined{count}=strcat('(',mult_control_point_clause,')');
            end
        end
    end

    if ~isempty(refined) 
        if size(refined,2)>1
            assumption=strcat('assume (',strjoin(refined(~cellfun('isempty',refined)),{' or '}),');');
            if iscell(assumption)
                assumption=assumption{:};
            end
        else
            assumption=strcat('assume ',refined(~cellfun('isempty',refined)),';');
            if iscell(assumption)
                assumption=assumption{:};
            end
        end
        
    end
end
