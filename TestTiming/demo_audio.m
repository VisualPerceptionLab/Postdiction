%% Very basic audio script
% Plays 2 seconds of white noise on the default sound playback device

%% PsychToolbox basic setup
PsychDefaultSetup(2);                                   % apply common Psychtoolbox parameters
InitializePsychSound;                                   % initialize Psychtoolbox audio

%% Sound setup
if PsychPortAudio('GetOpenDeviceCount')                 % check to see if a PortAudio device is still open...
    PsychPortAudio('Close');                            % ...and close it if necessary
end
paudio = PsychPortAudio('Open');                        % open default sound playback device using lowest latency interface
status = PsychPortAudio('GetStatus',paudio);            % Get audio device status
fs = status.SampleRate;                                 % ...extract sample rate

%% Stimulus setup
duration = 2;                                           % set sound stimulus duration (seconds)
wav = rand(2,fs*duration);                              % create white noise stimulus for duration @ sample rate
PsychPortAudio('FillBuffer',paudio,wav);                % load stimulus into sound buffer

%% Play stimulus
PsychPortAudio('Start',paudio, 1,0,1);                  % play stimulus and save start time
[tstart,~,~,tstop] = PsychPortAudio('Stop',paudio,3,1); % ... and wait until the sound stops playing
tstop-tstart                                            % display sound duration

%% Tidy up & end
PsychPortAudio('Close');                                % close audio device
