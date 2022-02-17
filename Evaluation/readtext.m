% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function splitStr=readtext(textfile)
    fid  = fopen(textfile,'r');
    text = textscan(fid,'%s','Delimiter','','endofline','');
    fclose(fid);
    text = text{1}{1};
    splitStr = regexp(text,'{''variable'':*','split')';
end
