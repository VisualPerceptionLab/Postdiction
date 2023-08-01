function [] = showInstructions_MainExpt(toneOrientation,background,Lmin,volume,wrapat,vspacing)
%Shows instructions for the grating task.

global window width height;
global buttonDeviceID;
global fixCrossTexture fixRect fixCrossTexture_ITI;

rotAngles = [45 135];
% change rotAngles so that the orientations are as per the unit circle.
rotAngles = -1 * (rotAngles+90);

%Compute the size of the stimulus
gratingSize_degrees = 10
gratingSize = degrees2pixels(gratingSize_degrees);
innerDegree = 1.5
destSquare = [width/2-gratingSize/2, height/2-gratingSize/2, width/2+gratingSize/2, height/2+gratingSize/2];
spatFreq = 0.5
    
%Show instructions on screen

%% What the gratings look like
text = 'Thank you for participating in our study!\n\nIn this study you will see so-called ''gratings''.\n\nPress any key to see what the gratings look like.';
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);

%Show gratings
gratingContrast = 0.8;
for i=1:4
    %Show grating
    grating1Phase = rand*2*pi; % random phase, between 0 and 2*pi
    stimulusMatrix = makeStimulus(gratingContrast, 0, 1, gratingSize_degrees,grating1Phase,spatFreq,innerDegree);
    readyStimulus = Screen('MakeTexture', window, stimulusMatrix);
    
    %Draw the grating
    if rem(i,2) == 1
        grating1RotAngle = rotAngles(1); %right-tilted orientation
        text = 'Right-tilted grating';
    else
        grating1RotAngle = rotAngles(2); %left-tilted orientation
        text = 'Left-tilted grating';
    end
    Screen('DrawTexture', window, readyStimulus, [], destSquare, grating1RotAngle);
    % Draw the fixation bull's-eye
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
    DrawFormattedText(window, text, 'center', 150, 0, wrapat);
    text = 'Press a button to continue.';
    DrawFormattedText(window, text, 'center', height-150, 0, wrapat);
    Screen('Flip', window);
    WaitSecs(.5);
    FlushEvents('keyDown');
    KbWait(buttonDeviceID);
end

%What the trials are like
text = 'On each trial, your task will be to report the orientation of the grating. It can be either:\n\n<: tilted to the left\n\nor:\n\n>: tilted to the right.\n\nPress any key to see examples.';
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);

%Show gratings
gratingContrast = 0.8;
for i=1:2
    %Show grating
    grating1Phase = rand*2*pi; % random phase, between 0 and 2*pi
    stimulusMatrix = makeStimulus(gratingContrast, 0, 1, gratingSize_degrees,grating1Phase,spatFreq,innerDegree);
    readyStimulus = Screen('MakeTexture', window, stimulusMatrix);
    
    %Draw the grating
    if rem(i,2) == 1
        grating1RotAngle = rotAngles(2); %left-tilted orientation
        text = '<: Left-tilted grating';
    else
        grating1RotAngle = rotAngles(1); %right-tilted orientation
        text = '>: Right-tilted grating';
    end
    Screen('DrawTexture', window, readyStimulus, [], destSquare, grating1RotAngle);
    % Draw the fixation bull's-eye
    Screen('DrawTexture', window, fixCrossTexture, fixRect, CenterRect(fixRect, [0 0 width height]));
    DrawFormattedText(window, text, 'center', 150, 0, wrapat);
    text = 'Press a button to continue.';
    DrawFormattedText(window, text, 'center', height-150, 0, wrapat);
    Screen('Flip', window);
    WaitSecs(.5);
    FlushEvents('keyDown');
    KbWait(buttonDeviceID);
end

%What the task is like
text = 'Each trial will start with a fixation point, which will be presented in the middle of the screen. It is important that you keep your eyes fixed on this point. Then, a grating will be briefly presented. Your task is to detect whether the grating is left-tilted (<) or right-tilted (>). After the grating has disappeared, the symbols ''<'' (for left-tilted) and ''>'' (for right-tilted) will appear on the screen.';
text = [text ' You then detect whether the response you want to give (< or >) is on the left or the right side of the screen, and press the left or right button to give your answer.'];
text = [text ' For example, if a left-tilted grating (<) was presented, and the < appears on the right side of the screen, you press the right button. If instead the < appears on the left side, you press the left button.'];
text = [text '\n\nFor this task, the left button is the ''u'', and the right button is the ''i'' on the keyboard. Please place the middle and index fingers of your left hand on these buttons.\n\nIt is important that you keep your eyes fixed on the dot in the center of the screen, and do not move your eyes to the grating.'];
text = [text '\n\nIs this clear? If you have any questions, please ask the experimenter now. If all is clear, press any key to practice this task.'];
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
% DrawFormattedText(window, text, [], 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);

