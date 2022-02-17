% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
function writeQCT(assumption,qctfilename,kmax,opt)
%   WRITEQCT takes the assumption, the file name and kmax the simulation time
%   transtaled into QVtrace time. It writes the qct formula into the file.
%   The qct formula includes setting kmax, the assumption and the property.

    kmax=['set k_max=',num2str(kmax),';'];
    S = fileread(qctfilename);
    if strcmp(opt.learningMethod,'GP') && ~isempty(assumption)
        assumption_statment=['assume ( ',assumption,' );'];
    else
        assumption_statment=assumption;
    end
    S = [kmax, char(10),assumption_statment, char(10), S];
    FID = fopen(qctfilename, 'w');
    if FID == -1, error('Cannot open file %s', qctfilename); end
    fwrite(FID, strcat(S), 'char');
    fclose(FID);
end
