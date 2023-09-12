%% PTB audio jitter test
% Open screen, on the 2nd monitor (if available)
% flip screen, play sound
% Close screen

%% Parameters
nstim = 10000;
f = 440;                                        % sound frequency
duration = 0.008;                               % sound duration
port = hex2dec('3ff8');                         % parallel port address
uselpt = true;                                  % use parallel port?

%% Parallel port setup
if uselpt
    io = io64;
    status = io64(io);
    assert( status == 0, 'Parallel port not opened!' )
    io64(io,port,0);
end

%% PsychToolbox basic setup
PsychDefaultSetup(2);                           % apply common Psychtoolbox parameters
Screen('Preference', 'SkipSyncTests', 1);       % suppress warnings about VBL timing
InitializePsychSound;                           % initialize Psychtoolbox audio

%% Keyboard setup
KbName('UnifyKeyNames');                        % improve portability of your code acorss operating systems
activeKeys = [KbName('ESCAPE')];                % specify key names of interest in the study
RestrictKeysForKbCheck(activeKeys);             % restrict the keys for keyboard input to the keys we want
KbQueueCreate                                   % create a keyboard queue
KbQueueStart                                    % start the keyboard queue recording

%% Audio setup
if PsychPortAudio('GetOpenDeviceCount')         % check to see if a PortAudio device is still open...
    PsychPortAudio('Close');                    % ...and close it if necessary
end
paudio = PsychPortAudio('Open');                % open default sound playback device using lowest latency interface
status = PsychPortAudio('GetStatus',paudio);    % Get audio device status
fs = status.SampleRate;                         % ...extract sample rate

%% Screen setup & open
scn = max(Screen('Screens'));                   % find second screen if connected
[pWin,wRect] = Screen('OpenWindow',scn);        % open a display window
[wWidth,wHeight] = Screen('WindowSize',pWin);   % find window width & height
[x0,y0] = RectCenter(wRect);                    % find the centre of the window
Screen('TextFont', pWin, 'Arial');              % Set typeface
Screen('TextSize', pWin, 30);                   % Set fontsize
Screen('TextStyle', pWin, 0);                   % Set style as sum of: Normal=0, bold=1, italic=2, underline=4, outline=8, condense=32, extend=64

%% Audio prepare stim 1
t = 1:floor( fs*duration );
wav = sin( 2*pi*f*t/fs );
PsychPortAudio('FillBuffer',paudio,[wav;wav]);  % load stimulus into sound buffer

%% Visual prepare frame 1
Screen('FillRect', pWin);
Screen('DrawText',pWin,'+',x0,y0);
Screen('FillRect', pWin, [0 0 0], [0 0 50 50]);

% stats
tvis       = zeros(nstim,3);
taud.start = zeros(nstim,1);
taud.stop  = zeros(nstim,1);

%% main loop
for n=1:nstim
    % frame 1 (& prepare frame 2)
    tvis(n,1) = Screen('Flip',pWin);
    if uselpt; io64(io,port,255); end
    % startAudioTime(iTrial, 2) = PsychPortAudio('Start', pahandle, 1, time ,1);
    startTime(n) = PsychPortAudio('Start',paudio, 1,tvis(n,1),1);
    Screen('FillRect', pWin);
    Screen('DrawText',pWin,'+',x0,y0);
    [taud.start(n),~,~,taud.stop(n)] = PsychPortAudio('Stop',paudio,3,1);
    % frame 2
    tvis(n,2) = Screen('Flip',pWin);
    if uselpt; io64(io,port,0); end
    % frame 3 (& prepare next frame 1)
    tvis(n,3) = Screen('Flip',pWin);
    Screen('FillRect', pWin);
    Screen('DrawText',pWin,'+',x0,y0);
    Screen('FillRect', pWin, [0 0 0], [0 0 50 50]);
    
    [keypressed,~,~,~,~] = KbQueueCheck;        % ...read the keyboard queue
    if keypressed
        break
    end
end

%% Tidy up & end
KbQueueStop                                     % stop keyboard queue recording
KbQueueRelease                                  % close keyboard queue
PsychPortAudio('Close');                        % close audio
sca;                                            % close screen
if uselpt; clear io; end                        % close paralle port

% stats
min(diff(tvis(:))*1000)
max(diff(tvis(:))*1000)
taud.start(:)-tvis(:,1)
