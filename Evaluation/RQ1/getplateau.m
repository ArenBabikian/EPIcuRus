% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function plateau=getplateau()

clear
close all
runs=1:1:50;

models=["twotank"];

requirementspermodels={{"R8"}};
prefixes=["IP"];
algorithms=["RS"];
ConvMax=3;
index=0;

for model=models

    index=index+1;
    allrequirements=requirementspermodels{index};
    
    for reqindex=1:size(allrequirements,2)
            requirement=allrequirements{reqindex};
            prefix=prefixes(index);
            for algorithm=algorithms
                disp(strcat('Benchmark/',model,filesep,requirement,filesep,'UR',filesep,algorithm));
                for run=runs
                    % get last iteration
                    path=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run));
                    if isfolder(path)
                        filenames=dir(strcat(path,filesep,'*iteration_*.qct'));
                        if ~isempty(filenames)
                            validAssumptionName=filenames(end).name;
                            lastiteration=str2double(extractBetween(validAssumptionName,'_','.qct'));
                        end


                        plateau=0;
                        path=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,'Run',num2str(run),filesep);
                        delete(strcat(path,'/*nojumps.txt'));
                        filename=dir(strcat(path,'/*jumps.txt'));
                        if ~isempty(filename)
                            sourcefid = fopen(strcat(filename(1).folder,filesep,filename(1).name),'r');
                            source=textscan(sourcefid,'%s','Delimiter','\n');
                            fclose(sourcefid);
                            if ~isempty(source{:})
                                jumps=strsplit(source{:}{1});
                                if ~isempty(jumps)
                                    j=1;
                                    % if first jump is >= max, the plateau is reached from
                                    % the 1st iteration

                                    if str2double(jumps{j}) >= ConvMax || numel(jumps)==1
                                           plateau=jumps{j};
                                    else
                                        % check if the plateau is reached later
                                        while j < numel(jumps) && plateau==0
                                            j=j+1;
                                           if str2double(jumps{j})-str2double(jumps{j-1}) >= ConvMax
                                               plateau=jumps{j-1};
                                           end

                                        end 
                                        % check if the last jump is a plateau
                                        if lastiteration-jumps{j} >= ConvMax
                                            plateau=jumps{j};
                                        end
                                    end
                                else
                                    plateau=1;
                                end
                            end

                            iteration=plateau;
                       
                            while ~isfile(strcat(path,'validassumption',num2str(iteration),'.qct')) && iteration>0
                                iteration=iteration-1;
                            end
                            if iteration~=0
                                disp(['plateau detected at run: ',num2str(run) ,'iteration: ',num2str(iteration)]);
                                % the last valid assumption before plateau is found
                                % copy the valid assumption at plateau into
                                % plateau.qct
                                copyfile(strcat(path,'validassumption',num2str(iteration),'.qct'),strcat(path,'plateau.qct'));
        %                     else
                                % no valid assumptions before plateau => v-safe_plateau = 0
                                % 
                                % no plateau.qct
        %                         path=strcat('Benchmark',filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run));
        %                         filenames=dir(strcat(path,filesep,'validassumption*.qct'));
        %                         if ~isempty(filenames)
        %                             validAssumptionName=filenames(end).name;
        %                             copy(strcat(path,validAssumptionName),strcat(path,'plateau.qct'));
        %                         end
                            end
                        end
                    end
                end
            end
    end
end

                    
                    
                    
                    
