function [] = checkStimTiming(data)

fixCueInt = 0.1; % interval between fixation cue and auditory cue.
toneDur = 0.08;
toneInt = 0.005;
cueStimSOA = 0.75; % SOA between auditory cue and stimulus
stimDur = 0.25; % in seconds
stimInterval = 0.5; % in seconds
respInt = 0.75; % length of response interval (after disappearance of the second shape), in seconds.

MoE = 0.005; % allowable margin of error in timing, in seconds.

desiredPresTimes = [0 ...
    fixCueInt+cueStimSOA ...
    fixCueInt+cueStimSOA+stimDur ...
    fixCueInt+cueStimSOA+stimDur+stimInterval ...
    fixCueInt+cueStimSOA+stimDur+stimInterval+stimDur ...
    fixCueInt+cueStimSOA+stimDur+stimInterval+stimDur+respInt]

desiredCueTimes = [fixCueInt ...
    fixCueInt + toneDur + toneInt ...
    fixCueInt + 2*toneDur + 2*toneInt]

presTimes = [];
reqPresTimes = [];
cueTimes = [];
reqCueTimes = [];
devTrials = [];
SOA = [];
trialCnt = 0;
for iBlock = 1:size(data,2)
   for iTrial = 1:data{iBlock}.nTrialsPerBlock;
       
       trialCnt = trialCnt + 1;
       
       if iTrial > 1
       SOA = [SOA data{iBlock}.presentationTime{iTrial}(1) - data{iBlock}.presentationTime{iTrial-1}(1)];
       end
       
       presTimes =    [presTimes    ; data{iBlock}.presentationTime{iTrial} - data{iBlock}.presentationTime{iTrial}(1)];
       reqPresTimes = [reqPresTimes ; data{iBlock}.reqPresentationTime{iTrial} - data{iBlock}.presentationTime{iTrial}(1)];
       
       presTimesDev = data{iBlock}.presentationTime{iTrial} - data{iBlock}.presentationTime{iTrial}(1) - desiredPresTimes;
       
       cueTimes =     [cueTimes     ; data{iBlock}.cueTime{iTrial} - data{iBlock}.presentationTime{iTrial}(1)];
       reqCueTimes =     [reqCueTimes     ; data{iBlock}.reqCueTime{iTrial} - data{iBlock}.presentationTime{iTrial}(1)];
       
       cueTimesDev = data{iBlock}.cueTime{iTrial} - data{iBlock}.presentationTime{iTrial}(1) - desiredCueTimes;
       
       if sum(abs(presTimesDev) > MoE) > 0 || sum(abs(cueTimesDev) > MoE) > 0
           % mark the trial as problematic
           devTrials = [devTrials trialCnt];
       end
       
   end
end

% round all times to the nearest millisecond
presTimes = round(1000*presTimes)/1000;
reqPresTimes = round(1000*reqPresTimes)/1000;
cueTimes = round(1000*cueTimes)/1000;
reqCueTimes = round(1000*reqCueTimes)/1000;

%reqPresTimes
presTimes

% presTimes has 6 columns:
% 1: onset of fixation cue
% 2: offset of fixation cue
% 3: onset of shape #1
% 4: offset of shape #1
% 5: onset of shape #2
% 6: offset of shape #2

%reqCueTimes
cueTimes

% cueTimes has 3 colums, one for each tone.

disp('Problematic trials:')
if ~isempty(devTrials)
    disp(num2str(devTrials));
    disp('Flip times:')
    presTimes(devTrials,:)
    disp('Audio times:')
    cueTimes(devTrials,:)
else
    disp('none.')
end

% Check SOAs
disp(sprintf('SOA: mean = %g, min = %g, max = %g',mean(SOA),min(SOA),max(SOA)))

end