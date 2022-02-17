% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
% writeAssum takes the execution time during one iteration and the files name and
% writes the execution time to the text file.

function  writeAssumptionsOfRun(assumption,file)    
    fid=fopen([file,'.txt'],'a');
    fprintf(fid,'%s\n',assumption);
    fclose(fid);
end
