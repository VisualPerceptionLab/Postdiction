function [window,width,height] = openScreen(windowPtrOrScreenNumber)
% [window,wRect,keyboardNumber,midW,midH] = openScreen(windowPtrOrScreenNumber)
%
% Opens a new screen using windowPtrOrScreenNumber.
% If no input is provided, screen is opened on max(Screen('Screens')).
%
% Performs some common commands to do at experiment startup.
% - sets highest priority level
% - initializes some MEX files
% - hides cursor
% - unifies key names

global environment

%%%%% open window
% hardcode so that mri uses extended screen 2
if strcmp(environment,'mri') || strcmp(environment,'mri_offline')
    windowPtrOrScreenNumber = 2;
elseif ~exist('windowPtrOrScreenNumber','var') || isempty(windowPtrOrScreenNumber)
    windowPtrOrScreenNumber = max(Screen('Screens'));
end

% MEG wiki says: [pWin,wRect]     = Screen('OpenWindow',scn);    % open a display window
displayRes = Screen('Rect',windowPtrOrScreenNumber)
% give a warning if resolution is not properly set
if (strcmp(environment,'mri') || strcmp(environment,'mri_offline')) && (displayRes(3) ~= 1920 || displayRes(4) ~= 1200)
    disp('Resolution is not 1920 by 1200.');
    continueExp = input('Continue?: (1: yes, 2: abort): ');
    if continueExp == 2
        continueExp = aaa; % force error
    end
elseif strcmp(environment,'beh_lab') && (displayRes(3) ~= 1920 || displayRes(4) ~= 1080)
    disp('Resolution is not 1920 by 1080.');
    continueExp = input('Continue?: (1: yes, 2: abort): ');
    if continueExp == 2
        continueExp = aaa; % force error
    end
elseif strcmp(environment,'macbook') && (displayRes(3) ~= 1440 || displayRes(4) ~= 900)
    disp('Resolution is not 1440 by 900.');
    continueExp = input('Continue?: (1: yes, 2: abort): ');
    if continueExp == 2
        continueExp = aaa; % force error
    end
end

if strcmp(environment,'FILworkstation')
    [window,wRect] = Screen('OpenWindow', windowPtrOrScreenNumber, 127, [0 0 1920 1080]);
else
    [window,wRect] = Screen('OpenWindow', windowPtrOrScreenNumber, 127);
%     [window,wRect] = Screen('OpenWindow', windowPtrOrScreenNumber, 127, [0 0 1366 768]);
end


width=wRect(3);
height=wRect(4);

%midW = width/2;
%midH = height/2;

%%%%% do other useful PTB startup stuff
priorityLevel=MaxPriority(window);
Priority(priorityLevel);

HideCursor;

KbName('UnifyKeyNames');

%%%%% initialize some commonly used mex files
% these files take a bit of time to load the first time around
GetSecs;
WaitSecs(.001);

if IsOSX
    d=PsychHID('Devices');
    keyboardNumber = 0;

    for n = 1:length(d)
        if strcmp(d(n).usageName,'Keyboard');
            keyboardNumber=n;
            break
        end
    end
    KbCheck(keyboardNumber);
else
    keyboardNumber = [];
    KbCheck;
end