function presentation = oneBlock(time, volume, training, nTrials, sampleRate, sizemult, distancemult, pitch)

global environment window width height;
global background Lmax mriTiming;
global fixCrossTexture fixRect fixCrossTexture_ITI;
%global Q;
global pahandle subjID;
global buttonDeviceID;

PsychPortAudio('RunMode', pahandle, 1);

% data{1}.endPresentationTime(:,1) - data{1}.presentationTime(:,2)

visStimWidth = degrees2pixels(0.28)*sizemult; % 14; %28% calculated from degrees of flash size width
visStimLength = degrees2pixels(1.2)*sizemult; %%118% calculated from degrees of flash size length
visStimEcc = degrees2pixels(1.42)*distancemult; %degrees2pixels(2 * 1.42); %140% calculated from degrees from center, horizontal
FixMarkHeight = 0; % fixation mark seems to be quite high
visStimHeight = degrees2pixels(4.3);% - FixMarkHeight; % 10 degrees under fixation mark = 986 pixels
stimColour = Lmax; %[230 230 230];

% Durations
preOnset = 1;% 23ms before first stimulus presentation
postOnset = preOnset; % same before as after
stimDur = 1/60; %2/60;%2 % 0.039; %0.017% 17ms show flash
stimInterval = 3/60; %2/60; %0.030; % 52ms inbetween stimuli
%audioInterval = 0.13; % 130ms audio interval
toneDur = 0.007; % 7ms
halfframe = 1/120;
toneFreqs = pitch; % postdiction % A4 C#5 E5
if training
    flash_text = 'How many flashes (2 or 3)?';
    conf_text = 'Confidence?';
    responseTime = 1.5;
    confidenceTime = 1.5;
else
    flash_text = '';
    conf_text = 'C?';
    responseTime = 1;
    confidenceTime = 1;
end

params = struct("visStimWidth", visStimWidth, "visStimLength", visStimLength, "visStimEcc", visStimEcc, "visStimHeight", visStimHeight, "stimColour", stimColour, "preOnset", preOnset, "stimDur", stimDur, "stimInterval", stimInterval, "toneDur", toneDur, "toneFreqs", toneFreqs, "responseTime", responseTime);

design = repmat([1 2 3 4],1,nTrials/4);
ExpDesign = design(randperm(nTrials));

%Start the sequence of trials
PsychPortAudio('RunMode', pahandle, 1);
% Initialise
[wavedata, sampleRate] = MakeBeep(toneFreqs, toneDur, sampleRate);
% hack wavedata to make it a square wave
wavedata(wavedata<0) = -1;
wavedata(wavedata>0) = 1;
wavedata = wavedata * volume;

currentTime = round(clock);
resultDir = fullfile(pwd,'Results',sprintf('S%02d',subjID));
if ~exist(resultDir,'dir'); mkdir(resultDir); end
resultFile = sprintf('backup_results_mainexp_%d_%d_%d_%d_%d_%d.mat',currentTime);
resultFile = fullfile(resultDir,resultFile);

vis_stim1_coord = [width/2-visStimEcc-(1/2)*visStimWidth height/2+visStimHeight-(1/2)*visStimLength width/2-visStimEcc+(1/2)*visStimWidth height/2+visStimHeight+(1/2)*visStimLength];
vis_stim2_coord = [width/2-0-(1/2)*visStimWidth height/2+visStimHeight-(1/2)*visStimLength width/2-0+(1/2)*visStimWidth height/2+visStimHeight+(1/2)*visStimLength];
vis_stim3_coord = [width/2+visStimEcc-(1/2)*visStimWidth height/2+visStimHeight-(1/2)*visStimLength width/2+visStimEcc+(1/2)*visStimWidth height/2+visStimHeight+(1/2)*visStimLength];

