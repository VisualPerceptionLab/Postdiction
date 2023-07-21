addpath '/Users/pkok/Dropbox/NTB_postdoc/PTB_scripts/edf-converter-master';

%edf0 = Edf2Mat('petkok1.edf');
%edf0 = Edf2Mat('S7_535.edf');
%edf0 = Edf2Mat('S55_022.edf');
%edf0 = Edf2Mat('S55_550.edf');

edfFile = fullfile(pwd,'Results','S90','16209.edf');
edfFile = fullfile(pwd,'Results','S90','16323.edf');
edfFile = fullfile(pwd,'Results','S90','162618.edf');
edf0 = Edf2Mat(edfFile);

disp(edf0);
plot(edf0);
% Of course you can also plot in your own style:
figure();
plot(edf0.Samples.posX(end - 2000:end), edf0.Samples.posY(end - 2000:end), 'o');

edf0.Events.Messages.info

% delay between SCANTRIGGER and first FIXCUE?
scantriggerInd = find(strcmp(edf0.Events.Messages.info,'SCANTRIGGER'),1);
scantriggerTime = edf0.Events.Messages.time(scantriggerInd);
firstFixCueInd = find(strcmp(edf0.Events.Messages.info,'FIXCUE'),1);
firstFixCueTime = edf0.Events.Messages.time(firstFixCueInd);
disp(sprintf('Interval between first scanner trigger and first fixation cue = %d ms',firstFixCueTime - scantriggerTime))

runTypeInd = find(strncmp(edf0.Events.Messages.info,'RUNTYPE',7),1);
if ~strcmp(edf0.Events.Messages.info(runTypeInd),'RUNTYPE3')
    % delays between FIXCUEs and SHAPEs
    fixCueInds = find(strcmp(edf0.Events.Messages.info,'FIXCUE'));
    fixCueTimes = edf0.Events.Messages.time(fixCueInds);
    shapeInds = find(strncmp(edf0.Events.Messages.info,'SHAPE',5));
    shapeTimes = edf0.Events.Messages.time(shapeInds);
    disp('Intervals between FIXCUEs and SHAPEs:')
    shapeTimes - fixCueTimes
    
    % if there were auditory cues, inspect their timing
    if ~strcmp(edf0.Events.Messages.info(runTypeInd),'RUNTYPE1')
        audCueInds = find(strncmp(edf0.Events.Messages.info,'CUE',3));
        audCueTimes = edf0.Events.Messages.time(audCueInds);
        disp('Intervals between FIXCUEs and CUEs:')
        audCueTimes - fixCueTimes
    end
end
