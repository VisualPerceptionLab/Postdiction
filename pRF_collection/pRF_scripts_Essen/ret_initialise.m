% little script to initialise moving bar stimuli
% PK 18-02-2013

clear all; close all;

% in case there are any bitsis loaded
delete(instrfind)

pRF_paths = fullfile(pwd,'MRstim','MRstim');
pRF_paths = genpath(pRF_paths);
addpath(pRF_paths);

LoadPsychHID
if Eyelink('Initialize')~=0; return; end % open a connection to the eyetracker PC
eyename = ['prfeye', num2str(subjID)]
Eyelink('Openfile',eyename)               % create test.edf on the eyetracker PC
ret_val = Eyelink('StartRecording')      % start recording (to the file)

ret

Eyelink('StopRecording')                 % stop recording
Eyelink('Closefile')                     % close the file
Eyelink('ReceiveFile')                   % copy the file to the Stimulus PC
Eyelink('Shutdown')                      % close the connection to the eyetracker PC