% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
function informationindex=compute_information_index()
    clear
    close all

%     models=["regulators"];
%     inputsnames={'lcv_cmd_fcs_dps_1','mcv_cmd_fcs_dps1', 'ncv_cmd_fcs_dps1','xcv_cmd_fcs_fps1','beta_adc_deg1', 'vtas_adc_kts1','hdg_des_deg1', 'alt_des_ft1','airspeed_des_fps1', 'hcv_cmd_fcs_fps1', 'zcv_fcs_fps1', 'beta_dot1','lcv_fps_dps1','mcv_fcs_dps1','ncv_fcs_dps1','dcv_fcs_fps1'};
%     inputsRanges =[-100 100;-100 100;-100 100;-100 100;0 100;0 100;-100 100;0 100;0 100;-100 100;-100 100;0 100;-100 100;-100 100;-100 100;-100 100];
%     requirementspermodels={{"R4"}};
%     models=["tustin"];
%     inputsnames={'xin1','T1','ic1','TL1','BL1','reset1'};
%     inputsRanges =[-10 10;0 10;-10 10;50 50;0 0;0 0];
%     requirementspermodels={{"R3"}};
    models=["twotank"];
    inputsnames={'t1h1','t2h1'};
    inputsRanges =[0 7;0 4];
    requirementspermodels={{"R8"}};
    prefixes=[""];
    informationindex=[];
    index=0;
    for model=models

        index=index+1;
        allrequirements=requirementspermodels{index};

        for reqindex=1:size(allrequirements,2)
            requirement=allrequirements{reqindex};
            prefix=prefixes(index);
            filename1=strcat(model,requirement,'IFBT_URlast');
            path1=strcat('Benchmark',filesep,model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,'IFBT_UR',filesep,filename1,'.txt');
            filename2=strcat(model,requirement,'RSlast');
            path2=strcat('Benchmark',filesep,model,filesep,prefix,filesep,requirement,filesep,'UR',filesep,'RS',filesep,filename2,'.txt');
            %inf_index=computeINF_INDEX(path1,path2);
            informations_of_assumptions=inf_index(path1,inputsnames,inputsRanges);
            information=mean(informations_of_assumptions(~isnan(informations_of_assumptions)));
            disp(['average of information over the assumptions of the method: ',num2str(information)]);
            informationindex(reqindex,:)=information;
        end
    end
end
