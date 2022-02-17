% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
clear
close all
runs=1:1:50;

models=["twotank"];

requirementspermodels={{"R1"}};
prefixes=["IP"];
algorithms=["GP"];

index=0;

for model=models

    index=index+1;
    allrequirements=requirementspermodels{index};
    
    for reqindex=1:size(allrequirements,2)
            requirement=allrequirements{reqindex};
            prefix=prefixes(index);
            for algorithm=algorithms
                disp(strcat('Benchmark/',model,filesep,requirement,filesep,'UR',filesep,algorithm));
                filename=strcat(model,requirement,algorithm);
                delete(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'.txt'));
                destfid = fopen(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'.txt'),'a+');
                for run=runs
                    foldername=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run));
                    if isfolder(foldername)
                        sourcefid = fopen(strcat(foldername,filesep,model,requirement,'UR.txt'),'r');
                        source=textscan(sourcefid,'%s','Delimiter','\n');
                        fclose(sourcefid);                    
                        fprintf(destfid,'%s\n', source{:}{end});     
                    end
                end
            end
    end
end
