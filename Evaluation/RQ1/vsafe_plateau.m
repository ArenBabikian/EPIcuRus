disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
disp('RQ1 (Effectiveness and Efficency): Comparison of TC policies');
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.

clear
close all
runs=1:1:50;

models=["regulators"];

requirementspermodels={{"R3"}};
prefixes=[""];
algorithms=[ "RS"];

algorithmresult=[0,0];
avg_time=[0,0];

index=0;

total=0;
for model=models

    disp(model)
    index=index+1;
    num=0;


    allrequirements=requirementspermodels{index};
    for reqindex=1:size(allrequirements,2)
            algorithmresult_partial=[0,0,0,0];
            avg_time_partial=[0,0,0,0];
            requirement=allrequirements{reqindex};
            for run=runs
                prefix=prefixes(index);
                algorithmid=1;
                for algorithm=algorithms
                    runfolder=strcat('Benchmark/',model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run));
                    if isfolder(runfolder)
                        disp(runfolder);
                        total=total+1;
                        if isfile(strcat('Benchmark/',model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,"plateau.qct"))
                            result=1;
                        else
                            result=0;
                        end

    %                     fid = fopen(strcat(prefix,filesep,model,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,"result.txt"),'r');
    %                     result=fscanf(fid,'%d');
    %                     fclose(fid);
                        algorithmresult(algorithmid)=algorithmresult(algorithmid)+result;
                        if result==1
                            algorithmresult_partial(algorithmid)=algorithmresult_partial(algorithmid)+result;
                            fideptime = fopen(strcat('Benchmark',filesep,model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,"validEPtime.txt"),'r');
                            eptime=fscanf(fideptime,'%f');
                            fclose(fideptime);
                            fidqvtime = fopen(strcat('Benchmark',filesep,model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,"validEPtime.txt"),'r');
                            qvtime=fscanf(fidqvtime,'%f');
                            fclose(fidqvtime);
                            totaltime=eptime+qvtime;
                        else
                            file1=strcat('Benchmark',filesep,model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,algorithm,filesep,"Run",num2str(run),filesep,"totaltime.txt");
                            if isfile(file1)
                                fidtotaltime = fopen(file1,'r');
                                totaltime=fscanf(fidtotaltime,'%f');
                                fclose(fidtotaltime);
                            end
                        end
                         avg_time(algorithmid)=avg_time(algorithmid)+totaltime;


                         avg_time_partial(algorithmid)=avg_time_partial(algorithmid)+totaltime;

                         algorithmid=algorithmid+1;
                    end
                end

            end

    end

end

v_safe=algorithmresult/(total)*100;
avg_time=avg_time/total;
disp(v_safe)
disp(avg_time)

plot(avg_time,v_safe);


function c=getcolors(num)
c=colormap(lines(num));

end



function []=plot(avg_time,v_safe)
    dx = 0.4; dy = 0.4; % displacement so the text does not overlay the data points

    algorithmsforlegend={'GP','RS'};
    algorithms={'GP','RS'};
    figure();
    colors=[0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880];
colormap(colors)
    hold on
    for i=1:1:size(avg_time,2)
        result=0;
        scatter(avg_time(i),v_safe(i),200,colors(i,:),'filled')
        text(avg_time(i)+dx, v_safe(i)+dy, num2str(result));
    end
    grid on

    ylabel("V\_SAFE (%)",'FontSize',15,'HorizontalAlignment', 'center');
    xlabel("AVG\_TIME (s)",'FontSize',15,'HorizontalAlignment', 'center');
    AX=legend(algorithmsforlegend,'Orientation','vertical');
    AX.FontSize = 15;

end