for iTrial=1:nTrials
    % select condition
    thisCondition = ExpDesign(iTrial);

    % Present the fixation bull's eye, as a cue of trial onset
    %Screen('DrawText', window , '+', fixRect , CenterRect(fixRect, [0 0 width height]));
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    % presentationTime keeps the start time of trial and show time of all visual
    % cues
    presentationTime(iTrial,1) = Screen('Flip', window, time - halfframe);
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    
    % Stimulus Pair 1
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
   
    Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim1_coord));
    
    %PK: first rectangle coordinates
    %vis_stim1_coord = [width/2-visStimEcc-(1/2)*visStimWidth height/2+visStimHeight-(1/2)*visStimLength width/2-visStimEcc+(1/2)*visStimWidth height/2+visStimHeight+(1/2)*visStimLength]
    
    
    % Show first visual stimulus one frame flip later for its indended
    % duration
    % 1st stimulus time shown
    %startAudioTime(iTrial, 1) = PsychPortAudio('Start', pahandle, 1, time ,0);
    time = presentationTime(iTrial,1) + preOnset;
    startAudioTime(iTrial, 1) = PsychPortAudio('Start', pahandle, 1, time ,1);
    presentationTime(iTrial,2) = Screen('Flip', window, startAudioTime(iTrial, 1) - halfframe);
    
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,2) + stimDur - halfframe);
    % Start audio playback at time 'time', return onset timestamp.
    
    % Duration between stimuli
    time = endPresentationTime(iTrial, 1) + stimInterval;
    
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    
    % just flip to keep timing right
    if thisCondition == 1
    presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
    end
    
    % if condition 2: flip and sound
    if thisCondition == 2
    % Audio cue 2
    % Start audio playback at time 'time', return onset timestamp.
    % calculate when new audio should come
    startAudioTime(iTrial, 2) = PsychPortAudio('Start', pahandle, 1, time ,1);
    presentationTime(iTrial,3) = Screen('Flip', window, startAudioTime(iTrial, 2) - halfframe);
    
    end

    % if condition 3: rect
    % invisible rabbit
    if thisCondition == 3 
    % Visual cue 2
    Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim2_coord));
    presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
    %Show first visual stimulus one frame flip later for its indended
    end
    
    % if condition 4: rect, sound
    if thisCondition == 4 
    % Visual cue 2
    Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim2_coord));
    startAudioTime(iTrial, 2) = PsychPortAudio('Start', pahandle, 1, time ,1);
    presentationTime(iTrial,3) = Screen('Flip', window, startAudioTime(iTrial, 2) - halfframe);
    end

    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
    time = endPresentationTime(iTrial, 2) + stimInterval;

%     % Stimulus (Pair) 2
%     PsychPortAudio('FillBuffer', pahandle, wavedata);
%     % Start audio playback at time 'time', return onset timestamp.
%     PsychPortAudio('Start', pahandle, 1);
%     % Stimulus Pair 1
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
%     Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], [0 visStimHeight width height]));
%     % Show first visual stimulus one frame flip later for its indended
%     % duration
%     presentationTime(1) = Screen('Flip', window, time);
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
%     presentationTime(1) = Screen('Flip', window, presentationTime(1) + stimDur);
%     time = presentationTime(1) + stimInterval;


    % Stimulus Pair 3
    
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim3_coord));
    % interspace with some time
    % follow with visual stimulus one frame later
    startAudioTime(iTrial, 3) = PsychPortAudio('Start', pahandle, 1, time ,1);
    presentationTime(iTrial,4) = Screen('Flip', window, startAudioTime(iTrial, 3) - halfframe);
    % flip to empty after 17ms
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    
    endPresentationTime(iTrial, 3) = Screen('Flip', window, presentationTime(iTrial,4) + stimDur - halfframe);
    % Start audio playback at time 'time', return onset timestamp.
    % wait before going to question
    time = endPresentationTime(iTrial, 3);%+ postOnset;
    
    % question 1
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    DrawFormattedText(window, flash_text, 'center', height/2-40, [0 0 0]);

    tempPresentationTime(1) = Screen('Flip', window, time - halfframe);
    time = tempPresentationTime(1) + responseTime;

    [flashAnswer, flashRespTime] = getResponse(time-halfframe);
    %time = flashRespTime + 1;
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    tempPresentationTime(1) = Screen('Flip', window, time-halfframe);
    %time = tempPresentationTime(1) + 1;
    
    % question 2
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    DrawFormattedText(window, conf_text, 'center', height/2-40, [0 0 0]);

    tempPresentationTime(1) = Screen('Flip', window, time - halfframe);
    time = tempPresentationTime(1) + confidenceTime;
    [confAnswer, confRespTime] = getResponse(time-halfframe);
    
    Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    tempPresentationTime(1) = Screen('Flip', window, time - halfframe);
    time = tempPresentationTime(1);
     % If there was no (timely/valid) response, flicker the bull's eye
    if (flashAnswer == -10) || (confAnswer == -10)
        % Present bull's eye
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
        fixFlicker_time = Screen('Flip', window, time + 0.1 - halfframe);
        % Replace by fixation point
        Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
        Screen('Flip', window, fixFlicker_time + 0.1 - halfframe);
    end
    
    % Duration of just ITI fixation mark
    ITI = 0;
    if mriTiming
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
    
    presentation.confAnswer(iTrial) = confAnswer;
    presentation.flashAnswer(iTrial) = flashAnswer;
    presentation.condition(iTrial) = thisCondition;
    presentation.time = time;
    presentation.startAudioTime = startAudioTime
    presentation.endPresentationTime = endPresentationTime
    presentation.presentationTime = presentationTime
    presentation.params = params;
    % random iti for decorrelation fmri signal
    %time = presentationTime(1) + ITI + (2*rand);

    %presentation.confAnswer(iTrial) = confAnswer;
    
    % time that question should remain
    %time = confRespTime;

    save(resultFile, 'presentation');
