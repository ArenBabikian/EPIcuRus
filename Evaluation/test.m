% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
clear
close all
runs=1:1:45;

models=["twotank"];

requirementspermodels={{"R7"}};
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
                first_valid_iteration=0;
                for run=runs
                    iteration=1;
                    valid=0;
                    while iteration<=20 && valid==0
                        validAssumptionName=['validassumption',num2str(iteration),'.qct'];
                        filename=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,validAssumptionName);
                        if isfile(filename)
                            valid=1;
                            first_valid_iteration=first_valid_iteration+iteration;
                        else
                            valid=0;
                        end
                        iteration=iteration+1;
                    end
                                     
                end
                disp(['valid assumption is found at iteration: ',num2str(first_valid_iteration)]);
            end
    end
end
