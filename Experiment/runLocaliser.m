% Present full contrast, on/off flickering gratings, to serve as a functional localiser.
% Current code shows 16 blocks, one block consists of two gratings (12s)
% and one fixation period (12s), so the script takes 12*16*3 = 576 s =
% 9:36 min to run.

clear all; close all;

rng('shuffle') % reset the state of the random number generator.

global window width height;
global environment;
global fixCrossTexture fixRect fixCrossTexture_dim;
global TR;

try
    
    [mriTiming, waitTime] = setEnvironment(false); % Initialise environment, no audio.
    KbName('UnifyKeyNames');
    
    subjID = input('Subject number?: ');
    
    [background,Lmin,Lmax] = calibrateLum(1);
    
    %Take current time. The results will be saved with the current time
    %appended to the file name as to prevent overwriting from one subject
    %to another
    currentTime = round(clock);
    resultDir = fullfile(pwd,'Results',sprintf('S%02d',subjID));
    if ~exist(resultDir,'dir'); mkdir(resultDir); end
    resultFile = sprintf('results_localiser_%d_%d_%d_%d_%d_%d.mat',currentTime);
    resultFile = fullfile(resultDir,resultFile);
    
    %Open window and do useful stuff
    if strcmp(environment,'mri') || strcmp(environment,'mri_offline')
        [window,width,height] = openScreen(0);
    else
        [window,width,height] = openScreen();
    end
    
    Screen('TextFont',window, 'Arial');
    Screen('TextSize',window, 20);
    Screen('FillRect', window, background);
    wrapat = 55;
    vspacing = 1.5;
    
