% This file is part of EPIcuRus
% Copyright © [2020] – [2021] University of Luxembourg.
function sanity=snCheck(qctfilename,kmax,opt)
% SNCHECK checks whether the property is satisfied or violated for all
% possible inputs
% INPUTS    qctfilename: the name of the qct file which contains the property to check 
%           kmax: the total simulation steps set in qvtrace
%           opt: Epicurus options
% OUTPUTS:  sanity
% sanity=1 : The property is satisfied for all possible input
% sanity =0: The property is violated for all possible input
% sanity=-1: the property is neither satisfied nor violated for all inputs
% check the property
    disp('Sanity check: checking the property..');
    originalqctPath=fullfile(fileparts(which([qctfilename,'original.qct'])),[qctfilename,'original.qct']);
    copyfile(originalqctPath,regexprep(originalqctPath,'original',''));
    qctPath=fullfile(fileparts(which([qctfilename,'.qct'])),[qctfilename,'.qct']);
    writeQCT('',qctPath,kmax,opt);
    copyfile(qctPath,'./qct.qct');
    checkingtimetic=tic;
    property_sanity=check();
    checkingtime=toc(checkingtimetic);
    if ~property_sanity
        disp('Violations are found');
    else
        sanity=1;
        disp('The property is satisfied for all possible input');
        return;
    end

    %% Check the negation of a property


    disp('Sanity check: checking the negation of the property..');
    fid = fopen([qctfilename,'original.qct'],'r');
    C=textscan(fid,'%s','Delimiter','\n');
    delete([qctfilename,'originalnegated.qct']);
    fidn= fopen([qctfilename,'originalnegated.qct'],'w');
    C{:}{end}=strcat('not( ',C{:}{end}(1:end-1),' );');
    for r=1:numel(C{:})
        fprintf(fidn,'%s\n',C{:}{r,1});
    end
    originalqctPath=fullfile(fileparts(which([qctfilename,'originalnegated.qct'])),[qctfilename,'originalnegated.qct']);
    copyfile(originalqctPath,regexprep(originalqctPath,'originalnegated',''));
    qctPath=fullfile(fileparts(which([qctfilename,'.qct'])),[qctfilename,'.qct']);
    writeQCT('',qctPath,kmax,opt);
    copyfile(qctPath,'./qct.qct');
    property_sanity=check();
    if ~property_sanity
        sanity=-1;
        disp('Violations are found');
    else
        sanity=0;
        disp('The property is violated for all possible input');
    end
end
