function [mriTiming, waitTime, sampleRate] = setEnvironment(audio)
% [waitTime] = setEnvironment(audio);
%
% Sets some global variables. Boolean 'audio' determines whether sound
% driver is initialised or not.

global distFromScreen pixelsPerCm;
global environment buttonDeviceID scanPulseDeviceID;
global pahandle;
global mriTiming;

environmentID = input('Which environment? (meg = 1, FILworkstation = 2): ');

%devices = PsychPortAudio('GetDevices')

switch environmentID
    case 1
              environment = 'meg'
                    
        distFromScreen = 55;
        pixelsPerCm = (1024/37 + 768/28)/2;  
        buttonDeviceID = -1;
              
        mriTiming = false; %true, jitter ITI 
        waitTime = 2; %second time
        
        audioDeviceID = 3;  %'Speakers (AUDIOfile V1.000)';
        Screen('Preference', 'SkipSyncTests', 1);


        port = hex2dec('3ff8');     % !!! check the port address in device manager !!!
        io = io64;                                       % create parallel port object
        status = io64(io);                               % check status of parallel port
        assert(status==0, 'Parallel port not opened.');

%         run = input('Run: ');
%         if Eyelink('Initialize')~=0; return; end % open a connection to the eyetracker PC
%         eyename = ['PDMEG', num2str(run)]
%         Eyelink('Openfile',eyename)               % create test.edf on the eyetracker PC
%         ret_val = Eyelink('StartRecording')      % start recording (to the file)
%             
    case 2
        PsychJavaTrouble;
        environment = 'FILworkstation'
        distFromScreen = 61.5;%50
        pixelsPerCm = (1920/52 + 1200/32.5)/2;%1920/44 % rough estimate
        buttonDeviceID = -1;
        megTiming = false
        waitTime = 4
        audioDeviceID = [] % Which audio device?
        Screen('Preference', 'SkipSyncTests', 1);
end

if audio
    % Perform basic initialization of the sound driver:
    InitializePsychSound;
    nrchannels = 1; % One channel only -> Mono sound.
    sampleRate = 44100;
    % Open the default audio device audioDeviceID, with default mode [] (==Only playback),
    % and a required latencyclass of zero 0 == no low-latency mode, as well as
    % a frequency of freq and nrchannels sound channels.
    % This returns a handle to the audio device:
    %pahandle = PsychPortAudio('Open', audioDeviceID, [], 0, sampleRate, nrchannels);
	pahandle = PsychPortAudio('Open', audioDeviceID, [], 2, sampleRate, nrchannels);
    
    PsychPortAudio('RunMode', pahandle, 1);
    % Play a sound, to initialise the audio device.
    [wavedata, sampleRate] = MakeBeep(800, 0.020, sampleRate); 
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Start audio playback at time 'time', return onset timestamp.
    PsychPortAudio('Start', pahandle, 1);
    

end

end