end
% amount of flashes we expect to see per condition (incl. illusory)
hypothesisAns = [2 3 2 3];
for i=1:4
    expectedAns(ExpDesign==i) = hypothesisAns(i);
end
% map hypothesis to condition
%expectedAns = changem(ExpDesign, hypothesisAns, [1 2 3 4]);
asExpected = presentation.flashAnswer == expectedAns;
totalScore = sum(asExpected)/nTrials;

% extract trials that were as expected (mask)
succesfulTrials = asExpected .* ExpDesign;
% find correct trials as fraction of total trials per condition
twoVeridicalscore = numel(find(succesfulTrials==1)) / (nTrials/4);
AVscore = numel(find(succesfulTrials==2)) / (nTrials/4);
IVscore = numel(find(succesfulTrials==3)) / (nTrials/4);
threeVeridicalscore = numel(find(succesfulTrials==4)) / (nTrials/4);

% average confidence rating per condition
conditionConf = zeros(1, 4);
for i=1:4
    condIndices = find(ExpDesign==i);
    exclNegatives = presentation.confAnswer(condIndices);
    exclNegatives = exclNegatives(exclNegatives>0);
    condConfmean = mean(exclNegatives) - 10;
    conditionConf(i) = condConfmean;
end
presentation.totalScore = totalScore
presentation.twoVeridicalscore = twoVeridicalscore
presentation.threeVeridicalscore = threeVeridicalscore
presentation.IVscore = IVscore
presentation.AVscore = AVscore
presentation.conditionConf = conditionConf

%Screen('CloseAll')

