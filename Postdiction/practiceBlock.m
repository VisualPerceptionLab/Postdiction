function presentation = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, mriTiming, feedback, practiceStage)

global environment window width height;
global fixCrossTexture fixRect fixCrossTexture_ITI;
%global Q;
global pahandle;
global buttonDeviceID;

PsychPortAudio('RunMode', pahandle, 1);

saveStim = false;

orients = [1 2];
nOrientations = 2;
rotAngles = [135 45];
% change rotAngles so that the orientations are as per the unit circle.
rotAngles = -1 * (rotAngles+90);

halfFrame = 0.5/60; % request flips have a frame before they should actually occur.

%Compute the size of the stimulus
gratingSize_degrees = 10;
gratingSize = 2*degrees2pixels(gratingSize_degrees/2);
innerDegree = 1.5;
destSquare = [width/2-gratingSize/2, height/2-gratingSize/2, width/2+gratingSize/2, height/2+gratingSize/2];
if practiceStage == 1
    gratingDur = 15/60; %2/60; % in seconds
elseif practiceStage > 1
    gratingDur = 2/60; %2/60; % in seconds
end
spatFreq = 0.5;

% %Attributes of the placeholder
% placeholderColour = [0 0 0];
% lineWidth = degrees2pixels(0.1);
% placeholderDestSquare = [width/2-gratingSize/2-lineWidth/2, height/2-gratingSize/2-lineWidth/2, width/2+gratingSize/2+lineWidth/2, height/2+gratingSize/2+lineWidth/2];

% attributes of the auditory cue tone
toneFreqs = [450 1000]; % A4 C#5 E5
toneDur = 0.2;
sampleRate = 44100;
rampTime = 0.01; % rise and fall times of the tones.
cueStimSOA = 0.75; % SOA between cue and stimulus

% attributes of the fixation cue
fixCueInt = 0.1; % SOA between fixation cue and auditory cue.

% Attributes of the task
respDelay = 0.75; % delay between grating presentation and presentation of orientation response mapping
orientRespInt = 1.25; % length of orientation response interval, in seconds.
confRespInt = 1.0; % length of confidence response interval, in seconds.
%respMap_lineWidth = degrees2pixels(0.2);
respMap_Yoffset_degrees = 1;
respMap_Yoffset = degrees2pixels(respMap_Yoffset_degrees);
% respMap_Xoffset_degrees = 1.5;
% respMap_Xoffset = degrees2pixels(respMap_Xoffset_degrees);
% respMap_lineSize_degrees = 1;
% respMap_lineSize = degrees2pixels(respMap_lineSize_degrees);

% create tones
wavedata = cell(1,length(toneFreqs));
for iTone = 1:length(toneFreqs)
    [wavedata{iTone}, sampleRate] = MakeBeep(toneFreqs(iTone), toneDur, sampleRate);
    % add linear rise and fall ramps
    ramp = 0:1/(rampTime*sampleRate):1;
    wavedata{iTone}(1:length(ramp)) = wavedata{iTone}(1:length(ramp)) .* ramp;
    ramp = ramp(end:-1:1);
    wavedata{iTone}(1+end-length(ramp):end) = wavedata{iTone}(1+end-length(ramp):end) .* ramp;
    wavedata{iTone} = wavedata{iTone} * volume; % adjust volume.
end

nCorrect = 0;
nTrials = size(trialSequence,1);

%Start the sequence of trials
for iTrial=1:nTrials
    
    % parse trialSequence; contains information on the trial
    
    % which cue?
    cue = trialSequence(iTrial,2);
    if cue == 1
        tonePresented = 1; % low tone
    elseif cue == 2
        tonePresented = 2; % high tone
    elseif isnan(cue)
        tonePresented = NaN;
    end
    
    % which orientation is predicted?
    if (toneOrientation == 1 && cue == 1) || (toneOrientation == 2 && cue == 2)
        % rising tones predict shape 1 and the cue was rising tones, or
        % falling tones predict shape 1 and the cue was falling tones.
        predOrientation = orients(1);
    elseif (toneOrientation == 1 && cue == 2) || (toneOrientation == 2 && cue == 1)
        % rising tones predict shape 1 and the cue was falling tones, or
        % falling tones predict shape 1 and the cue was rising tones.
        predOrientation = orients(2);
    else
        % all options should have been covered above, something has
        % gone wrong.
        predOrientation = bbb; %forcefully break out
    end
    
    % which orientation will be presented?
    if trialSequence(iTrial,1) == 1
        % the orientation prediction will come true
        gratingOrientation = predOrientation;
        gratingRotAngle = rotAngles(gratingOrientation);
    elseif trialSequence(iTrial,1) == 0
        % omit the grating
        gratingOrientation = NaN;
        gratingRotAngle = 0;
    end
    
    % Give the grating a random phase
    gratingPhase = rand*2*pi; % random phase, between 0 and 2*pi
    
    % Present the fixation bull's eye, as a cue of trial onset
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
    presentationTime(1) = Screen('Flip', window, time - halfFrame);
    reqPresentationTime(1) = time;
    time = presentationTime(1) + fixCueInt;
    
    %% Present the auditory cue.
    if isnan(cue) || strcmp(practiceStage,'stage1')
        % no auditory cue; just update 'time' and set some variables (to
        % avoid errors).
        time = time + cueStimSOA;
        reqCueTime = NaN;
        cueTime = NaN;
    else
        % present the auditory cue
        reqCueTime = time;
        % Fill the audio playback buffer with the audio data 'wavedata':
        PsychPortAudio('FillBuffer', pahandle, wavedata{tonePresented});
        % Start audio playback at time 'time', return onset timestamp.
        cueTime = PsychPortAudio('Start', pahandle, 1, reqCueTime, 1);
        
        time = cueTime + cueStimSOA; % Present the stimulus after the cue
        
