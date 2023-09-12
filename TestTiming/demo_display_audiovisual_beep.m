%% Very basic screen demo
% Opens a screen on the 2nd monitor (if available)
% Draws text and displays for 3 seconds
% Loads and draws an image for 3 seconds
% Closes screen

%% PsychToolbox basic setup
PsychDefaultSetup(2);                           % apply common Psychtoolbox parameters
Screen('Preference', 'SkipSyncTests', 1);       % suppress warnings about VBL timing

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
audioDeviceID = []
InitializePsychSound;
pahandle = PsychPortAudio('Open', audioDeviceID, [], 2, sampleRate, nrchannels);

PsychPortAudio('RunMode', pahandle, 1);
toneDur = 1; % 7ms
toneFreqs = [1500]; % 800hz postdiction % A4 C#5 E5
sampleRate = 44100;
PsychPortAudio('RunMode', pahandle, 1);
% Initialise
[wavedata, sampleRate] = MakeBeep(toneFreqs, toneDur, sampleRate);
PsychPortAudio('FillBuffer', pahandle, wavedata); % load stimulus into sound buffer

%% Screen setup & open
scn = max(Screen('Screens'));                   % find second screen if connected
[pWin,wRect] = Screen('OpenWindow',scn);        % open a display window
[wWidth,wHeight] = Screen('WindowSize',pWin);   % find window width & height
[x0,y0] = RectCenter(wRect);                    % find the centre of the window
stimColour = [0 0 0];
%% Use screen

% Text style
WaitSecs(3)
Screen('FillRect', pWin, stimColour);                       % fill window with default backgroound colour
Screen('Flip', pWin); 
%% Play stimulus
PsychPortAudio('Start',pahandle, 1,0,1);                  % play stimulus and save start time
% [tstart,~,~,tstop] = PsychPortAudio('Stop',paudio,3,1); % ... and wait until the sound stops playing
% tstop-tstart;     
WaitSecs(3);  
% Screen('TextFont', pWin, 'Arial');              % Set typeface
% Screen('TextSize', pWin, 30);                   % Set fontsize
% Screen('TextStyle', pWin, 0);                   % Set style as sum of: Normal=0, bold=1, italic=2, underline=4, outline=8, condense=32, extend=64
% % Text ifddd
% Screen('DrawText',pWin,'Basic DrawText',x0,y0); % Draw the text @ x,y
% Screen('Flip', pWin);                           % Display the window
% WaitSecs(3);                                    % for 3 seconds
% % Text ii
% txt = 'Centre-aligned multi-line text,\nwith forced line breaks\nFor example, an \ninstruction screen';
% vSpacing = 1.5;                                 % line spacing
% DrawFormattedText(pWin,txt,'center','center',[],[],[],[],vSpacing);
% Screen('Flip', pWin);                           % Display the window
% WaitSecs(3);                                    % for 3 seconds
% 
% % Image
% im = imread('Mosquito.bmp');                    % read an image file
% Screen('PutImage', pWin, im);                   % and load into window
% Screen('Flip', pWin);                           % Display the window
% WaitSecs(3)                                     % for 3 seconds

%% Tidy up & end
PsychPortAudio('Close');                                % close audio device
Screen('Close',pWin)                            % close display window. Atlernatively: Screen('CloseAll')
