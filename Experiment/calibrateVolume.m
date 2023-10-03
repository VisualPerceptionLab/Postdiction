% calibrateVolume
%
% This script plays sounds and let's the participant increase or decrease
% the volume.

clear all; close all;

%global environment;
global pahandle;

try
    
    [mriTiming, waitTime] = setEnvironment(true); % Initialise environment, including audio.
    KbName('UnifyKeyNames');
    
    subjID = input('Subject number?: ');
    resultDir = fullfile(pwd,'Results',sprintf('S%02d',subjID));
    if ~exist(resultDir,'dir'); mkdir(resultDir); end;
    
    % attributes of the auditory cue tone
    %toneFreqs = [500 800 1100]; % Frequencies used by Sander Bosch
    %toneFreqs = [440 554 659]; % A4 C#5 E5
    %toneDur = 0.08;
    toneInt = 0.005;
    sampleRate = 44100;
    %rampTime = 0.01; % rise and fall times of the tones.
    toneDur = 0.007; % 7ms
    toneFreqs = 2000; % 800hz postdiction % A4 C#5 E5
    SOA = 0.75; % SOA between tone sequences
    
    % create tones
    wavedata = cell(1,length(toneFreqs));
    for iTone = 1:length(toneFreqs)
        %[wavedata{iTone}, sampleRate] = MakeBeep(toneFreqs(iTone), toneDur, sampleRate);
        % add linear rise and fall ramps
        %ramp = 0:1/(rampTime*sampleRate):1;
        %wavedata{iTone}(1:length(ramp)) = wavedata{iTone}(1:length(ramp)) .* ramp;
        %ramp = ramp(end:-1:1);
        %wavedata{iTone}(1+end-length(ramp):end) = wavedata{iTone}(1+end-length(ramp):end) .* ramp;
        [wavedata, sampleRate] = MakeBeep(toneFreqs, toneDur, sampleRate);
        % hack wavedata to make it a square wave
        wavedata(wavedata<0) = -1;
        wavedata(wavedata>0) = 1;
    end
    curWavedata = wavedata;
    
    cue = 1;
    volume = 1;
    time = GetSecs + 1;
    while 1
        cue = 3 - cue;
        if cue == 1
            toneOrder = [1 2 3];
        elseif cue == 2
            toneOrder = [3 2 1];
        end
        
        % present the auditory cue
        reqCueTime(1) = time;
        for iTone = 1:length(toneFreqs)
            % Fill the audio playback buffer with the audio data 'wavedata':
            PsychPortAudio('FillBuffer', pahandle, curWavedata);
            % Start audio playback at time 'time', return onset timestamp.
            cueTime(iTone) = PsychPortAudio('Start', pahandle, 1, reqCueTime(iTone), 1);
            reqCueTime(iTone+1) = cueTime(iTone) + toneDur + toneInt;
        end
        reqCueTime = reqCueTime(1:length(toneFreqs));
        
        time = cueTime(1) + SOA; % Present the stimulus after the cue
        
        % Wait for response (this is after the second grating), unless a
        % response was already given.
        while GetSecs < time - 0.050;
            [answer, respTime] = getResponse(GetSecs + 0.050); % look for responses
            switch answer
                case 1
                    % turn volume down
                    volume = 0.995*volume % 0.95
                    FlushEvents('keyDown');
                case 2
                    % turn volume up
                    volume = 1.005*volume % 1.05
                    FlushEvents('keyDown');
            end
            % adjust volume of tones
            for iTone = 1:length(toneFreqs)
                curWavedata = wavedata * volume;
            end
            % save volume
            save(fullfile(resultDir,'volume.mat'),'volume');
        end
        
    end
    
catch aloha
    
    % Close the audio device:
    PsychPortAudio('Close', pahandle);
    
    psychrethrow(psychlasterror);
end