%         if strcmp(environment,'mri') || strcmp(environment,'mri_offline')
%             % send a message to the eyetracker
%             text = sprintf('CUE%d',cue);
%             Eyelink('Message', text);
%         end
    end
    
    %% Prepare and show the grating (or noise) stimulus
    noisePatch = trialSequence(iTrial,4);
    if ~isnan(gratingOrientation)
        stimulusMatrix = makeStimulus(gratingContrast,noiseContrast,noisePatch,gratingSize_degrees,gratingPhase,spatFreq,innerDegree);
    else
        stimulusMatrix = makeStimulus(0,noiseContrast,noisePatch,gratingSize_degrees,gratingPhase,spatFreq,innerDegree);
    end
    readyStimulus = Screen('MakeTexture', window, stimulusMatrix);
    Screen('DrawTexture', window, readyStimulus, [], destSquare, gratingRotAngle);
    Screen('Close',readyStimulus);
    %Screen('FrameOval', window, placeholderColour, placeholderDestSquare, lineWidth);
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
    presentationTime(2) = Screen('Flip', window, time - halfFrame);
    reqPresentationTime(2) = time;
    time = presentationTime(2) + gratingDur;
    
    if saveStim
        imageArray = Screen('GetImage', window);
        stimName = sprintf('oneBlock_stim_trial%d.tiff',iTrial);
        imwrite(imageArray, stimName)
    end
    
    %% Remove the stimulus and display the fixation bull's eye again
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
    presentationTime(3) = Screen('Flip', window, time - halfFrame);
    reqPresentationTime(3) = time;
    time = presentationTime(3) + respDelay;
    
    % Remove any keypresses that occured before presentation of the grating.
    FlushEvents('keyDown');
    
    %% Present orientation response options
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
    respMap = trialSequence(iTrial,3);
    if respMap == 1
        %Screen('DrawLine', window, [0 0 0], width/2-respMap_Xoffset-respMap_lineSize, height/2+respMap_Yoffset+respMap_lineSize, width/2-respMap_Xoffset, height/2+respMap_Yoffset, respMap_lineWidth);
        %Screen('DrawLine', window, [0 0 0], width/2+respMap_Xoffset+respMap_lineSize, height/2+respMap_Yoffset+respMap_lineSize, width/2+respMap_Xoffset, height/2+respMap_Yoffset, respMap_lineWidth);
        %DrawFormattedText(window, 'A', width/2-respMap_Xoffset, height/2+respMap_Yoffset, [0 0 0]);
        %DrawFormattedText(window, 'B', width/2+respMap_Xoffset, height/2+respMap_Yoffset, [0 0 0]);
        %DrawFormattedText(window, 'A    B', 'center', height/2+respMap_Yoffset, [0 0 0]);
        %DrawFormattedText(window, 'A                               B', 'center', height/2+respMap_Yoffset, [0 0 0]);
         DrawFormattedText(window, '<         >', 'center', 'center', [0 0 0]);
    elseif respMap == 0
        %Screen('DrawLine', window, [0 0 0], width/2-respMap_Xoffset-respMap_lineSize, height/2+respMap_Yoffset, width/2-respMap_Xoffset, height/2+respMap_Yoffset+respMap_lineSize, respMap_lineWidth);
        %Screen('DrawLine', window, [0 0 0], width/2+respMap_Xoffset+respMap_lineSize, height/2+respMap_Yoffset, width/2+respMap_Xoffset, height/2+respMap_Yoffset+respMap_lineSize, respMap_lineWidth);
        %DrawFormattedText(window, 'A', width/2+respMap_Xoffset, height/2+respMap_Yoffset, [0 0 0]);
        %DrawFormattedText(window, 'B', width/2-respMap_Xoffset, height/2+respMap_Yoffset, [0 0 0]);
        %DrawFormattedText(window, 'B    A', 'center', height/2+respMap_Yoffset, [0 0 0]);
        %DrawFormattedText(window, 'B                               A', 'center', height/2+respMap_Yoffset, [0 0 0]);
         DrawFormattedText(window, '>         <', 'center', 'center', [0 0 0]);
    end
    presentationTime(4) = Screen('Flip', window, time - halfFrame);
    startRespInterval = presentationTime(4);
    time = presentationTime(4) + orientRespInt;
    
    % Check for responses.
    if practiceStage > 2
        [orientAnswer, orientRespTime] = getResponse(time - 2*halfFrame);
    elseif practiceStage <= 2
        [orientAnswer, orientRespTime] = getResponse(Inf);
    end
    orientRT = orientRespTime - startRespInterval;
    
    % Remove any remaining keypresses
    FlushEvents('keyDown');
    
    if practiceStage > 4
        %% Present confidence response prompt
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
        DrawFormattedText(window, 'CONF?', 'center', height/2+respMap_Yoffset, [0 0 0]);
        presentationTime(5) = Screen('Flip', window, time - halfFrame);
        startConfRespInterval = presentationTime(5);
        time = presentationTime(5) + confRespInt;
        
        % Check for responses.
        % at 'time', the second grating needs to be removed; check for
        % responses until within one refresh of that time.
        [confAnswer, confRespTime] = getResponse(time - 2*halfFrame);
        confRT = confRespTime - startConfRespInterval;
    end
    
    % After the response interval, present the fixation point without
    % the circle around it, as a cue that the trial has ended.
    Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
    presentationTime(6) = Screen('Flip', window, time - halfFrame);
    reqPresentationTime(6) = time;
    
    if practiceStage > 2
        % If there was no (timely/valid) response, flicker the bull's eye
        if orientAnswer == -10
            % Present bull's eye
            Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
            fixFlicker_time = Screen('Flip', window, time + 0.1 - halfFrame);
            % Replace by fixation point
            Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
            Screen('Flip', window, fixFlicker_time + 0.1 - halfFrame);
        end
    end
    
    % Check if the response was correct
    if respMap == 1
        correct = gratingOrientation == orientAnswer;
    elseif respMap == 0
        correct = gratingOrientation == 3-orientAnswer;
    end
    fprintf('orient = %d\n',gratingOrientation);
    fprintf('respMap = %d\n',respMap);
    fprintf('answer = %d\n',orientAnswer);
    fprintf('correct = %d\n',correct);
    if practiceStage > 4
        fprintf('confidence = %d\n',confAnswer);
    end
    
    %Give feedback
    if feedback == 1
        if correct == 1
            textColour = [0 255 0];
            text = 'CORRECT!';
        elseif orientAnswer == -10
            textColour = [255 0 0];
            text = 'TOO SLOW!';
        else
            textColour = [255 0 0];
            text = 'WRONG!';
        end
        DrawFormattedText(window, text, 'center', height/2+100, textColour);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
        time = Screen('Flip',window);
        
        %remove feedback after 1 second
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
        Screen('Flip', window, time + 1 - halfFrame);
    end
    
    %Update the number of incorrect responses and time
    nCorrect = nCorrect + correct;
    
    %Update time
    ITI = 1.4;
    if mriTiming
        % add jitter
        intLengths = [0 1.5 3];
        intProps =   [0.5 0.3 0.2];
        x = rand;
        if x < intProps(1)
            intLength = intLengths(1);
        elseif x < intProps(1) + intProps(2)
            intLength = intLengths(2);
        else
            intLength = intLengths(3);
        end
        ITI = ITI + intLength;
    end
    time = time + ITI;
    
    %Save data
    presentation.cue(iTrial) = cue;
    presentation.tonePresented{iTrial} = tonePresented;
    presentation.predOrientation(iTrial) = predOrientation;
    presentation.gratingOrientation(iTrial) = gratingOrientation;
    presentation.gratingRotAngle(iTrial) = gratingRotAngle;
    presentation.gratingContrast(iTrial) = gratingContrast;
    presentation.gratingPhase(iTrial) = gratingPhase;
    presentation.noisePatch(iTrial) = noisePatch;
    presentation.respMap(iTrial) = respMap;
    presentation.orientAnswer(iTrial) = orientAnswer;
    presentation.orientRT(iTrial) = orientRT;
    if practiceStage > 4
        presentation.confAnswer(iTrial) = confAnswer;
        presentation.confRT(iTrial) = confRT;
    end
    presentation.answeredCorrect(iTrial) = correct;
    presentation.cueTime{iTrial} = cueTime;
    presentation.reqCueTime{iTrial} = reqCueTime;
    presentation.presentationTime{iTrial} = presentationTime;
    presentation.reqPresentationTime{iTrial} = reqPresentationTime;
    presentation.ITI(iTrial) = ITI;
    %     if ~practice
    %         presentation.qMean_updated(iTrial) = qMean_updated;
    %         presentation.qSD_updated(iTrial) = qSD_updated;
    %     end
    
    clear presentationTime reqPresentationTime
    
end

presentation.nTrialsPerBlock = nTrialsPerBlock;
presentation.nOrientations = nOrientations;
presentation.rotAngles = rotAngles;
presentation.orients = orients;
presentation.trialSequence = trialSequence;
presentation.toneOrientation = toneOrientation;
presentation.cueStimSOA = cueStimSOA;
presentation.feedback = feedback;
presentation.nCorrect = nCorrect;
presentation.time = time;

%KbQueueRelease(buttonDeviceID);

end