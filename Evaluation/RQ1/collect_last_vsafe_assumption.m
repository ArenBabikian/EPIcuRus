% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
clear
close all
runs=1:1:50;

models=["regulators"];

requirementspermodels={{'R1'}};
prefixes=["IP"];
algorithms=["IFBT_UR"];

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
                delete(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'last.txt'));
                destfid = fopen(strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,filename,'last.txt'),'a+');
                for run=runs
                    path=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run));
%                     last vsafe
                    filenames=dir(strcat(path,filesep,'validassumption*.qct'));
%                     plateau
%                     filenames=dir(strcat(path,filesep,'plateau.qct'));
                    if ~isempty(filenames)
                        validAssumptionName=filenames(end).name;
                        filename=strcat(path,filesep,validAssumptionName);
                        sourcefid = fopen(filename,'r');
                        source=textscan(sourcefid,'%s','Delimiter','\n');
                        fclose(sourcefid);
                        assumption=replace(source{:}{2},'all_k(k>= 0  and k<= 100  impl ','(');
                        assumption=replace(assumption,'{k}','1');
                        assumption=replace(assumption,'t1h','t1h1');
                        assumption=replace(assumption,'t2h','t2h1');
                        assumption=erase(assumption, 'assume ');
                        assumption=erase(assumption, ';');
                        fprintf(destfid,'%s\n', assumption); 
                    end
                                     
                end
            end
    end
end
