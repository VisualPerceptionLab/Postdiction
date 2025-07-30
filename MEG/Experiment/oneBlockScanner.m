function presentation = oneBlock(time, volume, training, nTrials, sampleRate)

global environment window width height;
global background Lmax mriTiming;
global fixCrossTexture fixRect fixCrossTexture_dim fixCrossTexture_miss fixCrossTexture_ITI;
%global Q;
global pahandle subjID;
global buttonDeviceID;

PsychPortAudio('RunMode', pahandle, 1);

% data{1}.endPresentationTime(:,1) - data{1}.presentationTime(:,2)
sizemult = 1;
distancemult = 1.5;
pitch = 800;
visStimWidth = degrees2pixels(0.28)*sizemult; % .28 measured as .33 % 14; %28% calculated from degrees of flash size width
visStimLength = degrees2pixels(1.2)*sizemult; % 1.2 measured as 1.24 %118% calculated from degrees of flash size length
visStimEcc = degrees2pixels(1.42)*distancemult; % outside: 1.42*2*1.5+1xstim = 4.53  measured as 4.42 %degrees2pixels(2 * 1.42); %140% calculated from degrees from center, horizontal
FixMarkHeight = 0; % fixation mark seems to be quite high
visStimHeight = degrees2pixels(4.3);% measured as middle stim: 4.00, bottom stim with size 1: 4.62, so with size 1.5: 4.92 - FixMarkHeight; % 10 degrees under fixation mark = 986 pixels
stimColour = Lmax; 

% Durations
preOnset = 1;
% tested with Erik
beamer_latency = 0.048;
stimDur = 1/60;  %16.6ms
stimInterval = 3/60; %52ms inbetween stimuli
toneDur = 0.01; % now 10ms % 7ms
halfframe = 1/120;
toneFreqs = pitch; % postdiction % A4 C#5 E5
%flash_text = '';
%conf_text = '';
responseTime = 2;

params = struct("visStimWidth", visStimWidth, "visStimLength", visStimLength, "visStimEcc", visStimEcc, "visStimHeight", visStimHeight, "stimColour", stimColour, "preOnset", preOnset, "stimDur", stimDur, "stimInterval", stimInterval, "toneDur", toneDur, "toneFreqs", toneFreqs, "responseTime", responseTime);

%design = repmat([1 2 3 4],1,nTrials/4);
ExpDesign = transpose(getExperimentalDesign(nTrials)); %design(randperm(nTrials));
%ExpDesign = design(randperm(nTrials));
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
    presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,2) + stimDur - halfframe);
    startAudioTime(iTrial, 1) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,2) + beamer_latency,1);
    % Start audio playback at time 'time', return onset timestamp.
    
    % Duration between stimuli
    time = endPresentationTime(iTrial, 1) + stimInterval;
    
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    
    % just flip to keep timing right
    if thisCondition == 1
    presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
    end
    
    % if condition 2: flip and sound
    if thisCondition == 2
    % Audio cue 2
    % Start audio playback at time 'time', return onset timestamp.
    % calculate when new audio should come
    %presentationTime(iTrial,3) = Screen('Flip', window, startAudioTime(iTrial, 2) - halfframe);
    presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
    startAudioTime(iTrial, 2) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,3) + beamer_latency,1);
    end

    % if condition 3: rect
    % invisible rabbit
    if thisCondition == 3 
    % Visual cue 2
    Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim2_coord));
    presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
    %Show first visual stimulus one frame flip later for its indended
    end
    
    % if condition 4: rect, sound
    if thisCondition == 4 
    % Visual cue 2
    Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim2_coord));
    presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
    startAudioTime(iTrial, 2) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,3) + beamer_latency, 1);
    %presentationTime(iTrial,3) = Screen('Flip', window, startAudioTime(iTrial, 2) - halfframe);
    end

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
    
    %presentationTime(iTrial,4) = Screen('Flip', window, startAudioTime(iTrial, 3) - halfframe);
    presentationTime(iTrial,4) = Screen('Flip', window, time - halfframe);
    % flip to empty after 17ms
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    endPresentationTime(iTrial, 3) = Screen('Flip', window, presentationTime(iTrial,4) + stimDur - halfframe);
    startAudioTime(iTrial, 3) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial, 4) + beamer_latency ,1);
    % Start audio playback at time 'time', return onset timestamp.
    % wait before going to question
    time = endPresentationTime(iTrial, 3);
    
    % question 1
    %Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
%     DrawFormattedText(window, flash_text, 'center', height/2-50, [0 0 0]);
% 
%     tempPresentationTime(1) = Screen('Flip', window, time - halfframe);
%     time = tempPresentationTime(1) + responseTime;

    [flashAnswer, flashRespTime] = getResponse(time+responseTime);
    %time = flashRespTime + 1;
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
%     tempPresentationTime(1) = Screen('Flip', window, time-halfframe);
    %time = tempPresentationTime(1) + 1;
    
    % question 2
%     Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
%     DrawFormattedText(window, conf_text, 'center', height/2-50, [0 0 0]);
% 
%     tempPresentationTime(1) = Screen('Flip', window, time - halfframe);
%     time = tempPresentationTime(1) + confidenceTime;
    %remainderRespTime = responseTime - (flashRespTime - time); 
    [confAnswer, confRespTime] = getResponse_conf(time+responseTime);
    %remainderRespTime = remainderRespTime - (confRespTime-flashRespTime);
    
    
    % wait for the remainder of the response time
    time = time+responseTime;
     % If there was no (timely/valid) response, flicker the bull's eye
    if (flashAnswer == -10) || (confAnswer == -10)
        % Present red bull's eye dot.
        Screen('DrawTexture', window, fixCrossTexture_miss, fixRect, CenterRect(fixRect, [0 0 width height]));
        Screen('Flip', window, time + 0.3 - halfframe);
    end
    
    Screen('DrawTexture', window, fixCrossTexture_dim, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    tempPresentationTime(1) = Screen('Flip', window, time - halfframe);
    time = tempPresentationTime(1);

    % Duration of just ITI fixation mark
    % trials are 3.36-6.18s: increase by 1.7s
    ITI = 1.6; %0
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
    presentation.flashRespTime(iTrial) = flashRespTime;
    presentation.confRespTime(iTrial) = confRespTime;
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

end