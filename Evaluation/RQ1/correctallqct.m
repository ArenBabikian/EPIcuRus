% This file is part of Evaluation
% Copyright © [2020] – [2021] University of Luxembourg.
% ,'R3','R4','R6','R7','R8'
model='tustin';
policies={'UR'};
number_runs=30;
% [0 7;0 4]
requirements={'R4a'};
%added='assume TL{0}== 50 and BL{0} ==0 and T>=-10 and T<=10 and xin>=-10 and xin<=10;';
uncorrect='T==0.1 and T{0}==0.1';
correct='T==1 and T{0}==1';
for req=1: size(requirements,2)
    for p=1:size(policies,2)
        for r=1:number_runs
            path=['Benchmark/',model,'/IP/',requirements{req},'/',policies{p},'/RS/Run',num2str(r),'/'];
% finalDatafinal/IP1/
            %             filename=[path,model,requirements{req},policies{p},'.txt'];
%             delete(filename);
            filenames=dir([path,'*.qct']);
            for i =1:size(filenames,1)
                %correctqct1([path,filenames(i).name],added);
                correctqct([path,filenames(i).name],uncorrect,correct);
            end
        end
    end
end

    