%     %Define the keys
%     if strcmp(input_device, 'keyboard')
%         key_1 = KbName('1!');
%         key_2 = KbName('2@');
%         escape = KbName('escape');
%     elseif strcmp(input_device, 'bitsi')
%         key_1 = 97;
%         key_2 = 98;
%         escape = 102;
%     end
    
    % Create fixation bullseye
    fixColour = Lmin;
    fixDiam = ceil(degrees2pixels(0.7));
    makeFixCross(fixColour, fixDiam, background);
     
    %Compute the size of the stimulus
    gratingSize_degrees = 10
    gratingSize = degrees2pixels(gratingSize_degrees);
    innerDegree = 1.5
    destSquare = [width/2-gratingSize/2, height/2-gratingSize/2, width/2+gratingSize/2, height/2+gratingSize/2];
    spatFreq = 0.5
    
    nOrientations = 2;
    rotAngles = [45 135];
    % change rotAngles so that the orientations are as per the unit circle.
    rotAngles = -1 * (rotAngles+90);

    nBlocks = 16 %16
    if strcmp(environment,'mri')
        presTime = 4*TR
    else
        presTime = 4*3.408 % in seconds
    end
    gratingContrast = 1;
    flickerFreq = 4; %4 flickers per sec: 2 Hz flicker frequency
    responseTimes = [];
    responseCount = 0;
    
    % pre-draw a bunch of gratings
    tic
    phases = 0:pi/6:1.99*pi;
    for iphase = 1:length(phases)
        phase = rand*2*pi; % random phase, between 0 and 2*pi
        %stimulus_matrix = makeGaborStimulus(gratingContrast,grating_size_degrees,phase,spatFreq);
        stimulusMatrix{iphase} = makeStimulus(gratingContrast,0,1,gratingSize_degrees,phase,spatFreq,innerDegree);
        readyStimulus{iphase} = Screen('MakeTexture', window, stimulusMatrix{iphase});
    end
    toc
    
    text = 'Fixation dot dimming task';
    time = waitForTrigger(waitTime,text,Lmin);
    
    % store the time at which the experiment actually starts
    initialTime = time;
    
    blockSequence = randperm(nBlocks);
    presentationTime = zeros(nBlocks,2,ceil(presTime*flickerFreq));
    spatfreqPres = zeros(nBlocks,4);
    stimOrder = zeros(nBlocks,4);
    %Display blocks
    % Remove any keypresses that occured before presentation of the
    % stimuli.
    FlushEvents('keyDown');
    
    changeTimesAbs = [];
    
    for iBlock = 1:nBlocks
        
        if blockSequence(iBlock) <= nBlocks/2
            orientationOrder = [1 NaN 2 NaN];
            stimOrder(iBlock,:) = orientationOrder;
        else
            orientationOrder = [2 NaN 1 NaN];
            stimOrder(iBlock,:) = orientationOrder;
        end
        
        % How many times will the fixation point change colour in this
        % block? 5-10 times.
        nChanges = 5 + round(5*rand);
        % When will these changes occur?
        changeTimes{iBlock} = randperm(floor(presTime*4-2));
        changeTimes{iBlock} = sort(changeTimes{iBlock}(1:nChanges));
        
        % Present the four blocks: the two orientations interleaved with
        % fixation blocks.
        for i = 1:4
            
            % Decide at which timepoint (in seconds) the fixation point will turn
            % black
            taskPres = changeTimes{iBlock}(changeTimes{iBlock} >= presTime*(i-1) & changeTimes{iBlock} <= presTime*i);
            % During which stimulus presentation (i.e. flicker)?
            taskPres = round((taskPres - presTime*(i-1)) * flickerFreq);
            
            spatfreqPres(iBlock,i) = spatFreq; 
            
            for j = 1:floor(presTime*flickerFreq)
                if mod(j,2) && ~isnan(orientationOrder(i))
                    rotAngle = rotAngles(orientationOrder(i));
                    phaseInd = randi(length(phases),1);
                    Screen('DrawTexture', window, readyStimulus{phaseInd}, [], destSquare, rotAngle);
                    %Screen('FillOval', window, background, [width/2-size_inner_most_circle, height/2-size_inner_most_circle, width/2+size_inner_most_circle, height/2+size_inner_most_circle]);
                end
                if find(taskPres == j)
                    %Screen('DrawDots', window, [width/2, height/2], dotSize, 0);
                    Screen('DrawTexture', window, fixCrossTexture_dim, fixRect, CenterRect(fixRect, [0 0 width height]));
                    %DrawFormattedText(window, 'Now!', 'center', height/2-200, fixColour);
                    changeTimesAbs = [changeTimesAbs time];
                else
                    %Screen('DrawDots', window, [width/2, height/2], dotSize, 255);
                    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
                end
                presentationTime(iBlock,i,j) = Screen('Flip',window, time);
                time = time+1/flickerFreq;
                
                % Check for inputs
                [answer, respTime] = getResponse(time - 0.016); % look for responses until within one frame of a new presentation
                if answer ~= -10
                    responseCount = responseCount + 1;
                    responseTimes(responseCount) = respTime;
                end
            end
            
            % If presTime is not a multiple of the flicker frequency, the
            % blocks will be slightly too short. Correct this.
            time = time + (presTime - floor(presTime*flickerFreq)/flickerFreq);
            
        end
        
        if iBlock == round(nBlocks/2)
            time = endOfBlock(1,2,'',time,wrapat,vspacing);
        end
        
    end
    
    % Wait until the last fixation block is over
    while GetSecs < time
        WaitSecs(1/60); %wait one frame
    end
    
    %Take the time when the program was stopped
    finishTime = GetSecs;
    
    % save the data
    data.initialTime = initialTime;
    data.finishTime = finishTime;
    data.blockSequence = blockSequence;
    data.presentationTime = presentationTime;
    data.stimOrder = stimOrder;
    data.spatfreqPres = spatfreqPres;
    data.changeTimes = changeTimes;
    data.changeTimesAbs = changeTimesAbs;
    data.rt = responseTimes;
    save(resultFile,'data')
    
    %End. Close all windows
    Screen('CloseAll');
    
catch
    
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end