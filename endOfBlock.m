function [time] = endOfBlock(iBlock,nBlocks,extraText,time,wrapat,vspacing)
% [time]  = endOfBlock(time,wrapat,vspacing)
%
% Presents 'End of block' screen. Returns the time at which the next
% display is to be presented.

global window width height;
global environment buttonDeviceID;
global fixCrossTexture fixRect fixCrossTexture_ITI;
global TR;

% Show 'end of block' screen
text = sprintf('End of block %d/%d',iBlock,nBlocks);
DrawFormattedText(window, text, 'center', height/2-75, 0, wrapat,0,0,vspacing);
DrawFormattedText(window, extraText, 'center', height/2, 0, wrapat,0,0,vspacing);

if strcmp(environment, 'mri')
    if iBlock < nBlocks
        totalBreakTime = round(30/TR)*TR; % make break duration a multiple of the TR.
        text = '30 second break';
        DrawFormattedText(window, text, 'center', height/2+75, 255, wrapat,0,0,vspacing);
        Screen('Flip',window, time);
        time = time + 2;
        % 26 second break: empty screen
        Screen('Flip', window, time);
        time = time + (totalBreakTime - 4);
        % put the fixation dot back on the screen 2 seconds before the
        % break ends.
        Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
    end
    Screen('Flip', window, time);
    time = time + 2;
else
    text = 'Press any key to continue.';
    DrawFormattedText(window, text, 'center', height/2+200, 0, wrapat,0,0,vspacing);
    Screen('Flip',window, time);
    WaitSecs(.5);
    
    FlushEvents('keyDown');
    
    %Wait for button press
    buttonpress = 0;
    while buttonpress == 0
        keyIsDown = KbCheck(buttonDeviceID);
        if keyIsDown
            buttonpress = 1;
            Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
            Screen('Flip',window);
            time = GetSecs;
        end
    end
    time = time + 2;
end

end