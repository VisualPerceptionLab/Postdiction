%% PTB audio jitter test
% Open screen, on the 2nd monitor (if available)
% flip screen, play sound
% Close screen

%% Parameters
nstim = 20;
f = 440;                                        % sound frequency
duration = 0.010;                               % sound duration
port = hex2dec('3ff8');                         % parallel port address

%% Parallel port setup
% io = io64;
% status = io64(io);
% assert( status == 0, 'Parallel port not opened!' )
% io64(io,port,0);

%% PsychToolbox basic setup
PsychDefaultSetup(2);                           % apply common Psychtoolbox parameters
Screen('Preference', 'SkipSyncTests', 1);       % suppress warnings about VBL timing
InitializePsychSound;                           % initialize Psychtoolbox audio

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
tvis = zeros(3,nstim);
taud.start = zeros(nstim,1);
taud.stop  = zeros(nstim,1);

%% main loop
for n=1:nstim
    % frame 1 (& prepare frame 2)
    tvis(1,n) = Screen('Flip',pWin);
    io64(io,port,255)
    PsychPortAudio('Start',paudio, 1,0,1);
%     Screen('FillRect', pWin);
%     Screen('DrawText',pWin,'+',x0,y0);
    [taud.start(n),~,~,taud.stop(n)] = PsychPortAudio('Stop',paudio,3,1);
    % frame 2
    tvis(2,n) = Screen('Flip',pWin);
    io64(io,port,0)
    % frame 3 (& prepare next frame 1)
    tvis(3,n) = Screen('Flip',pWin);
    Screen('FillRect', pWin);
    Screen('DrawText',pWin,'+',x0,y0);
    Screen('FillRect', pWin, [0 0 0], [0 0 50 50]);
end

%% Tidy up & end
PsychPortAudio('Close');                        % close audio
sca;                                            % close screen
clear io

% stats
min(diff(tvis(:))*1000)
max(diff(tvis(:))*1000)
taud.start(:)-tvis(1,:)'
