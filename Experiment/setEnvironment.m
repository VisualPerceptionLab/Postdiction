function [mriTiming, waitTime, sampleRate] = setEnvironment(audio)
% [waitTime] = setEnvironment(audio);
%
% Sets some global variables. Boolean 'audio' determines whether sound
% driver is initialised or not.

global distFromScreen pixelsPerCm;
global environment buttonDeviceID scanPulseDeviceID;
global pahandle;
global TR;
global mriTiming;

environmentID = input('Which environment? (mri = 1, mri_offline = 2, testingroom = 3, macbook = 4, FILworkstation = 5): ');

%devices = PsychPortAudio('GetDevices')

switch environmentID
    case 1
        environment = 'mri'
        distFromScreen = 113; % prev 90 + 5
        pixelsPerCm = (1920/35.5 + 1200/22)/2; % prev 1920/44.5
        TR = 3.264; %0.080*48 for sequence with initial volume in opposite PE dir
        
        mriTiming = true
        waitTime = 1*TR
        
        audioDeviceID = [] % Which audio device?
        Screen('Preference', 'SkipSyncTests', 1);
        
        % Find index of device that receives scanner pulses
        DEVICENAME = '932'; %name of device you want to poll
        % DEVICENAME = 'USB NetVista Full Width Keyboard';
        %use this line if you want to mimic the trigger pulse (on a Mac) for debugging purposes
        [index, devName] = GetKeyboardIndices;
        for device = 1:length(index)
            if strcmp(devName(device),DEVICENAME)
                buttonDeviceID = index(device);
                scanPulseDeviceID = index(device);
            end
        end
        
    case 2
        environment = 'mri_offline'
        distFromScreen = 113; % prev 90 + 5
        pixelsPerCm = (1920/35.5 + 1200/22)/2; % prev 1920/44.5
        mriTiming = false
        waitTime = 4
        
        audioDeviceID = [] % Which audio device?
        Screen('Preference', 'SkipSyncTests', 1);
        
        % Find index of device that receives scanner pulses
        DEVICENAME = '932'; %name of device you want to poll
        %DEVICENAME = 'USB NetVista Full Width Keyboard';
        %use this line if you want to mimic the trigger pulse (on a Mac) for debugging purposes
        [index, devName] = GetKeyboardIndices;
        for device = 1:length(index)
            if strcmp(devName(device),DEVICENAME)
                buttonDeviceID = index(device)
                scanPulseDeviceID = index(device);
            end
        end
        
   case 3
        %PsychJavaTrouble;
        environment = 'beh_lab'
        distFromScreen = 44;
        % The pixels per cm monitor averaged over resp. width and height
        % for measurement errors.
        pixelsPerCm = (1920/53.8 + 1080/30.5) / 2;%(1920/52.5 + 1080/29)/2
        buttonDeviceID = -1;
        mriTiming = false
        waitTime = 4
        audioDeviceID = [] % Which audio device?
        Screen('Preference', 'SkipSyncTests', 1);
   case 4
        environment = 'macbook'
        distFromScreen = 50
        pixelsPerCm = 1440/29
        buttonDeviceID = -1;
        mriTiming = false
        waitTime = 4
        audioDeviceID = [] % Which audio device?
        Screen('Preference', 'SkipSyncTests', 1);
   case 5
        PsychJavaTrouble;
        environment = 'FILworkstation'
        distFromScreen = 61.5;%50
        pixelsPerCm = (1920/52 + 1200/32.5)/2;%1920/44 % rough estimate
        buttonDeviceID = -1;
        mriTiming = false
        waitTime = 4
        audioDeviceID = [] % Which audio device?
        Screen('Preference', 'SkipSyncTests', 1);
%     case 6
%         environment = 'Laptop'
%         distFromScreen = 60
%         pixelsPerCm = (1920/52.5 + 1080/29)/2
%         
%         buttonDeviceID = -1;
%         
%         mriTiming = false
%         waitTime = 4
%         
%         audioDeviceID = [] % Which audio device?
%         Screen('Preference', 'SkipSyncTests', 1);
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
    [wavedata, sampleRate] = MakeBeep(800, 0.007, sampleRate); 
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Start audio playback at time 'time', return onset timestamp.
    PsychPortAudio('Start', pahandle, 1);
    
    WaitSecs(1)
    [wavedata, sampleRate] = MakeBeep(2000, 0.007, sampleRate);
    % hack wavedata to make it a square wave
    wavedata(wavedata<0) = -1;
    wavedata(wavedata>0) = 1;
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Start audio playback at time 'time', return onset timestamp.
    PsychPortAudio('Start', pahandle, 1);
end

end