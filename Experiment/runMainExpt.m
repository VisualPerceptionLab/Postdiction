% runMainExpt
% Main experiment.
%
% This script takes about X.X minutes to run (2 blocks of 64 trials).

clear all; close all;

rng('default') % re5set the state of the random number generator.

global window width height;
global environment;
global pahandle;
global subjID
global background Lmax;
%global Q

try
    
    [mriTiming, waitTime, sampleRate] = setEnvironment(true); % Initialise environment, including audio.
    KbName('UnifyKeyNames');
    subjID = input('Subject number?: ');
    %% This might be a safer way to ensure consistency in omissions&contrast across participants.
    training = input('1 = Behavourial Training 0 = Scanning');
    % creates a practice block
    if mriTiming
        showInstructions = 2;
    else
        showInstructions = input('Show instructions? (1: yes or 2: no): ');
    end
    %BlockNumber = input('Blocknumber?: (1,2,3 or 4)');
    %toneOrientation = input('Cue map? (1 or 2): ');
   
    [background,Lmin,Lmax] = calibrateLum(1.0); %1.5
    
     %2
    if showInstructions == 1
        nBlocks = 1;
        nTrialsPerBlock = 32;
    else 
        nBlocks = 1;
        nTrialsPerBlock = 4;
    end
    if mod(nTrialsPerBlock,4) ~= 0
        disp('WARNING: nTrialsPerBlock is not a multiple of 4, counterbalancing will fail!');
        abort = input('Abort experiment?: (1: yes, 2: no): ');
        if abort == 1
            abort = aaa; % force error
        end
    end
    nTrialsTotal = nBlocks*nTrialsPerBlock;
    feedback = 0;
    practice = 0;
    
    % create a counterbalanced trial structure for a (task) block.
    %trialStructure = getTrialStructure(nTrialsPerBlock, propOmission);
   
    currentTime = round(clock);
    if showInstructions == 1
        resultDir = fullfile(pwd,'Results',sprintf('practice_S%02d',subjID));
    else
        resultDir = fullfile(pwd,'Results',sprintf('S%02d',subjID));
    end
    if ~exist(resultDir,'dir'); mkdir(resultDir); end
    resultFile = sprintf('results_mainexp_%d_%d_%d_%d_%d_%d.mat',currentTime);
    resultFile = fullfile(resultDir,resultFile);
    %     if ~practice
    %         staircaseFile = sprintf('staircase_mainexp_runType%d_%d_%d_%d_%d_%d_%d.mat',runType,currentTime);
    %         staircaseFile = fullfile(resultDir,staircaseFile);
    %     end
    %     getStaircases(subjID,resultDir,runType);5
    
    if exist(fullfile(resultDir,'volume.mat'),'file')
        load(fullfile(resultDir,'volume.mat'),'volume');
    else
        disp('No volume calibration found, using default volume.');
        volume = 1;
    end
    %Open window and do useful stuff
    if strcmp(environment,'mri') || strcmp(environment,'mri_offline')
        [window,width,height] = openScreen();
    else
        [window,width,height] = openScreen();
    end
    
    widthRatioDifference = width/1322;
    heightRatioDifference = height/768;
    
    textSize = round(20*(heightRatioDifference));
    Screen('TextFont',window, 'Arial');
    Screen('TextSize',window, textSize);
    % Change for background
    %background = background/5*3;
    Screen('FillRect', window, background);%background);
    wrapat = round(100*widthRatioDifference); %wrapat = 100;
    vspacing = 1.5*widthRatioDifference; %vspacing = 1.5;
    
    % Create fixation bullseye
    % Change for background
    fixColour = Lmin;
    fixDiam = ceil(degrees2pixels(0.7));
    makeFixCross(fixColour, fixDiam, background);

    if showInstructions == 1
        showInstructions_MainExpt(background,Lmin,volume,wrapat,vspacing);
    end

    % Wait for scanner trigger or button press (depending on environment) before starting the experiment.
    time = waitForTrigger(waitTime,[],fixColour);
    
    % store the time at which the experiment actually starts - i.e. the
    % start of the first trial.
    initialTime = time;
    data = [];
    %Display blocks
    for iBlock = 1:nBlocks
%         if (iBlock == 3) || (iBlock == 5)
%             time = waitForTrigger(waitTime,[],fixColour);
%             time = waitForTrigger(waitTime,[],fixColour);
%         end
        
        % alice params
