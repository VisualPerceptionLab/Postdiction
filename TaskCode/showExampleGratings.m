function [time] = showExampleGratings(time, background, Lmin, waitForButtonPress)

global window width height;
global fixCrossTexture fixRect fixCrossTexture_ITI;
global buttonDeviceID;

% some variables
contrast = 0.8;
phase = 0;

nOrientations = 8;
rotAngles = 0:180/nOrientations:180-180/nOrientations;
% change rotAngles so that the orientations are as per the unit circle.
rotAngles = -1 * (rotAngles-90);

% prepare grating
example_GratingSizeDegrees = 4;
example_GratingSize = degrees2pixels(example_GratingSizeDegrees);
spatFreq = 1 * (5/example_GratingSizeDegrees);
innerDegree = example_GratingSizeDegrees/15;
stimulusMatrix = makeStimulus(contrast,0,1,example_GratingSizeDegrees,phase,spatFreq,innerDegree);
readyStimulus = Screen('MakeTexture', window, stimulusMatrix);

% show relationship between the two gratings and the response symbols.
orients = [7 3];
vertOffset = degrees2pixels(example_GratingSizeDegrees/2 + 0.5);
horOffset = degrees2pixels(example_GratingSizeDegrees/2 + 0.5);

order = [1 2];

%rotAngles
%rotAngles(orients(order(1)))
example_DestinationSquare = [width/2-example_GratingSize/2+horOffset, height/2-example_GratingSize/2-vertOffset, width/2+example_GratingSize/2+horOffset, height/2+example_GratingSize/2-vertOffset];
Screen('DrawTexture', window, readyStimulus, [], example_DestinationSquare, rotAngles(orients(order(1))));

%rotAngles(orients(order(2)))
example_DestinationSquare = [width/2-example_GratingSize/2+horOffset, height/2-example_GratingSize/2+vertOffset, width/2+example_GratingSize/2+horOffset, height/2+example_GratingSize/2+vertOffset];
Screen('DrawTexture', window, readyStimulus, [], example_DestinationSquare, rotAngles(orients(order(2))));

% DrawFormattedText(window, '<         >', 'center', 'center', [0 0 0]);
DrawFormattedText(window, '<', width/2-horOffset, height/2-vertOffset+10, Lmin);
DrawFormattedText(window, '>', width/2-horOffset, height/2+vertOffset+10, Lmin);

if waitForButtonPress
    text = 'Press a button to continue';
    DrawFormattedText(window, text, 'center', height/2+200, Lmin);
end
Screen('Flip',window, time);

if waitForButtonPress
    FlushEvents('keyDown');
    KbWait(buttonDeviceID);
    time = GetSecs;
else
    time = time+2;
end

%Present the fixation point
Screen('DrawTexture', window, fixCrossTexture_ITI, fixRect, CenterRect(fixRect, [0 0 width height]));
Screen('Flip',window, time);
time = GetSecs+2;

end