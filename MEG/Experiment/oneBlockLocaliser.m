function presentation = oneBlock(time, volume, training, nTrials, sampleRate)

global environment window width height;
global background Lmax mriTiming;
global fixCrossTexture fixRect fixCrossTexture_dim fixCrossTexture_miss fixCrossTexture_ITI;
%global Q;
global pahandle subjID;
global buttonDeviceID;
global localizer_count;

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
preOnset = 0.1;
% MEG wiki
beamer_latency = 1/60;
stimDur = 1/60;  %16.6ms
stimInterval = 3/60; %52ms inbetween stimuli
toneDur = 0.01; % now 10ms % 7ms
halfframe = 1/120;
toneFreqs = pitch; % postdiction % A4 C#5 E5
%flash_text = '';
%conf_text = '';
% responseTime = 2;

params = struct("visStimWidth", visStimWidth, "visStimLength", visStimLength, "visStimEcc", visStimEcc, "visStimHeight", visStimHeight, "stimColour", stimColour, "preOnset", preOnset, "stimDur", stimDur, "stimInterval", stimInterval, "toneDur", toneDur, "toneFreqs", toneFreqs);

design = repmat(1:localizer_count,1,nTrials/7);
% ExpDesign = transpose(getExperimentalDesign(nTrials)); %design(randperm(nTrials));
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
resultFile = sprintf('backup_localiser_mainexp_%d_%d_%d_%d_%d_%d.mat',currentTime);
resultFile = fullfile(resultDir,resultFile);

vis_stim1_coord = [width/2-visStimEcc-(1/2)*visStimWidth height/2+visStimHeight-(1/2)*visStimLength width/2-visStimEcc+(1/2)*visStimWidth height/2+visStimHeight+(1/2)*visStimLength];
vis_stim2_coord = [width/2-0-(1/2)*visStimWidth height/2+visStimHeight-(1/2)*visStimLength width/2-0+(1/2)*visStimWidth height/2+visStimHeight+(1/2)*visStimLength];
vis_stim3_coord = [width/2+visStimEcc-(1/2)*visStimWidth height/2+visStimHeight-(1/2)*visStimLength width/2+visStimEcc+(1/2)*visStimWidth height/2+visStimHeight+(1/2)*visStimLength];

% Wait second before block starts.
time = time + 1;

for iTrial=1:nTrials
    % select condition
    thisCondition = ExpDesign(iTrial);
    
    startAudioTime(iTrial, 1) = 0;
    % Present the fixation bull's eye, as a cue of trial onset
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    % presentationTime keeps the start time of trial and show time of all visual
    presentationTime(iTrial,1) = Screen('Flip', window, time - halfframe);
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    
   
    % Flash localiser: left flash
    if thisCondition == 1
        % Flash 1
        time = presentationTime(iTrial,1) + preOnset;
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height])); 
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim1_coord));
        presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,2) + stimDur - halfframe);

        time = endPresentationTime(iTrial, 1);

    % Flash localiser: middle flash
    elseif thisCondition == 2
        % Flash 2
        time = presentationTime(iTrial,1) + preOnset + stimDur + stimInterval;
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height])); 
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim2_coord));
        presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,2) + stimDur - halfframe);

        time = endPresentationTime(iTrial, 1);

    % Flash localiser: right flash
    elseif thisCondition == 3
        % Flash 3
        time = presentationTime(iTrial,1) + preOnset + stimDur*2 + stimInterval*2;
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height])); 
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim3_coord));
        presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,2) + stimDur - halfframe);

        time = endPresentationTime(iTrial, 1);

    % Flash localiser: left, middle, right
    elseif thisCondition == 4
        % Flash 1
        time = presentationTime(iTrial,1) + preOnset;
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height])); 
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim1_coord));
        presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,2) + stimDur - halfframe);

        % Duration between stimuli
        time = endPresentationTime(iTrial, 1) + stimInterval;

        % Flash 2
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim2_coord));
        presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
        
        % Duration between stimuli
        time = endPresentationTime(iTrial, 2) + stimInterval;

        % Flash 3
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim3_coord));
        presentationTime(iTrial,4) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 3) = Screen('Flip', window, presentationTime(iTrial,4) + stimDur - halfframe);

        time = endPresentationTime(iTrial, 3);
    
    % Flash localiser: left, right
    elseif thisCondition == 5
        % Flash 1
        time = presentationTime(iTrial,1) + preOnset;
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height])); 
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim1_coord));
        presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,2) + stimDur - halfframe);

        % Duration between stimuli
        time = endPresentationTime(iTrial, 1) + stimInterval;

        % Flash 2
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
        
        % Duration between stimuli
        time = endPresentationTime(iTrial, 2) + stimInterval;

        % Flash 3
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        Screen('FillRect', window, stimColour, CenterRect([0 0 visStimWidth visStimLength], vis_stim3_coord));
        presentationTime(iTrial,4) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 3) = Screen('Flip', window, presentationTime(iTrial,4) + stimDur - halfframe);

        time = endPresentationTime(iTrial, 3);
    
    % Tone localiser: first, second, third
    elseif thisCondition == 6
        % Tone 1
        time = presentationTime(iTrial,1) + preOnset;
        presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
        startAudioTime(iTrial, 1) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,3) + beamer_latency,1);

        % Duration between stimuli
        time = endPresentationTime(iTrial, 1) + stimInterval;
        
        % Tone 2
        presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
        startAudioTime(iTrial, 2) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,3) + beamer_latency,1);

        % Duration between stimuli
        time = endPresentationTime(iTrial, 2) + stimInterval;
        
        % Tone 3
        presentationTime(iTrial,4) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 3) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
        startAudioTime(iTrial, 3) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,3) + beamer_latency,1);

        time = endPresentationTime(iTrial, 3);

    % Tone localiser: first, third
    elseif thisCondition == 7
        % Tone 1
        time = presentationTime(iTrial,1) + preOnset;
        presentationTime(iTrial,2) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 1) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
        startAudioTime(iTrial, 1) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,3) + beamer_latency,1);

        % Duration between stimuli
        time = endPresentationTime(iTrial, 1) + stimInterval;
        
        % Tone 2
        presentationTime(iTrial,3) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 2) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);

        % Duration between stimuli
        time = endPresentationTime(iTrial, 2) + stimInterval;
        
        % Tone 3
        presentationTime(iTrial,4) = Screen('Flip', window, time - halfframe);
        Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
        endPresentationTime(iTrial, 3) = Screen('Flip', window, presentationTime(iTrial,3) + stimDur - halfframe);
        startAudioTime(iTrial, 3) = PsychPortAudio('Start', pahandle, 1, presentationTime(iTrial,3) + beamer_latency,1);

        time = endPresentationTime(iTrial, 3);
    end
    
    
    
     
     % If there was no (timely/valid) response, flicker the bull's eye
  
    % Duration of just ITI fixation mark
    % trials are 3.36-6.18s: increase by 1.7s
    ITI = 1; %0
    if mriTiming
        intLengths = [-0.1 0 0.1];
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

    Screen('DrawTexture', window, fixCrossTexture_dim, fixRect, CenterRect(fixRect, [0 -FixMarkHeight width height]));
    tempPresentationTime(1) = Screen('Flip', window, time - halfframe);
    time = tempPresentationTime(1);
    [~, time] = getResponse(time+ITI);


    presentation.condition(iTrial) = thisCondition;
    presentation.time = time;
    presentation.startAudioTime = startAudioTime
    presentation.endPresentationTime = endPresentationTime
    presentation.presentationTime = presentationTime
    presentation.params = params;

    save(resultFile, 'presentation');
end

end