%         sizemult_list =      [1   1.5 1   1.5 1.5 1]; %Aaron[1 1 1.5 1.5 1]; %Dot/Doug [1 1   1.5 1.5 1];
%         distancemult_list =  [1.5 1.5 1.5 1.5 1.5 1.5]; % Aaron [1 1 1   1.5 1.5] %Dot/Doug [1 1.5 1.5 1 1];
%         % contrasts
%         contrasts =          [1.5 1   0.5 0.5 1 1.5];
        
        % Yan params
        sizemult_list =      [1 1 1 1 1 1 ]; %Aaron[1 1 1.5 1.5 1]; %Dot/Doug [1 1   1.5 1.5 1];
        distancemult_list =  [1.5 1.5 1.5 1.5 1.5 1.5]; % Aaron [1 1 1   1.5 1.5] %Dot/Doug [1 1.5 1.5 1 1];
        % contrasts
        contrasts =          [1 1 1 1 1 1];
        [background,Lmin,Lmax] = calibrateLum(contrasts(iBlock)); 
        %pitch_list = [2000 2000 2000 2000]; % Aaron [2000 4000 2000 2000 2000]; % Dot/Doug [2000 2000 2000 2000 4000];
        sizemult = sizemult_list(iBlock);
        distancemult = distancemult_list(iBlock);
        pitch = 2000;
        % Create trial sequence for the block
%         trialSequence = trialStructure(randperm(nTrialsPerBlock),:);
        % Hack it so that there are no more than 5 omissions in a row,
        % and that the first trial is always a valid trial.
        % Show example gratings (and tone-orientation contingency if applicable)
%         if strcmp(environment,'mri') && iBlock == 1
%             % present the example shapes while waiting for the scanner to
%             % stabilise.
%             showExampleGratings(time-waitTime+1, background, Lmin, false);
%         else
%             time = showExampleGratings(time, background, Lmin, false);
%         end
%         
        %Present a block of trials
        %trialSequence
        data{iBlock} = oneBlock(time, volume, training, nTrialsPerBlock, sampleRate, sizemult, distancemult, pitch);

        
        %Save the data
        save(resultFile, 'data');
        
        %         if ~practice
        %             % Save the staircases
        %             save(staircaseFile, 'orientationQ', 'contrastQ');
        %             save(fullfile(resultDir,'curStaircases.mat'), 'orientationQ', 'contrastQ');
        %         end
        
        %Update the time
        time = data{iBlock}.time;
        
      %  performance = round(100*data{iBlock}.nCorrect / sum(~isnan(data{iBlock}.gratingOrientation)));
       % missedOrientResp = round(100*mean(data{iBlock}.orientAnswer == -10));
      %  missedConfResp = round(100*mean(data{iBlock}.confAnswer == -10));
        
      %         accuracyText = sprintf('You answered correctly on %d percent of trials.', performance);
      %         missedOrientText = sprintf('\nYou were too slow in reporting the tilt of the grating on %d percent of trials.', missedOrientResp);
      %         missedConfText = sprintf('\nYou were too slow in reporting your confidence on %d percent of trials.', missedConfResp);
      %        performanceText = [accuracyText missedOrientText missedConfText];
      performanceText = '';
      time = endOfBlock(iBlock,nBlocks,performanceText,time,wrapat,vspacing);
      %breakEndTime(iBlock, 1) = WaitSecs(30);
    end
    
    % Take the time when the program was stopped
    finishTime = GetSecs;
    data{1}.finishTime = finishTime;
    %data{1}.breakEndTime = breakEndTime;
    data{1}.initialTime = initialTime;
    
    % Save the results
    save(resultFile, 'data');
    
    %     if ~practice
    %         % Save the staircases
    %         save(staircaseFile, 'orientationQ', 'contrastQ');
    %         % Save staircase values for future use.
    %         save(fullfile(resultDir,'curStaircases.mat'), 'orientationQ', 'contrastQ');
    %     end
    
    % Close the audio device:
    PsychPortAudio('Close', pahandle);
    
    %End. Close all windows
    Screen('CloseAll');
    
    % Check stimulus timing (only for during development)
    %checkStimTiming(data);
    
    % Plot some results for the staircasing procedure
    %plotQuestResults(data);
    
catch aloha
    
    % Close the audio device:
    PsychPortAudio('Close', pahandle);
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end