%What the task is like
text = 'Okay great, a block of 16 practice trials will start now!';
DrawFormattedText(window, text, width/2 - 400, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(3);
Screen('Flip',window);

practiceStage1 = true;
while practiceStage1
    % run practice block without auditory cues, without noise, without
    % confidence response, and without time limit on response.
    gratingContrast = 0.8;
    noiseContrast = 0;
    time = GetSecs + 5;
    nTrialsPerBlock = 16;
    propOmission.prob = 0;
    propOmission.alwaysValid = true;
    trialSequence = getTrialStructure(nTrialsPerBlock, propOmission);
    feedback = true;
    practice = 1;
    data = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, false, feedback, practice);
    
    %What the trials are like
    text = sprintf('You responded correctly on %d out of %d trials.\n\n',data.nCorrect,nTrialsPerBlock);
    if data.nCorrect/nTrialsPerBlock < 0.75
        text = [text 'Is the task clear? If not, please ask the experimenter to explain.\n\nPress the left button to practice again.'];
    else
        text = [text 'Well done. Press the left button if you want to practice again, or press the right button to continue.'];
    end
    DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
    Screen('Flip',window);
    WaitSecs(1);
    FlushEvents('keyDown');
    
    [repeatDecision, ~] = getResponse(Inf);
    if repeatDecision == 1
        practiceStage1 = true;
    elseif repeatDecision == 2
        practiceStage1 = false;
    end
    Screen('Flip',window);
end

% Explain that gratings will be presented more briefly in the real
% experiment and have people practice this.
text = 'Okay great. In the actual experiment, the gratings will be presented very briefly, making them harder to detect. Press a key to practice this.';
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);
Screen('Flip',window);

practiceStage2 = true;
while practiceStage2
    gratingContrast = 0.8;
    noiseContrast = 0;
    time = GetSecs + 5;
    nTrialsPerBlock = 16;
    propOmission.prob = 0;
    propOmission.alwaysValid = true;
    trialSequence = getTrialStructure(nTrialsPerBlock, propOmission);
    feedback = true;
    practice = 2;
    data = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, false, feedback, practice);
    
    %What the trials are like
    text = sprintf('You responded correctly on %d out of %d trials.\n\n',data.nCorrect,nTrialsPerBlock);
    if data.nCorrect/nTrialsPerBlock < 0.75
        text = [text 'Is the task clear? If not, please ask the experimenter to explain.\n\nPress the left button to practice again.'];
    else
        text = [text 'Well done. Press the left button if you want to practice again, or press the right button to continue.'];
    end
    DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
    Screen('Flip',window);
    WaitSecs(1);
    FlushEvents('keyDown');
    
    [repeatDecision, ~] = getResponse(Inf);
    if repeatDecision == 1
        practiceStage2 = true;
    elseif repeatDecision == 2
        practiceStage2 = false;
    end
    Screen('Flip',window);
end

% Explain that response time is limited, and have people practice this.
text = 'Excellent. Up to now, there has not been any time pressure on your responses. However, in the actual experiment, you will only have one second to give your response. Press a key to practice this.';
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);
Screen('Flip',window);

practiceStage3 = true;
while practiceStage3
    gratingContrast = 0.8;
    noiseContrast = 0;
    time = GetSecs + 5;
    nTrialsPerBlock = 16;
    propOmission.prob = 0;
    propOmission.alwaysValid = true;
    trialSequence = getTrialStructure(nTrialsPerBlock, propOmission);
    feedback = true;
    practice = 3;
    data = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, false, feedback, practice);
    
    %What the trials are like
    text = sprintf('You responded correctly on %d out of %d trials.\n\n',data.nCorrect,nTrialsPerBlock);
    if data.nCorrect/nTrialsPerBlock < 0.75
        text = [text 'Is the task clear? If not, please ask the experimenter to explain.\n\nPress the left button to practice again.'];
    else
        text = [text 'Well done. Press the left button if you want to practice again, or press the right button to continue.'];
    end
    DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
    Screen('Flip',window);
    WaitSecs(1);
    FlushEvents('keyDown');
    
    [repeatDecision, ~] = getResponse(Inf);
    if repeatDecision == 1
        practiceStage3 = true;
    elseif repeatDecision == 2
        practiceStage3 = false;
    end
    Screen('Flip',window);
