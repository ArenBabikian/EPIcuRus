% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
function valid=modelCheck(assumToCheck,qctfilename,opt,simTime)
% MODELCHECK joins the assumption to the requirement statement written in
% qct and when QVtrace is enabled, it checks on QVtrace if the qct formula is valid.
% 
% INPUT
%   - assumToCheck: the assumption containing the set of constraints {C1,C2,...Cn} associated with the different leaves
%   - qctfilename: the file name of the qct file 
%   - opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.
%   - simTime: the simulation time
% OUTPUT
%   valid: if the QVtrace check proves the assumption correct, valid=true else valid=false
    if opt.qvtraceenabled
        scriptPath=fullfile(fileparts(which('qvtrace.py')),'qvtrace.py');
        originalqctPath=fullfile(fileparts(which([qctfilename,'original.qct'])),[qctfilename,'original.qct']);
        kmax=(simTime/opt.SampTime);
        copyfile(originalqctPath,regexprep(originalqctPath,'original',''));
        qctPath=fullfile(fileparts(which([qctfilename,'.qct'])),[qctfilename,'.qct']);
        writeQCT(assumToCheck,qctPath,kmax,opt);
        copyfile(qctPath,'./qct.qct');
        turn='QvCheck';
        turnfile=fopen('turn.txt', 'w'); 
        fprintf(turnfile,'QvCheck'); 
        fclose(turnfile);
        timetic=tic;
        disp('Waiting that QVtrace finishes the analysis');
        while(~strcmp(turn,'Matlab'))
            pause(1)
            turnfile=fopen('turn.txt', 'r'); 
            turn=fgetl(turnfile); 
            fclose(turnfile);
        end
        qvtraceTime=toc(timetic);
        disp(['qvtrace time: ',num2str(qvtraceTime)]);
        disp('QVtrace ended');
        msgfid=fopen('message.txt', 'r'); 
        message = textscan(msgfid,'%s','delimiter','\n');
        fclose(msgfid);
        noV=strfind(message{1},': No violations are possible');
        v=strfind(message{1},': Violations are possible');
        if ~isempty(find(~cellfun(@isempty,noV)))
            valid=1;
        elseif  ~isempty(find(~cellfun(@isempty,v)))
            valid=0;
        else
            valid=2;
        end         
        delete message.txt;
    else
        valid=0;
    end
end
