if Eyelink('Initialize')~=0; return; end % open a connection to the eyetracker PC
Eyelink('Openfile','test')               % create test.edf on the eyetracker PC
ret_val = Eyelink('StartRecording')      % start recording (to the file)

numtrials = 10
for n = 1:numtrials                      % Trial loop
    Eyelink('Message','Trigger %d',n)    % optionally send triggers (to the file)
    WaitSecs(1)
end

Eyelink('StopRecording')                 % stop recording
Eyelink('Closefile')                     % close the file
Eyelink('ReceiveFile')                   % copy the file to the Stimulus PC
Eyelink('Shutdown')                      % close the connection to the eyetracker PC