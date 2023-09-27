function [time] = waitForTrigger(waitTime,text,taskColour)
% [time]  = waitForTrigger(waitTime,text)
%
% Waits for scanner trigger or button press (depending on the
% environment). Returns 'time' at which experiment should start.
%
% Time between scanner trigger and 'time' is determined by input argument
% 'waitTime'.

global window width height fixCrossTexture fixRect;
global environment buttonDeviceID scanPulseDeviceID;

scanPulseDeviceID

Lmin = 0;
textColour = taskColour; %Lmin;

% [index, devName] = GetKeyboardIndices;
% if strcmp(devName(index==buttonDeviceID),'932')
%     escape = KbName('4');
% else
escape = KbName('escape');
% end

if strcmp(environment,'mri')
    
    scannerTrigger = KbName('5%');
    
    %Wait for the first scanner pulse
    % show fixation cross or not?
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
%     DrawFormattedText(window, text, 'center', height/2-200, textColour);
%     text = 'Waiting for experiment';
%     DrawFormattedText(window, text, 'center', height/2+100, textColour);
    Screen('Flip',window);
    
    FlushEvents('keyDown');
    
    %Wait for scanner back tick
    firstScan = 0;
    while firstScan == 0
        WaitSecs(0.001);
        [keyIsDown,secs,keyCode]=KbCheck(scanPulseDeviceID);
        if keyIsDown
            if keyCode(scannerTrigger)
                firstScan = 1;
            elseif keyCode(escape)
                answer = bbb; % forcefully break out
            end
        end
    end
    
    % mark scanner trigger in data file
    %Eyelink('message', 'SCANTRIGGER');
    
    time = secs;
    Screen('Flip',window);
    
    % Wait a few scans before the experiment begins.
    time = time + waitTime;
    
else
    
    % Wait for a button press.
    DrawFormattedText(window, text, 'center', height/2-200, textColour);
    text = 'Press any key to start';
    DrawFormattedText(window, text, 'center', height/2+100, textColour);
    Screen('Flip',window);
    WaitSecs(.5);
    
    FlushEvents('keyDown');
    
    %Wait for button press
    buttonpress = 0;
    while buttonpress == 0
        [keyIsDown,~,~]=KbCheck(buttonDeviceID);
        if keyIsDown
            buttonpress = 1;
            Screen('Flip',window);
            time = GetSecs;
        end
        WaitSecs(0.001);
    end
    Screen('Flip',window);
    time = GetSecs;
    
    % Wait a few seconds before the experiment begins.
    time = time + waitTime;
end