function [resultfilename, scriptname, algorithmFolder] = prepResultsFolder(model, property, policy, GPalgorithm)
    
resultfilename=strcat(model,property,policy);
scriptname=[model,property];
modelFolder=['result',filesep,model];
if ~exist(modelFolder, 'dir')
    mkdir(modelFolder);
end
propertyFolder=strcat('result',filesep,model,filesep,property);
if ~exist(propertyFolder, 'dir')
    mkdir(propertyFolder);
end
policyFolder=strcat('result',filesep,model,filesep,property,filesep,policy);
if ~exist(policyFolder, 'dir')
    mkdir(policyFolder);
end
algorithmFolder=strcat('result',filesep,model,filesep,property,filesep,policy,filesep,GPalgorithm);
if ~exist(algorithmFolder, 'dir')
    mkdir(algorithmFolder);
end