end

% Explain that gratings will be embedded in noise, and therefore harder to
% see.
text = 'During the experiment, the gratings will be embedded in visual noise, making them more difficult to detect.\n\n';
text = [text 'To help you, at the start of each trial, a sound will indicate that the grating is about to appear.'];
text = [text ' The trials will go as follows: A circle will appear around the fixation point, a sound will be played to signal the grating is about to appear, and the grating will be presented.\n\n'];
text = [text 'Note that your task is still the same as before: simply indicate whether the grating is left-tilted or right-tilted.\n\n'];
text = [text 'Press a key for some practice trials.'];
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);
Screen('Flip',window);

practiceStage4 = true;
while practiceStage4
    gratingContrast = 0.4;
    noiseContrast = 0.2;
    time = GetSecs + 5;
    nTrialsPerBlock = 16;
    propOmission.prob = 0;
    propOmission.alwaysValid = true;
    trialSequence = getTrialStructure(nTrialsPerBlock, propOmission);
    feedback = true;
    practice = 4;
    data = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, false, feedback, practice);
    
    %What the trials are like
    text = sprintf('You responded correctly on %d out of %d trials.\n\n',data.nCorrect,nTrialsPerBlock);
    if data.nCorrect/nTrialsPerBlock < 0.75
        text = [text 'Is the task clear? If not, please ask the experimenter to explain.\n\nPress the left button to practice again.'];
    else
        text = [text 'Well done. Press the left button if you want to practice again, or press the right button to continue.'];
    end
    DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
    Screen('Flip',window);
    WaitSecs(1);
    FlushEvents('keyDown');
    
    [repeatDecision, ~] = getResponse(Inf);
    if repeatDecision == 1
        practiceStage4 = true;
    elseif repeatDecision == 2
        practiceStage4 = false;
    end
    Screen('Flip',window);
end

% Explain that gratings will be embedded in noise, and therefore harder to
% see.
text = 'Well done. We will increase the noise even further now, making the gratings even more difficult to detect.\n\n';
text = [text 'Press a key for some practice trials.'];
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);
Screen('Flip',window);

practiceStage4 = true;
while practiceStage4
    gratingContrast = 0.2;
    noiseContrast = 0.2;
    time = GetSecs + 5;
    nTrialsPerBlock = 16;
    propOmission.prob = 0;
    propOmission.alwaysValid = true;
    trialSequence = getTrialStructure(nTrialsPerBlock, propOmission);
    feedback = true;
    practice = 4;
    data = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, false, feedback, practice);
    
    %What the trials are like
    text = sprintf('You responded correctly on %d out of %d trials.\n\n',data.nCorrect,nTrialsPerBlock);
    if data.nCorrect/nTrialsPerBlock < 0.75
        text = [text 'Is the task clear? If not, please ask the experimenter to explain.\n\nPress the left button to practice again.'];
    else
        text = [text 'Well done. Press the left button if you want to practice again, or press the right button to continue.'];
    end
    DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
    Screen('Flip',window);
    WaitSecs(1);
    FlushEvents('keyDown');
    
    [repeatDecision, ~] = getResponse(Inf);
    if repeatDecision == 1
        practiceStage4 = true;
    elseif repeatDecision == 2
        practiceStage4 = false;
    end
    Screen('Flip',window);
end

% Explain that they won't get trial-by-trial feedback
text = 'Great job. Over the course of the experiment, the gratings will become more and more difficult to detect.';
text = [text ' Furthermore, you won''t get feedback after you give your response anymore. The only feedback you will get, is that if you don''t respond in time, the circle around the fixation point will flicker to alert you to this.'];
text = [text '\n\nPlease remember that it''s VERY important that you keep your eyes focused on the fixation dot in the centre of the screen, and don''t move your eyes to the gratings. In the scanner, this will be monitored using an eye-tracker.\n\n'];
text = [text 'Press a key to practice the task without feedback.'];
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);
Screen('Flip',window);

