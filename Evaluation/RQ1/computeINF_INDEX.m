% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function inf_index= computeINF_INDEX(file1,file2)
% we need a text file which contains the list of assumptions of one run:
% one assumption per iteration
    countMoreInf=0;
    countLessInf=0;
    countNonComp=0;
    fid1=fopen(file1,'r');
    assumptions1=textscan(fid1,'%s','Delimiter','\n');
    fclose(fid1);
    fid2=fopen(file2,'r');
    assumptions2=textscan(fid2,'%s','Delimiter','\n');
    fclose(fid2);
    disp([file1,' vs. ',file2]);
    for assumption1 = 1: size(assumptions1{:},1)
        % Compare assumption with all assumptions of  assumptions2
        for assumption2=1: size(assumptions2{:},1)
            % returns 1 if param1 is more informative than param2
            % returns 0 if param1 is less informative than param2
            % returns -1 if param1 and param2 are not comparable
            try
                isMoreInf=isMoreInformative(assumptions1{:}{assumption1},assumptions2{:}{assumption2});
            catch
                isMoreInf=-1;
            end
            if isMoreInf==1
                countMoreInf=countMoreInf+1;
            elseif isMoreInf==0
                countLessInf=countLessInf+1;
            else
                countNonComp=countNonComp+1;
            end
        end
    end
    inf_index=[countMoreInf,countLessInf,countNonComp];  
    disp(countMoreInf);
    disp(countLessInf);
    disp(countNonComp);
end
