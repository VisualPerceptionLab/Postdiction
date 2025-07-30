%
clear all
    
try

    rgb = input('RGB value?: ');
    
    %Open window and do useful stuff
    [window,width,height] = openScreen();

    Screen('TextFont',window, 'Arial');
    Screen('TextSize',window, 20);
    Screen('FillRect', window, rgb);
    Screen('Flip', window);
    
    KbWait;

    %End. Close all windows
    Screen('CloseAll');

catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end