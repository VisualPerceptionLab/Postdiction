function [] = getStaircases(subjID,resultDir,runType)
% [] = getStaircases(subjID,resultDir)
%
% Loads or creates staircase(s) for shape discrimination tasks.

global orientationQ contrastQ;

%% Determine threshold guess and SD to use.
orientation_thresholdGuess = 4;
orientation_priorSd = 3;
orientation_thresholdGuess=log10(orientation_thresholdGuess);

contrast_thresholdGuess = 0.2;
contrast_priorSd = 0.5;
contrast_thresholdGuess=log10(contrast_thresholdGuess);

if exist(fullfile(resultDir,'curStaircases.mat'),'file')
    % load staircases
    curStaircaseFile = fullfile(resultDir,'curStaircases.mat');
    load(curStaircaseFile, 'orientationQ', 'contrastQ');
    
%     if runType == 1 || runType == 3
%         currentGuess = 10^QuestMean(orientationQ);
%     elseif runType == 2 || runType == 4
%         currentGuess = 10^QuestMean(contrastQ);
%     end
%     
%     text = sprintf('Guess = %g. Okay? (1: yes, 2: no):', currentGuess);
%     loadStaircase = input(text);
%     
%     if loadStaircase == 1
%         % Use the pre-stored staircases; nothing to do here.
%     elseif loadStaircase == 2
%         % initialise new staircase(s) based on default values.
%         pThreshold=0.75;
%         beta=3.5;delta=0.01;gamma=0.5;
%         switch runType
%             case 1 % orientation task
%                 orientationQ = QuestCreate(orientation_thresholdGuess,orientation_priorSd,pThreshold,beta,delta,gamma);
%             case 2 % contrast task
%                 contrastQ = QuestCreate(contrast_thresholdGuess,contrast_priorSd,pThreshold,beta,delta,gamma);
%         end
%     end
    
else
    fprintf('curStaircases.mat not found for subject %d. Will initialise new staircases.\n',subjID);
    continueExp = input('Continue?: (1: yes, 2: abort): ');
    if continueExp == 2
        continueExp = aaa; % force error
    end
    
    pThreshold=0.75;
    beta=3.5;delta=0.01;gamma=0.5;
    orientationQ = QuestCreate(orientation_thresholdGuess,orientation_priorSd,pThreshold,beta,delta,gamma);
    contrastQ = QuestCreate(contrast_thresholdGuess,contrast_priorSd,pThreshold,beta,delta,gamma);
end

end