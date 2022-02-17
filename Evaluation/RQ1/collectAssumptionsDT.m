% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.clear
close all
runs=1:1:50;

models=["twotank"];

requirementspermodels={{"R7"}};
prefixes=["IP"];
algorithms=["DT"];

index=0;

for model=models

    index=index+1;
    allrequirements=requirementspermodels{index};
    
    for reqindex=1:size(allrequirements,2)
            requirement=allrequirements{reqindex};
            prefix=prefixes(index);
            for algorithm=algorithms
                disp(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm));
                filename=strcat(model,requirement,'IFBT_UR');
                delete(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'.txt'));
                destfid = fopen(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'.txt'),'a+');
                for run=runs
                    sourcefid = fopen(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,model,'R7','IFBT_URiteration_30.qct'),'r');
                    source=textscan(sourcefid,'%s','Delimiter','\n');
                    fclose(sourcefid);
                    %best=strjoin([extractBetween(replace(source{:}{end},'TL','TL1'),'assume(',')')]);
                    fprintf(destfid,'%s\n', source{:}{2});                  
                end
            end
    end
end
