function [answer, respTime] = getResponse(endTime)

global buttonDeviceID environment;

%Define the keys
if strcmp(environment,'mri') || strcmp(environment,'mri_offline')
    flash_key_1 = KbName('1!');
    flash_key_2 = KbName('2@');
    volume_up   = KbName('3#');
    volume_down = KbName('4$');
    conf_key_1 = KbName('6^');
    conf_key_2 = KbName('7&');
    conf_key_3 = KbName('8*');
    conf_key_4 = KbName('9(');
    escape = KbName('escape');
else
    flash_key_1 = KbName('u');
    flash_key_2 = KbName('i');
    conf_key_1 = KbName('r');
    conf_key_2 = KbName('e');
    conf_key_3 = KbName('w');
    conf_key_4 = KbName('q');
    volume_up = KbName('UpArrow');
    volume_down = KbName('DownArrow');
    escape = KbName('escape');
end

answer = -10; %in case no answer is given within the time limit
respTime = GetSecs;
while GetSecs < endTime
    [keyIsDown,respTime,keyCode]=KbCheck(buttonDeviceID);
    if keyIsDown
        if keyCode(flash_key_1)
            answer = 2;
            break;
        elseif keyCode(flash_key_2)
            answer = 3;
            break;
        elseif keyCode(escape)
            answer = bbb; % forcefully break out
        end
    end
end

end