% here we could call betasanalysis.m and analyse_behavior to plot/analyse
% all data.
clear all; close all;
subjects = {'S07'};

% How do I make sure this works for one and for many subjects?
% The data structure is
% subjects_behaviour{subject}{run}{block}.[trial_scores, confidences,
% time_intervals]
% Test this pipeline

nSubjects = length(subjects);
for iSubject=1:nSubjects
    behaviour_data{iSubject} = analyse_behaviour(subjects{iSubject});
end

% Make plots

% Plot the scores per block with average. Grouped per run, 4 groups are
% conditions.
figure;
for iSubject=1:nSubjects
    subject_behaviour = behaviour_data{iSubject};

    subplot(2, ceil(nSubjects/2), iSubject);
    % plot scores
    for iRun=1:length(subject_behaviour)
        % average over blocks
        % alternatively average over runs and look at blocks
        % might have to include misses here? is a block with 2 answers
        % equal to one with 10?
        data(:,iRun)= mean(subject_behaviour{iRun}.trial_scores.all_scores, 1);
    end
    bar(data, 'LineWidth', 2);
    
    % Customize subplot title
    title([subjects{iSubject}]);
    
    % Add other customization as needed
    
    % Example: Add labels, legend, etc. (replace with your own code)
    xlabel('Scores for each run, per condition');
    ylabel('% desired ans');
    ylim([0 1])
    legend('Run1', 'Run2', 'Run3');
end

hold off
% Plots of confidence per condition, for desired and undesired. Grouped by
% condition, for desired and undesired

figure;
for iSubject=1:nSubjects
    subject_behaviour = behaviour_data{iSubject};
    subplot(2, ceil(nSubjects/2), iSubject);
    % plot confidence per run
%     for iRun=1:length(subject_behaviour)
% 
%     end
%     % plot confidence desired vs undesired
    for iRun=1:length(subject_behaviour)
        % average over blocks
        % alternatively average over runs and look at blocks
        desired(1,iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond1.mean);
        desired(2,iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond2.mean);
        desired(3,iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond3.mean);
        desired(4,iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond4.mean);
        undesired(1,iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond1.mean);
        undesired(2,iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond2.mean);
        undesired(3,iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond3.mean);
        undesired(4,iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond4.mean);

        % standard dev bars des/undes
        cond_des_std(1, iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond1.std); %/ sqrt(length(Roi{1,cond}(~isnan(Roi{1,cond}))));
        cond_des_std(2, iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond2.std);
        cond_des_std(3, iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond3.std);
        cond_des_std(4, iRun) = nanmean(subject_behaviour{iRun}.confidences.desired.cond4.std);

        cond_undes_std(1, iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond1.std); %/ sqrt(length(Roi{1,cond}(~isnan(Roi{1,cond}))));
        cond_undes_std(2, iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond2.std);
        cond_undes_std(3, iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond3.std);
        cond_undes_std(4, iRun) = nanmean(subject_behaviour{iRun}.confidences.undesired.cond4.std);
        % collapse into one row
    end
    plotstds(:,1) = mean(cond_des_std, 2);
    plotstds(:,2) = mean(cond_undes_std, 2);
    % combine desired and undesired, such that they are both columns
    % how to handle nans?
    conf_data(:,1) = mean(desired, 2);
    conf_data(:,2) = mean(undesired, 2);
    bar(conf_data, 'LineWidth', 2);

    % Calculate x-coordinates for error bars
    groupWidth = 0.6;  % Adjust this value based on your preference
    numGroups = 4;
    numBars = 2;
    barWidth = groupWidth / numBars;
    
    x = zeros(numGroups, numBars);
    for i = 1:numBars
        x(:,i) = (1:numGroups) - (groupWidth / 2) + (i-0.5) * groupWidth / numBars;
    end
    hold on;
%     for cond = 1:4
%         x = (1:2) - .48 + cond*0.19;  % Adjust x-coordinates for each set of bars
    conf_data(isnan(conf_data)) = 0;
    plotstds(isnan(plotstds)) = 0;
    errorbar(x, conf_data, plotstds, '.', 'LineWidth', 1.5);

    hold off;
    %bar(undesired, 'LineWidth', 2);
    
    % Customize subplot title
    title([subjects{iSubject}]);
    
    % Add other customization as needed
    
    % Example: Add labels, legend, etc. (replace with your own code)
    xlabel('Conf for each condition');
    ylabel('Confidence');
    ylim([1 4])
    legend('desired', 'undesired');
end

% Build a plot of timings versus the times it should have

% Neuroimaging analysis

% pRF beta analysis