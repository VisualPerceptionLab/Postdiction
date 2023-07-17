function [mriTiming, waitTime] = setEnvironment(audio)
% [waitTime] = setEnvironment(audio);
%
% Sets some global variables. Boolean 'audio' determines whether sound
% driver is initialised or not.

global distFromScreen pixelsPerCm;
global environment buttonDeviceID scanPulseDeviceID;
global pahandle;
global TR;

environmentID = input('Which environment? (mri = 1, mri_offline = 2, testingroom4 = 3, macbook = 4, FILworkstation = 5): ');

%devices = PsychPortAudio('GetDevices')

switch environmentID
    case 1
        environment = 'mri'
        distFromScreen = 91; % prev 90 + 5
        pixelsPerCm = 1920/31; % prev 1920/44.5
        
        TR = 0.073*48 %0.080*48 for sequence with initial volume in opposite PE dir
        
        mriTiming = true
        waitTime = 2*TR
        
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
        distFromScreen = 91; % prev 90 + 5
        pixelsPerCm = 1920/31; % prev 1920/44.5
        
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
        distFromScreen = 60
        pixelsPerCm = 1368/20;%(1920/52.5 + 1080/29)/2
        
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
        distFromScreen = 91;%50
        pixelsPerCm = 1920/31;%1920/44 % rough estimate
        
        buttonDeviceID = -1;
        
        mriTiming = false
        waitTime = 4
        
        audioDeviceID = [] % Which audio device?
        Screen('Preference', 'SkipSyncTests', 1);
        
        Screen('Preference', 'TextRenderer',0) % otherwise, drawing text will cause PTB to crash.
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
    %[wavedata, sampleRate] = MakeBeep(750, 0.5, sampleRate);
    %PsychPortAudio('FillBuffer', pahandle, wavedata);
    % Start audio playback at time 'time', return onset timestamp.
    %PsychPortAudio('Start', pahandle, 1);
end

end