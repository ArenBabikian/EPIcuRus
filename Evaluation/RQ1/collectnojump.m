% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
clear
close all
runs=1:1:50;

models=["regulators"];

requirementspermodels={{"R4"}};
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
                destfilename=strcat(model,requirement,algorithm);
                delete(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,destfilename,'jumps.txt'));
                destfid = fopen(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,destfilename,'jumps.txt'),'a+');
                for run=runs
                    path=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,'Run',num2str(run));
                    filename=dir(strcat(path,'/*jumps.txt'));
                    sourcefid = fopen(strcat(filename(1).folder,filesep,filename(1).name),'r');
                    source=textscan(sourcefid,'%s','Delimiter','\n');
                    fclose(sourcefid); 
                    if ~isempty(source{:})
                        fprintf(destfid,'%s\n', source{:}{1});
                    end
                end
            end
    end
end
