% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
clear
close all
runs=1:1:50;

models=["tustin"];

requirementspermodels={{"R4a"}};
prefixes=[""];
algorithms=["DT"];

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
                delete(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'1st.txt'));
                destfid = fopen(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'1st.txt'),'a+');
                for run=runs
                    valid=0;
                    validAssumptionName=['validassumption.qct'];
                    filename=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,validAssumptionName);
                    if isfile(filename)
                        valid=1;
                        sourcefid = fopen(filename,'r');
                        source=textscan(sourcefid,'%s','Delimiter','\n');
                        fclose(sourcefid);
                        %assumption=extractBetween(source{:}{2},'assume ( all_k(k>= 0  and k<= 100  impl',') );');
                        fprintf(destfid,'%s\n', source{:}{2}); 

                    end
                                     
                end
            end
    end
end
