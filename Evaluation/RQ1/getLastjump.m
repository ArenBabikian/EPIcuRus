% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function last=getLastjump()
    clear
    close all

%     models=["regulators"];
%     inputsnames={'lcv_cmd_fcs_dps_1','mcv_cmd_fcs_dps1', 'ncv_cmd_fcs_dps1','xcv_cmd_fcs_fps1','beta_adc_deg1', 'vtas_adc_kts1','hdg_des_deg1', 'alt_des_ft1','airspeed_des_fps1', 'hcv_cmd_fcs_fps1', 'zcv_fcs_fps1', 'beta_dot1','lcv_fps_dps1','mcv_fcs_dps1','ncv_fcs_dps1','dcv_fcs_fps1'};
%     inputsRanges =[-50 50;-50 50;-50 50;-50 50;0 50;0 50;-50 50;0 50;0 50;-50 50;-50 50;0 50;-50 50;-50 50;-50 50;-50 50];
%     requirementspermodels={{"R1", "R3","R4"}};
    models=["regulators"];
    inputsnames={'xin1','ic1','TL1','BL1','reset1'};
    inputsRanges =[0 5;-10 10;0 50;0 0;0 0];
    requirementspermodels={{"R4"}};
%     models=["twotank"];
%     inputsnames={'t1h1','t2h1'};
%     inputsRanges =[3 7;0 2];
%     requirementspermodels={{"R7"}};
    prefixes=["plateauExp"];
    informationindex=[];
    index=0;
    for model=models

        index=index+1;
        allrequirements=requirementspermodels{index};
        
        for reqindex=1:size(allrequirements,2)
            requirement=allrequirements{reqindex};
            prefix=prefixes(index);
            filename1=strcat(model,requirement,'RS');
            path=strcat('Benchmark',filesep,model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,'RS',filesep,filename1,'jumps.txt');
            fid=fopen(path,'r');
            jumps=textscan(fid,'%s','Delimiter','\n');
            fclose(fid);
            lastRS=zeros(1,numel(jumps{:}));
            for i=1:numel(jumps{:})
                idx=find(jumps{:}{i} == ' ', 1, 'last');
                if isempty(idx)
                    lastRS(i)=1;
                else
                    lastRS(i)=str2double(jumps{:}{i}((idx+1):end));
                end
            end
        end
    end
end
