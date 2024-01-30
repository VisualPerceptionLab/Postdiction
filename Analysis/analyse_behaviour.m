function all_runs_behaviour = analyse_behaviour(subject)
% TO-DO:
% Average confidence undesired, desired and both. What analysis?
% Scores. Inclusion criteria checker?
% Checks for time.
% which answers are missed? 

% Scores seem okay
% Conf has some bugs, time still need to check

% Find out which operating system we're running on
if ispc
    results_path = 'D:\Documents\PhD project\postdiction_AV_fMRI\Data Collection\Data';
elseif isunix
    results_path = 'D:/something';
end

path = dir(fullfile(results_path, subject, 'results_mainexp_*'));
% Create results, fill results with each iBlock
for run=1:length(path)
    results = load(fullfile(results_path, subject, path(run).name)).data;

    nTrials = size(results{1}.condition, 2);
    nBlocks = size(results, 2);
    conditions = 4;
    
    % Collect results, confidence per condition depending on desired or
    % undesired or average.
    
    for i=1:nBlocks
        all_scores(i,1) = results{i}.twoVeridicalscore;
        all_scores(i,2) = results{i}.AVscore;
        all_scores(i,3) = results{i}.IVscore;
        all_scores(i,4) = results{i}.threeVeridicalscore;
        misses(i) = sum(results{i}.flashAnswer<0);
    end
    
    trial_scores.all_scores = all_scores;
    % Get average of blocks per condition
    for i=1:conditions
        average_scores(i) = mean(all_scores(:,i));
        std_scores(i) = std(all_scores(:,i))
    end
    trial_scores.average_scores = average_scores;
    trial_scores.misses = misses;
    
    behaviour.trial_scores = trial_scores;
    
    % Average confidence per condition for desired, undesired, and both.
    % also do standard deviation and misses.
    % could write a check here to see if a participant passes.
    for iBlock = 1:nBlocks
       % select desired answers
       % maybe first cond, then desired/undesired?
       cond1_des = find(results{iBlock}.condition==1 & results{iBlock}.flashAnswer==2);
       cond2_des = find(results{iBlock}.condition==2 & results{iBlock}.flashAnswer==3);
       cond3_des = find(results{iBlock}.condition==3 & results{iBlock}.flashAnswer==2);
       cond4_des = find(results{iBlock}.condition==4 & results{iBlock}.flashAnswer==3);
       
       confidences.desired.cond1.all{iBlock} = results{iBlock}.confAnswer(cond1_des);

       confidences.desired.cond1.mean(iBlock) = mean(confidences.desired.cond1.all{iBlock}(confidences.desired.cond1.all{iBlock}>10) -10);
       confidences.desired.cond1.std(iBlock) = std(confidences.desired.cond1.all{iBlock}(confidences.desired.cond1.all{iBlock} >10) -10);
    
       confidences.desired.cond2.all{iBlock} = results{iBlock}.confAnswer(cond2_des);
       confidences.desired.cond2.mean(iBlock) = mean(confidences.desired.cond2.all{iBlock}(confidences.desired.cond2.all{iBlock}>10) -10);
       confidences.desired.cond2.std(iBlock) = std(confidences.desired.cond2.all{iBlock}(confidences.desired.cond2.all{iBlock}>10) -10);
    
       confidences.desired.cond3.all{iBlock} = results{iBlock}.confAnswer(cond3_des);
       confidences.desired.cond3.mean(iBlock) = mean(confidences.desired.cond3.all{iBlock}(confidences.desired.cond3.all{iBlock}>10) -10);
       confidences.desired.cond3.std(iBlock) = std(confidences.desired.cond3.all{iBlock}(confidences.desired.cond3.all{iBlock}>10) -10);
    
       confidences.desired.cond4.all{iBlock} = results{iBlock}.confAnswer(cond4_des);
       confidences.desired.cond4.mean(iBlock) = mean(confidences.desired.cond4.all{iBlock}(confidences.desired.cond4.all{iBlock}>10) -10);
       confidences.desired.cond4.std(iBlock) = std(confidences.desired.cond4.all{iBlock}(confidences.desired.cond4.all{iBlock}>10) -10);
    
       cond1_undes = find(results{iBlock}.condition==1 & results{iBlock}.flashAnswer==3);
       cond2_undes = find(results{iBlock}.condition==2 & results{iBlock}.flashAnswer==2);
       cond3_undes = find(results{iBlock}.condition==3 & results{iBlock}.flashAnswer==3);
       cond4_undes = find(results{iBlock}.condition==4 & results{iBlock}.flashAnswer==2);
    
       confidences.undesired.cond1.all{iBlock} = results{iBlock}.confAnswer(cond1_undes);
       confidences.undesired.cond1.mean(iBlock) = mean(confidences.undesired.cond1.all{iBlock}(confidences.undesired.cond1.all{iBlock}>10) -10);
       confidences.undesired.cond1.std(iBlock) = std(confidences.undesired.cond1.all{iBlock}(confidences.undesired.cond1.all{iBlock}>10) -10);
    
       confidences.undesired.cond2.all{iBlock} = results{iBlock}.confAnswer(cond2_undes);
       confidences.undesired.cond2.mean(iBlock) = mean(confidences.undesired.cond2.all{iBlock}(confidences.undesired.cond2.all{iBlock}>10) -10);
       confidences.undesired.cond2.std(iBlock) = std(confidences.undesired.cond2.all{iBlock}(confidences.undesired.cond2.all{iBlock}>10) -10);
    
       confidences.undesired.cond3.all{iBlock} = results{iBlock}.confAnswer(cond3_undes);
       confidences.undesired.cond3.mean(iBlock) = mean(confidences.undesired.cond3.all{iBlock}(confidences.undesired.cond3.all{iBlock}>10) -10);
       confidences.undesired.cond3.std(iBlock) = std(confidences.undesired.cond3.all{iBlock}(confidences.undesired.cond3.all{iBlock}>10) -10);
    
       confidences.undesired.cond4.all{iBlock} = results{iBlock}.confAnswer(cond4_undes);
       confidences.undesired.cond4.mean(iBlock) = mean(confidences.undesired.cond4.all{iBlock}(confidences.undesired.cond4.all{iBlock}>10) -10);
       confidences.undesired.cond4.std(iBlock) = std(confidences.undesired.cond4.all{iBlock}(confidences.undesired.cond4.all{iBlock}>10) -10);
       
       confidences.misses(iBlock) = sum(results{iBlock}.confAnswer<10);
    end
    

    % checker function
    %condition 1 larger than 85% correct
    screened = true;
    if trial_scores.average_scores(1) < 0.85
        screened = false
    end
    if trial_scores.average_scores(4) < 0.85
        screened = false
    end
    highconfav = 0;
    for iBlock = 1:nBlocks
        % count
        highconfav = sum(confidences.desired.cond2.all{iBlock} < 13 & confidences.desired.cond2.all{iBlock} > 10)
    end

    if highconfav < 15
        screened = false;
    end
    disp(screened)
    %condition 2 larger than 35% > 2.5
    %condition 4 larger than 85% correct
    

    behaviour.confidences = confidences;
    
    % timing measurements:
    
    % between trial timing in time_intervals, per block. Maybe plot with
    % boundaries 5s and 8s.
    for iBlock = 1:nBlocks
        for nTrial =1: nTrials
            % can this be simplified with (:,)?
            initialTimings(nTrial) = results{iBlock}.presentationTime(nTrial,1);
        end
        condition{iBlock} = results{iBlock}.condition;
        time_intervals.trial_length{iBlock} = initialTimings(2:nTrials) - initialTimings(1:nTrials-1);
    end
    
    % between auditory and visual
    for iBlock = 1:nBlocks
        withinstim{iBlock,1} = results{iBlock}.startAudioTime(:,1) - results{iBlock}.presentationTime(:,2);
        withinstim{iBlock,2} = results{iBlock}.startAudioTime(:,2) - results{iBlock}.presentationTime(:,3);
        withinstim{iBlock,3} = results{iBlock}.startAudioTime(:,3) - results{iBlock}.presentationTime(:,4);
    end
    time_intervals.withinstim = withinstim;
    
    % between visual, can analyze per condition here with presentationTimes.
    for iBlock = 1:nBlocks
        flashTimes=results{iBlock}.presentationTime(iBlock,:);
        betweenvis{iBlock,1} = flashTimes(:,2) - flashTimes(:,1);
        betweenvis{iBlock,2} = flashTimes(:,3) - flashTimes(:,2);
        betweenvis{iBlock,3} = flashTimes(:,4) - flashTimes(:,3);
    end
    time_intervals.betweenvis = betweenvis;
    
    % between auditory, can analyze per condition here with presentationTimes.
    for iBlock = 1:nBlocks
        audioTimes=results{iBlock}.startAudioTime(iBlock,:);
        betweenaudio{iBlock,1} = audioTimes(:,2) - audioTimes(:,1);
        betweenaudio{iBlock,2} = audioTimes(:,3) - audioTimes(:,2);
    end
    time_intervals.betweenaudio = betweenaudio;
    
    % between block timing - untested. There is only one initialTime. Subtract
    % presentationTimes?
    for iBlock = 1:nBlocks-1
        initialTiming1(iBlock) = results{iBlock}.presentationTime(1,1);
        initialTiming2(iBlock) = results{iBlock+1}.presentationTime(1,1);
        betweenBlock{iBlock} = initialTiming2 - initialTiming1;
    end
    time_intervals.betweenBlock = betweenBlock;
    
    behaviour.time_intervals = time_intervals;

    all_runs_behaviour{run} = behaviour;
end