practiceStage4 = true;
while practiceStage4
    gratingContrast = 0.2;
    noiseContrast = 0.2;
    time = GetSecs + 5;
    nTrialsPerBlock = 16;
    propOmission.prob = 0;
    propOmission.alwaysValid = true;    
    trialSequence = getTrialStructure(nTrialsPerBlock, propOmission);
    feedback = false;
    practice = 4;
    data = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, false, feedback, practice);
    
    %What the trials are like
    text = sprintf('You responded correctly on %d out of %d trials.\n\n',data.nCorrect,nTrialsPerBlock);
    if data.nCorrect/nTrialsPerBlock < 0.75
        text = [text 'Is the task clear? If not, please ask the experimenter to explain.\n\nPress the left button to practice again.'];
    else
        text = [text 'Well done. Press the left button if you want to practice again, or press the right button to continue.'];
    end
    DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
    Screen('Flip',window);
    WaitSecs(1);
    FlushEvents('keyDown');
    
    [repeatDecision, ~] = getResponse(Inf);
    if repeatDecision == 1
        practiceStage4 = true;
    elseif repeatDecision == 2
        practiceStage4 = false;
    end
    Screen('Flip',window);
end

% Introduce the confidence response
text = 'We will now introduce one final aspect of the experiment. As you''ve seen, the gratings are sometimes very difficult to detect, and this will become even harder as the experiment progresses.';
text = [text ' Therefore, after you have given your response on the tilt of the grating, we would like you to indicate how sure you are that you saw the grating, or whether you saw only noise.'];
text = [text ' You will have four response options:\n\n'];
text = [text 'button 1 (''r''): I am sure I saw a grating\n'];
text = [text 'button 2 (''e''): I probably saw a grating\n'];
text = [text 'button 3 (''w''): I may have seen a grating\n'];
text = [text 'button 4 (''q''): I did not see a grating\n\n'];
text = [text 'Please give your confidence response after you have given your response on the tilt of the grating, when ''CONF?'' appears on the screen.\n\n'];
text = [text 'Place the fingers of your left hand on the four keys indicated above. Your index fingers should be on the ''q'', your middle finger on the ''w'', your ring finger on the ''e'' and your little finger on the ''r''.'];
text = [text '\n\nIs this clear? If not, please alert the experimenter. If everything is clear, press a key to practice this.'];
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(1);
FlushEvents('keyDown');
KbWait(buttonDeviceID);
Screen('Flip',window);

practiceStage5 = true;
while practiceStage5
    gratingContrast = 0.2;
    noiseContrast = 0.2;
    time = GetSecs + 5;
    nTrialsPerBlock = 16;
    propOmission.prob = 0;
    propOmission.alwaysValid = true;
    trialSequence = getTrialStructure(nTrialsPerBlock, propOmission);
    feedback = false;
    practice = 5;
    data = practiceBlock(gratingContrast, noiseContrast, nTrialsPerBlock, time, toneOrientation, trialSequence, background, Lmin, volume, false, feedback, practice);
    
    %What the trials are like
    text = sprintf('You responded correctly on %d out of %d trials.\n\n',data.nCorrect,nTrialsPerBlock);
    if data.nCorrect/nTrialsPerBlock < 0.75
        text = [text 'Is the task clear? If not, please ask the experimenter to explain.\n\nPress the left button to practice again.'];
    else
        text = [text 'Well done. Press the left button if you want to practice again, or press the right button to continue.'];
    end
    DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
    Screen('Flip',window);
    WaitSecs(1);
    FlushEvents('keyDown');
    
    [repeatDecision, ~] = getResponse(Inf);
    if repeatDecision == 1
        practiceStage5 = true;
    elseif repeatDecision == 2
        practiceStage5 = false;
    end
    Screen('Flip',window);
end

%What the trials are like
text = 'Excellent, you have now been introduced to all aspects of the experiment. If you have any questions, please alert the experimenter.\n\n';
text = [text 'Please remember that it''s VERY important that you keep your eyes focused on the fixation dot in the centre of the screen, and don''t move your eyes to the gratings.\n\n'];
text = [text 'You are now ready to start two short practice blocks. Press any button to continue.'];
DrawFormattedText(window, text, width/2 - 800, 'center', 0, wrapat,0,0,vspacing);
Screen('Flip',window);
WaitSecs(0.5);
FlushEvents('keyDown');
KbWait(buttonDeviceID)


end