end
% 
%     reqPresentationTime(1) = time;
%     time = presentationTime(1) + fixCueInt;
%     
%     %% Present the auditory cue.
%     if isnan(cue) || strcmp(practice,'stage1')
%         % no auditory cue; just update 'time' and set some variables (to
%         % avoid errors).
%         time = time + cueStimSOA;
%         reqCueTime = NaN;
%         cueTime = NaN;
%     else
%         % present the auditory cue
%         reqCueTime = time;
%         % Fill the audio playback buffer with the audio data 'wavedata':
%         PsychPortAudio('FillBuffer', pahandle, wavedata{tonePresented});
%         % Start audio playback at time 'time', return onset timestamp.
%         cueTime = PsychPortAudio('Start', pahandle, 1, reqCueTime, 1);
%         
%         time = cueTime + cueStimSOA; % Present the stimulus after the cue
%         
% %         if strcmp(environment,'mri') || strcmp(environment,'mri_offline')
% %             % send a message to the eyetracker
% %             text = sprintf('CUE%d',cue);
% %             Eyelink('Message', text);
% %         end
%     end
%     
%     %% Prepare and show the grating (or noise) stimulus
%     noisePatch = trialSequence(iTrial,4);
%     if ~isnan(gratingOrientation)
%         stimulusMatrix = makeStimulus(gratingContrast,noiseContrast,noisePatch,gratingSize_degrees,gratingPhase,spatFreq,innerDegree);
%     else
%         stimulusMatrix = makeStimulus(0,noiseContrast,noisePatch,gratingSize_degrees,gratingPhase,spatFreq,innerDegree);
%     end
%     readyStimulus = Screen('MakeTexture', window, stimulusMatrix);
%     Screen('DrawTexture', window, readyStimulus, [], destSquare, gratingRotAngle);
%     Screen('Close',readyStimulus);
%     %Screen('FrameOval', window, placeholderColour, placeholderDestSquare, lineWidth);
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%     presentationTime(2) = Screen('Flip', window, time - halfFrame);
%     reqPresentationTime(2) = time;
%     time = presentationTime(2) + gratingDur;
%     
%     if saveStim
%         imageArray = Screen('GetImage', window);
%         stimName = sprintf('oneBlock_stim_trial%d.tiff',iTrial);
%         imwrite(imageArray, stimName)
%     end
%     
%     %% Remove the stimulus and display the fixation bull's eye again
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%     presentationTime(3) = Screen('Flip', window, time - halfFrame);
%     reqPresentationTime(3) = time;
%     time = presentationTime(3) + respDelay;
% 
%     % Remove any keypresses that occured before presentation of the grating.
%     FlushEvents('keyDown');
%     
%     %% Present orientation response options
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%     respMap = trialSequence(iTrial,3);
% 
%     if respMap == 1
%         %Screen('DrawLine', window, [0 0 0], width/2-respMap_Xoffset-respMap_lineSize, height/2+respMap_Yoffset+respMap_lineSize, width/2-respMap_Xoffset, height/2+respMap_Yoffset, respMap_lineWidth);
%         %Screen('DrawLine', window, [0 0 0], width/2+respMap_Xoffset+respMap_lineSize, height/2+respMap_Yoffset+respMap_lineSize, width/2+respMap_Xoffset, height/2+respMap_Yoffset, respMap_lineWidth);
%         %DrawFormattedText(window, '<', width/2-respMap_Xoffset, 'center', [0 0 0]);
%         %DrawFormattedText(window, '>', width/2+respMap_Xoffset, 'center', [0 0 0]);
%         %DrawFormattedText(window, 'A    B', 'center', height/2+respMap_Yoffset, [0 0 0]);
%         %DrawFormattedText(window, 'A                               B', 'center', height/2+respMap_Yoffset, [0 0 0]);
%          DrawFormattedText(window, '<         >', 'center', 'center', [0 0 0]);
%     elseif respMap == 0
%         %Screen('DrawLine', window, [0 0 0], width/2-respMap_Xoffset-respMap_lineSize, height/2+respMap_Yoffset, width/2-respMap_Xoffset, height/2+respMap_Yoffset+respMap_lineSize, respMap_lineWidth);
%         %Screen('DrawLine', window, [0 0 0], width/2+respMap_Xoffset+respMap_lineSize, height/2+respMap_Yoffset, width/2+respMap_Xoffset, height/2+respMap_Yoffset+respMap_lineSize, respMap_lineWidth);
%         %DrawFormattedText(window, '>', width/2-respMap_Xoffset, 'center', [0 0 0]);
%         %DrawFormattedText(window, '<', width/2+respMap_Xoffset, 'center', [0 0 0]);
%         %DrawFormattedText(window, 'B    A', 'center', height/2+respMap_Yoffset, [0 0 0]);
%         %DrawFormattedText(window, 'B                               A', 'center', height/2+respMap_Yoffset, [0 0 0]);
%          DrawFormattedText(window, '>         <', 'center', 'center', [0 0 0]);
%     end
%     
%     presentationTime(4) = Screen('Flip', window, time - halfFrame);
%     startRespInterval = presentationTime(4);
%     time = presentationTime(4) + orientRespInt;
%     
%     % Check for responses.
%     % at 'time', the second grating needs to be removed; check for
%     % responses until within one refresh of that time.
%     [orientAnswer, orientRespTime] = getResponse(time - 2*halfFrame);
%     orientRT = orientRespTime - startRespInterval;
%     
%     % Remove any remaining keypresses
%     FlushEvents('keyDown');
%     
%     %% Present confidence response prompt
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%     DrawFormattedText(window, 'CONF?', 'center', height/2+respMap_Yoffset, [0 0 0]);
%     presentationTime(5) = Screen('Flip', window, time - halfFrame);
%     startConfRespInterval = presentationTime(5);
%     time = presentationTime(5) + confRespInt;
%     
%     % Check for responses.
%     % at 'time', the second grating needs to be removed; check for
%     % responses until within one refresh of that time.
%     [confAnswer, confRespTime] = getResponse(time - 2*halfFrame);
%     confRT = confRespTime - startConfRespInterval;
%     
%     % After the response interval, present the fixation point without
%     % the circle around it, as a cue that the trial has ended.
%     Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
%     presentationTime(6) = Screen('Flip', window, time - halfFrame);
%     reqPresentationTime(6) = time;
%     
%     % If there was no (timely/valid) response, flicker the bull's eye
%     if (orientAnswer == -10) || (confAnswer == -10)
%         % Present bull's eye
%         Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%         fixFlicker_time = Screen('Flip', window, time + 0.1 - halfFrame);
%         % Replace by fixation point
%         Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
%         Screen('Flip', window, fixFlicker_time + 0.1 - halfFrame);
%     end
%     
%     % Check if the response was correct
%     if respMap == 1
%         correct = gratingOrientation == orientAnswer;
%     elseif respMap == 0
%         correct = gratingOrientation == 3-orientAnswer;
%     end
% %     fprintf('orient = %d\n',gratingOrientation);
% %     fprintf('respMap = %d\n',respMap);
% %     fprintf('answer = %d\n',orientAnswer);
% %     fprintf('correct = %d\n',correct);
% %     fprintf('confidence = %d\n',confAnswer);
%     
%     %         % update Quest
%     %         if ~practice
%     %             % Update the relevant Quest structure.
%     %             % Only update if there was a response.
%     %             if answer ~= -10
%     %                 if runType == 1  || runType == 3
%     %                     orientationQ = QuestUpdate(orientationQ,(log10(abs(orientationDiff))),correct);
%     %                     qMean_updated = QuestMean(orientationQ);
%     %                     qSD_updated = QuestSd(orientationQ);
%     %                 elseif runType == 2  || runType == 4
%     %                     contrastQ = QuestUpdate(contrastQ,(log10(abs(contrastDiff))),correct);
%     %                     qMean_updated = QuestMean(contrastQ);
%     %                     qSD_updated = QuestSd(contrastQ);
%     %                 else % what happened?
%     %                     answer = aaa;
%     %                 end
%     %             else
%     %                 qMean_updated = NaN;
%     %                 qSD_updated = NaN;
%     %             end
%     %         end
%     
%     %Give feedback
%     if feedback == 1
%         if correct == 1
%             textColour = [0 255 0];
%             text = 'CORRECT!';
%         elseif orientAnswer == -10
%             textColour = [255 0 0];
%             text = 'TOO SLOW!';
%         else
%             textColour = [255 0 0];
%             text = 'WRONG!';
%         end
%         DrawFormattedText(window, text, 'center', height/2+50, textColour);
%         Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%         time = Screen('Flip',window);
%         
%         %remove feedback after 1 second
%         Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%         Screen('Flip', window, time + 1 - halfFrame);
%     end
%     
%     %Update the number of incorrect responses and time
%     nCorrect = nCorrect + correct;
%     
%     %Update time
%     ITI = 1.4;
%     if mriTiming
%         % add jitter
%         intLengths = [0 1.5 3];
%         intProps =   [0.5 0.3 0.2];
%         x = rand;
%         if x < intProps(1)
%             intLength = intLengths(1);
%         elseif x < intProps(1) + intProps(2)
%             intLength = intLengths(2);
%         else
%             intLength = intLengths(3);
%         end
%         ITI = ITI + intLength;
%     end
%     time = time + ITI;
%     
%     %Save data
%     presentation.cue(iTrial) = cue;
%     presentation.tonePresented{iTrial} = tonePresented;
%     presentation.predOrientation(iTrial) = predOrientation;
%     presentation.gratingOrientation(iTrial) = gratingOrientation;
%     presentation.gratingRotAngle(iTrial) = gratingRotAngle;
%     presentation.gratingContrast(iTrial) = gratingContrast;
%     presentation.gratingPhase(iTrial) = gratingPhase;
%     presentation.noisePatch(iTrial) = noisePatch;
%     presentation.respMap(iTrial) = respMap;
%     presentation.orientAnswer(iTrial) = orientAnswer;
%     presentation.confAnswer(iTrial) = confAnswer;
%     presentation.orientRT(iTrial) = orientRT;
%     presentation.confRT(iTrial) = confRT;
%     presentation.answeredCorrect(iTrial) = correct;
%     presentation.cueTime{iTrial} = cueTime;
%     presentation.reqCueTime{iTrial} = reqCueTime;
%     presentation.presentationTime{iTrial} = presentationTime;
%     presentation.reqPresentationTime{iTrial} = reqPresentationTime;
%     presentation.ITI(iTrial) = ITI;
%     %     if ~practice
%     %         presentation.qMean_updated(iTrial) = qMean_updated;
%     %         presentation.qSD_updated(iTrial) = qSD_updated;
%     %     end
%     
%     clear presentationTime reqPresentationTime
%     
% end
% 
% presentation.nTrialsPerBlock = nTrialsPerBlock;
% presentation.nOrientations = nOrientations;
% presentation.rotAngles = rotAngles;
% presentation.orients = orients;
% presentation.trialSequence = trialSequence;
% presentation.toneOrientation = toneOrientation;
% presentation.cueStimSOA = cueStimSOA;
% presentation.feedback = feedback;
% presentation.nCorrect = nCorrect;
% presentation.time = time;
% 
% %KbQueueRelease(buttonDeviceID);
% 
% end