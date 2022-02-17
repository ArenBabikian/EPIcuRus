% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
% WRITETIME takes the file name and the time and writes the time in the file
function writetime(file,time)
    fid=fopen(file,'wt');
    fprintf(fid,'%s',num2str(time));
    fclose(fid);
end
