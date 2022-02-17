% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
function sanity=check()
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
        sanity=1;
    elseif  ~isempty(find(~cellfun(@isempty,v)))
        sanity=0;
    else
        sanity=2;
    end         
    delete message.txt;
end
