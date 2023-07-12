%Play a sound

%What kind of beeps?
% Thut et al, JNS 2006: 50 ms auditory cue, instructing subjects to
% covertly direct their attention either to the left (100 Hz tone) or to the right (800 Hz tone)
% Den Ouden et al, CerCor 2009: 450 and 1000 Hz. But 500 ms long!

freq1 = 500;
freq2 = 1000;
duration = 0.250;
sampleRate = 44100;

KbName('UnifyKeyNames');
escape = KbName('escape');

audioDeviceID = 8 % Which audio device?

% Perform basic initialization of the sound driver:
InitializePsychSound;

nrchannels = 1; % One channel only -> Mono sound.

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
pahandle = PsychPortAudio('Open', audioDeviceID, [], 0, sampleRate, nrchannels);

PsychPortAudio('RunMode', pahandle, 1);


% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.
buttonpress = 0;
count = 0;
while buttonpress == 0
    count = count + 1;
    if mod(count,2) == 1
        [wavedata, sampleRate] = MakeBeep(freq1, duration , sampleRate);
    else
        [wavedata, sampleRate] = MakeBeep(freq2, duration , sampleRate);
    end
    
    % add linear rise and fall ramps
    rampTime = 0.01;
    ramp = 0:1/(rampTime*sampleRate):1;
    wavedata(1:length(ramp)) = wavedata(1:length(ramp)) .* ramp;
    ramp = ramp(end:-1:1);
    wavedata(1+end-length(ramp):end) = wavedata(1+end-length(ramp):end) .* ramp;
    
    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, wavedata);

    t1 = PsychPortAudio('Start', pahandle, 1, GetSecs+1.0, 1);
    
    while GetSecs < t1+0.250
        [keyIsDown,respTime,keyCode]=KbCheck;
        if keyIsDown
            if keyCode(escape)
                buttonpress = 1; % end tone presentation
            end
        end
    end
end
% Stop playback:
PsychPortAudio('Stop', pahandle);

% Close the audio device:
PsychPortAudio('Close', pahandle);