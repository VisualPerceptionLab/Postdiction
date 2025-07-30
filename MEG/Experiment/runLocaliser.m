% runMainExpt
% Main experiment.
%
% This script takes about X.X minutes to run (2 blocks of 64 trials).

clear all; close all;

%rng('shuffle') % re5set the state of the random number generator.

global window width height;
global environment;
global pahandle;
global subjID
global background Lmax;
global localizer_count;
%global Q

try
    
    [mriTiming, waitTime, sampleRate] = setEnvironment(true); % Initialise environment, including audio.
    KbName('UnifyKeyNames');
    subjID = input('Subject number: ');
    
    
    %% This might be a safer way to ensure consistency in omissions&contrast across participants.
%     training = input('1 = Behavourial Training 0 = Scanning');
    % creates a practice block
%     if mriTiming
%         showInstructions = 2;
%     else
%         showInstructions = input('Show instructions? (1: yes or 2: no): ');
%     end
    %BlockNumber = input('Blocknumber?: (1,2,3 or 4)');
    %toneOrientation = input('Cue map? (1 or 2): ');
   
    [background,Lmin,Lmax] = calibrateLum(1.0); %1.5
    
    localizer_count = 7;
    nTrialsPerBlock = 49;

    if mod(nTrialsPerBlock,localizer_count) ~= 0
        disp('WARNING: nTrialsPerBlock is not a multiple of 4, counterbalancing will fail!');
        abort = input('Abort experiment?: (1: yes, 2: no): ');
        if abort == 1
            abort = aaa; % force error
        end
    end
    nTrialsTotal = nTrialsPerBlock;
    feedback = 0;
    practice = 0;
   
    currentTime = round(clock);

    resultDir = fullfile(pwd,'Results',sprintf('S%02d',subjID));

    if ~exist(resultDir,'dir'); mkdir(resultDir); end
    resultFile = sprintf('localiser_mainexp_%d_%d_%d_%d_%d_%d.mat',currentTime);
    resultFile = fullfile(resultDir,resultFile);
    
%     if exist(fullfile(resultDir,'volume.mat'),'file')
%         load(fullfile(resultDir,'volume.mat'),'volume');
%     else
%         disp('No volume calibration found, using default volume.');
%         volume = 1;
%     end
volume=1;
    %Open window and do useful stuff
     [window,width,height] = openScreen();
     
    % To-do: MEG
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
    
    % store the time at which the experiment actually starts - i.e. the
    % start of the first trial.
    % Wait for scanner trigger or button press (depending on environment) before starting the experiment.
    time = waitForTrigger(waitTime,[],fixColour);
    initialTime = time;
%     if MEGTiming
%     Eyelink('Message','Trigger %s',num2str(initialTime))    % optionally send triggers (to the file)
%     end
    data = [];

    [background,Lmin,Lmax] = calibrateLum(1); 
    pitch = 800;
    % Create trial sequence for the block
    
   training = false;
   data{1} = oneBlockLocaliser(time, volume, training, nTrialsPerBlock, sampleRate);

    
    %Save the data
    save(resultFile, 'data');
    
    %Update the time
    time = data{1}.time;
        
%       performanceText = '';
%       time = endOfBlock(iBlock,nBlocks,performanceText,time,wrapat,vspacing);
%       %breakEndTime(iBlock, 1) = WaitSecs(30);
    
    % Take the time when the program was stopped
    finishTime = GetSecs;
    data{1}.finishTime = finishTime;
    %data{1}.breakEndTime = breakEndTime;
    data{1}.initialTime = initialTime;
    
    % Save the results
    save(resultFile, 'data');
    
%     % To-do: MEG
%     Eyelink('StopRecording')                 % stop recording
%     Eyelink('Closefile')                     % close the file
%     Eyelink('ReceiveFile')                   % copy the file to the Stimulus PC
%     Eyelink('Shutdown')                      % close the connection to the eyetracker PC

    % Close the audio device:
    PsychPortAudio('Close', pahandle);
    
    %End. Close all windows
    Screen('CloseAll');

    
catch aloha
    
    % Close the audio device:
    PsychPortAudio('Close', pahandle);
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end
