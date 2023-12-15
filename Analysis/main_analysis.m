% here we could call betasanalysis.m and analyse_behavior to plot/analyse
% all data.
clear all; close all;
subjects = {'Oliver_humanpilot','Oliver_humanpilot_copy_for_testing'};

% How do I make sure this works for one and for many subjects?
% The data structure is
% subjects_behaviour{subject}{run}{block}.[trial_scores, confidences,
% time_intervals]
% Test this pipeline

nSubjects = length(subjects);
for iSubject=1:nSubjects
    behaviour = analyse_behaviour(subjects{iSubject});
    subjects_behaviour{iSubject} = behaviour;
end

% Make plots
for iSubject=1:nSubjects
    behaviour_data = subjects_behaviour{iSubject};
    scores = behaviour_data.all_scores;
    subplot(2, ceil(nSubjects/2), iSubject);
    % plot scores
    for iRun=1:length(behaviour_data)
        % average over blocks
        % alternatively average over runs and look at blocks

        data{iRun} = behaviour_data
    data{behaviour_data}
    plot(data, 'LineWidth', 2);
    
    % Customize subplot title
    title(behaviour_data);
    
    % Add other customization as needed
    
    % Example: Add labels, legend, etc. (replace with your own code)
    xlabel('X-axis');
    ylabel('Y-axis');
    legend('Data');

% Behavioral analysis
% Plot the scores per block with average. 4 subbars are blocks, 4 bars are
% conditions.
% Build a plot of timings versus the times it should have
% Plots of confidence per condition, for desired and undesired. subbars are
% conditions, bars are des/undes?


% Neuroimaging analysis

% pRF beta analysis