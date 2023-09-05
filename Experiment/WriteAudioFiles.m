% attributes of the auditory cue tone
toneFreqs = [450 1000]; % A4 C#5 E5
toneDur = 0.2;
sampleRate = 44100;
rampTime = 0.01; % rise and fall times of the tones.
cueStimSOA = 0.75; % SOA between cue and stimulus
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
    audiowrite('/Users/joosthaarsma/Documents/MATLAB',wavedata{iTone},sampleRate)
end
