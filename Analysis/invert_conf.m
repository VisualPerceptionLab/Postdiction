clear all;
close all;
filename = "results_mainexp_2024_1_26_11_53_12"
pathname = fullfile('D:\Documents\PhD_project\postdiction_AV_fMRI\data_collection\Data\S03_scan\',filename)
load(pathname)
%%
data{1}.confAnswer(data{1}.confAnswer==14)
data{1}.confAnswer(data{1}.confAnswer==13)
data{1}.confAnswer(data{1}.confAnswer==12)
data{1}.confAnswer(data{1}.confAnswer==11)

data{2}.confAnswer(data{2}.confAnswer==14);
data{2}.confAnswer(data{2}.confAnswer==13);
data{2}.confAnswer(data{2}.confAnswer==12);
data{2}.confAnswer(data{2}.confAnswer==11);
%%
% Find indices of numbers to swap
indices_14 = find(data{1}.confAnswer == 14);
indices_13 = find(data{1}.confAnswer== 13);
indices_12 = find(data{1}.confAnswer == 12);
indices_11 = find(data{1}.confAnswer== 11);

% Replace values according to swapping
data{1}.confAnswer(indices_14) = 11;
data{1}.confAnswer(indices_13) = 12;
data{1}.confAnswer(indices_12) = 13;
data{1}.confAnswer(indices_11) = 14;

% Find indices of numbers to swap
indices_14 = find(data{2}.confAnswer == 14);
indices_13 = find(data{2}.confAnswer== 13);
indices_12 = find(data{2}.confAnswer == 12);
indices_11 = find(data{2}.confAnswer== 11);

% Replace values according to swapping
data{2}.confAnswer(indices_14) = 11;
data{2}.confAnswer(indices_13) = 12;
data{2}.confAnswer(indices_12) = 13;
data{2}.confAnswer(indices_11) = 14;
%%
block = data{1}
ExpDesign = block.condition
block.conditionConf
conditionConf = zeros(1, 4);
for i=1:4
    condIndices = find(ExpDesign==i);
    exclNegatives = block.confAnswer(condIndices);
    exclNegatives = exclNegatives(exclNegatives>0);
    condConfmean = mean(exclNegatives) - 10;
    conditionConf(i) = condConfmean
end

block = data{2}
ExpDesign = block.condition
block.conditionConf
conditionConf = zeros(1, 4);
for i=1:4
    condIndices = find(ExpDesign==i);
    exclNegatives = block.confAnswer(condIndices);
    exclNegatives = exclNegatives(exclNegatives>0);
    condConfmean = mean(exclNegatives) - 10;
    conditionConf(i) = condConfmean
end
%%
save(pathname, 'data')