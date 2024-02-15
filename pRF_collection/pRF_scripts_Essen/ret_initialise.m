% little script to initialise moving bar stimuli
% PK 18-02-2013

clear all; close all;

% in case there are any bitsis loaded
delete(instrfind)

pRF_paths = fullfile(pwd,'MRstim','MRstim');
pRF_paths = genpath(pRF_paths);
addpath(pRF_paths);
subjID = input('Subject number: ');
run = input('Run: ');
LoadPsychHID
if Eyelink('Initialize')~=0; return; end % open a connection to the eyetracker PC
eyename = ['PRF', num2str(run)]
Eyelink('Openfile',eyename)               % create test.edf on the eyetracker PC
ret_val = Eyelink('StartRecording')      % start recording (to the file)

initialTime = time;
Eyelink('Message','Trigger %s',num2str(initialTime)) 

ret

Eyelink('StopRecording')                 % stop recording
Eyelink('Closefile')                     % close the file
Eyelink('ReceiveFile')                   % copy the file to the Stimulus PC
Eyelink('Shutdown')                      % close the connection to the eyetracker PC