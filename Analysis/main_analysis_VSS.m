% here we could call betasanalysis.m and analyse_behavior to plot/analyse
% all data.
clear all; close all;
% select participants 
subject_nrs = [1:17 19:22 24:36 42 44:52 54:75];
scanner = true;
%subject_nrs = [2 3 7 10 12 14 15 22 24 25 27 29 30 31 35] % screening passed
subjects= [];
for pp=1:length(subject_nrs)
    subjects = [subjects; (sprintf('S%02d', subject_nrs(pp)))];
end
%subjects = {'S01','S02', 'S03', 'S04', 'S05', 'S06'};%{'S22'}%

% How do I make sure this works for one and for many subjects?
% The data structure is
% subjects_behaviour{subject}{run}{block}.[trial_scores, confidences,
% time_intervals]
% Test this pipeline

% Find out which operating system we're running on
if ispc
    results_path = 'D:\Documents\PhD_project\postdiction_AV_fMRI\data_collection\Data';
elseif isunix
    results_path = '/mnt/d/Documents/PhD_project/postdiction_AV_fMRI/data_collection/Data';
end

nSubjects = length(subjects);
index = 0;
for iSubject=1:nSubjects
    subject = subjects(iSubject,:);
    if scanner == true
        path = dir(fullfile(results_path, subject, subject, 'results_mainexp_*'));
    else 
         path = dir(fullfile(results_path, subject, 'results_mainexp_*'));
    end
    % Create results, fill results with each iBlock
    files_found = size(path);
    if files_found(1)>0
        index = index+1;
        behaviour_data{index} = analyse_behaviour(subject, results_path, scanner);
    end
end

% Make plots

% Plot the scores per block with average. Grouped per run, 4 groups are
% conditions.

group_analysis = true;
% if group_analysis == true
%     figure;
% end
%group_data = mat(nSubjects, 4)
for iSubject=1:index
    subject_behaviour = behaviour_data{iSubject};
    % 1 plot per individual
    if group_analysis == false
        
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
        title([num2str(subjects(iSubject))]);
        
        % Add other customization as needed
        
        % Example: Add labels, legend, etc. (replace with your own code)
        xlabel('Scores per condition');
        ylabel('3 flashes');
        ylim([0 1])
        %legend('Run1', 'Run2', 'Run3', 'Run4');
    else
        group_data(iSubject, 1:4) = subject_behaviour{1}.trial_scores.average_scores;
        
        group_data_conf(1, 1, iSubject) = nanmean(subject_behaviour{1}.confidences.desired.cond1.mean);
        group_data_conf(1, 2, iSubject) = nanmean(subject_behaviour{1}.confidences.desired.cond2.mean);
        group_data_conf(1, 3, iSubject) = nanmean(subject_behaviour{1}.confidences.desired.cond3.mean);
        group_data_conf(1, 4, iSubject) = nanmean(subject_behaviour{1}.confidences.desired.cond4.mean);
        group_data_conf(2, 1, iSubject) = nanmean(subject_behaviour{1}.confidences.undesired.cond1.mean);
        group_data_conf(2, 2, iSubject) = nanmean(subject_behaviour{1}.confidences.undesired.cond2.mean);
        group_data_conf(2, 3, iSubject) = nanmean(subject_behaviour{1}.confidences.undesired.cond3.mean);
        group_data_conf(2, 4, iSubject) = nanmean(subject_behaviour{1}.confidences.undesired.cond4.mean);

        flash_answers(iSubject,:) = subject_behaviour{1}.flashans
        expdesigns(iSubject,:) = subject_behaviour{1}.expdesign
        

        

        %avg_flash_cond(1:4) = avg_flash_cond(1:4) + avg_flash_pp/nSubjects
    end
end


if group_analysis == true
    figure;
        
        % statistical comparison between conditions
        for iCond=1:4
            cond_answers(iCond,:) = flash_answers(expdesigns==iCond);
        end
        % correct test for binary/ordinal and non parametric?
        % perhaps mean first per pp
        % and use a non normal test
        [h,p] = ranksum(cond_answers(2,:), cond_answers(1,:));
        [h,p] = ranksum(cond_answers(4,:), cond_answers(2,:));

        confdes1= squeeze(group_data_conf(1,1,:));
        confdes2= squeeze(group_data_conf(1,2,:));
        confdes3= squeeze(group_data_conf(1,3,:));
        confdes4= squeeze(group_data_conf(1,4,:));

        [h,p] = ranksum(cond_answers(2,:), cond_answers(1,:));
        [h,p] = ranksum(cond_answers(4,:), cond_answers(2,:));
        [h,p] = ranksum(cond_answers(4,:), cond_answers(3,:));
        [h,p] = ranksum(cond_answers(3,:), cond_answers(1,:));

        % correct for Peter's graphs

        group_data(:,1) = 1-group_data(:,1);%1-
        group_data(:,3) = 1-group_data(:,3);%1-
        group_data_mean = mean(group_data);
        group_data_ste = std(group_data)/ sqrt(length(group_data(:,1)));
        %plot(group_data_mean)
        bar(group_data_mean([1,2,4]), 'LineWidth', 2);
            % Calculate x-coordinates for error bars
        groupWidth = 0.6;  % Adjust this value based on your preference
        numGroups = 3;
        numBars = 1;
        barWidth = groupWidth / numBars;
        
        x = zeros(numGroups, numBars);
        for i = 1:numBars
            x(:,i) = (1:numGroups) - (groupWidth / 2) + (i-0.7);% * groupWidth / numBars;
        end
        hold on;
    %     for cond = 1:4
    %         x = (1:2) - .48 + cond*0.19;  % Adjust x-coordinates for each set of bars
        errorbar(x, group_data_mean([1,2,4]), group_data_ste([1,2,4]), '.', 'LineWidth', 1.5);
        
        if ~scanner
        % Add a line to denote significance comparison
        x = [1 2]; % X-coordinates of the two bars being compared
        y = [0.65 0.65]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.01, '**', 'FontSize', 18, 'HorizontalAlignment', 'center');

        % Add a line to denote significance comparison
        x = [3 4]; % X-coordinates of the two bars being compared
        y = [0.965 0.965]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.01, '**', 'FontSize', 18, 'HorizontalAlignment', 'center');
        end
        
        if scanner
        % Add a line to denote significance comparison
        x = [1 2]; % X-coordinates of the two bars being compared
        y = [0.93 0.93]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.01, '**', 'FontSize', 18, 'HorizontalAlignment', 'center');

%         % Add a line to denote significance comparison
%         x = [3 4]; % X-coordinates of the two bars being compared
%         y = [0.97 0.97]; % Y-coordinate (above the taller bar)
%         plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
%         % Add a significance annotation (assuming the difference is significant)
%         text(mean(x), y(1) + 0.01, '**', 'FontSize', 18, 'HorizontalAlignment', 'center');
        end

%         x = [1 2]; % X-coordinates of the two bars being compared
%         y = [0.83 0.83]; % Y-coordinate (above the taller bar)
%         plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
%         % Add a significance annotation (assuming the difference is significant)
%         text(1.5, 0.85, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');

        x_labels = {"Congr. Two", "illusion", "Congr. Three"};
        xticklabels(x_labels)
        % Customize subplot title
        title(["Group average for subjects: ", index]);
        xlabel('Conditions');
        ylabel('3 flash');
        ylim([0 1])
        figure;
        % confs
        group_data_conf_des = [nanmean(group_data_conf(1,1,:)) nanmean(group_data_conf(1,2,:)) nanmean(group_data_conf(1,3,:)) nanmean(group_data_conf(1,4,:))]; %4-(x-1)
        group_data_conf_undes = [nanmean(group_data_conf(2,1,:)) nanmean(group_data_conf(2,2,:)) nanmean(group_data_conf(2,3,:)) nanmean(group_data_conf(2,4,:))];
        group_data_conf_des_ste = [nanstd(group_data_conf(1,1,:))/ sqrt(length(group_data(:,1))) nanstd(group_data_conf(1,2,:))/ sqrt(length(group_data(:,1))) nanstd(group_data_conf(1,3,:))/ sqrt(length(group_data(:,1))) nanstd(group_data_conf(1,4,:))/ sqrt(length(group_data(:,1)))];
        group_data_conf_undes_ste = [nanstd(group_data_conf(2,1,:))/ sqrt(length(group_data(:,1))) nanstd(group_data_conf(2,2,:))/ sqrt(length(group_data(:,1))) nanstd(group_data_conf(2,3,:))/ sqrt(length(group_data(:,1))) nanstd(group_data_conf(2,4,:))/ sqrt(length(group_data(:,1)))];
        [h, p_ver3_2flash, ~, s]= ttest(squeeze(group_data_conf(1,4,:)), squeeze(group_data_conf(1,3,:)), tail='right')
        [h, p_ver3_3flash, ~, s]= ttest(squeeze(group_data_conf(2,4,:)), squeeze(group_data_conf(2,3,:)), tail='left')
        [h, p_ver2_2flash, ~, s]= ttest(squeeze(group_data_conf(1,1,:)), squeeze(group_data_conf(1,2,:)), tail='left')
        [h, p_ver2_3flash, ~, s]= ttest(squeeze(group_data_conf(2,1,:)), squeeze(group_data_conf(2,2,:)), tail='right')
                [h, p_ver2_3flash, ~, s]= ttest(squeeze(group_data_conf(2,1,:)), squeeze(group_data_conf(2,2,:)), tail='right')

        
        %plot(group_data_mean)
        plotste(:,1) = group_data_conf_des_ste;
        plotste(:,2) = group_data_conf_undes_ste;
        % combine desired and undesired, such that they are both columns
        % how to handle nans?
        conf_data(:,1) = 4-(group_data_conf_des-1);
        conf_data(:,2) = 4-(group_data_conf_undes-1);
        % change desired and undesired around for condition 2 and 4 so that they
        % become 2 and 3 flash
        
        bar(conf_data([1,2,4],:), 'LineWidth', 2);
    
        % Calculate x-coordinates for error bars
        groupWidth = 0.6;  % Adjust this value based on your preference
        numGroups = 3;
        numBars = 2;
        barWidth = groupWidth / numBars;
        %bar(undesired, 'LineWidth', 2);
        
        % Customize subplot title
        title(["Group conf average for subjects: ", index]);
        
        xlabel('Conditions');
        ylabel('Confidence');
        ylim([1 4])

        x_err = zeros(numGroups, numBars);
        for i = [1 2 4]
            x_err(:,i) = (1:numGroups) - (groupWidth / 2) + (i-0.5) * groupWidth / numBars;
        end
        hold on;
        
        % significance bars for confidence

        if ~scanner

        %p_ver3_2flash = 0.0027
        % Add a line to denote significance comparison
        x = [2.85 3.85]; % X-coordinates of the two bars being compared
        y = [3.65 3.65]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.005, '**', 'FontSize', 18, 'HorizontalAlignment', 'center');
        
        % p_ver3_3flash = 1.1090e-05
        % Add a line to denote significance comparison
        x = [3.15 4.15]; % X-coordinates of the two bars being compared
        y = [3.75 3.75]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.01, '***', 'FontSize', 18, 'HorizontalAlignment', 'center');
        
        %p_ver2_2flash = 4.8597e-07
        % Add a line to denote significance comparison
        x = [0.85 1.85]; % X-coordinates of the two bars being compared
        y = [3.86 3.86]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.01, '***', 'FontSize', 18, 'HorizontalAlignment', 'center');
        
        %p_ver2_3flash = 0.0161
        % Add a line to denote significance comparison
        x = [1.15 2.15]; % X-coordinates of the two bars being compared
        y = [3.45 3.45]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.01, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');

        end
        
        if scanner
%         %p_ver3_2flash = 0.0188
%         % Add a line to denote significance comparison
%         x = [2.85 3.85]; % X-coordinates of the two bars being compared
%         y = [3.75 3.75]; % Y-coordinate (above the taller bar)
%         plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
%         % Add a significance annotation (assuming the difference is significant)
%         text(mean(x), y(1) + 0.005, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
%         
%         % p_ver3_3flash = 0.0147
%         % Add a line to denote significance comparison
%         x = [3.15 4.15]; % X-coordinates of the two bars being compared
%         y = [3.85 3.85]; % Y-coordinate (above the taller bar)
%         plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
%         % Add a significance annotation (assuming the difference is significant)
%         text(mean(x), y(1) + 0.01, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
%         
        %p_ver2_2flash = 0.0054
        % Add a line to denote significance comparison
        x = [0.85 1.85]; % X-coordinates of the two bars being compared
        y = [3.84 3.84]; % Y-coordinate (above the taller bar)
        plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
        % Add a significance annotation (assuming the difference is significant)
        text(mean(x), y(1) + 0.01, '**', 'FontSize', 18, 'HorizontalAlignment', 'center');
        
%         %p_ver2_3flash = 0.0161
%         % Add a line to denote significance comparison
%         x = [1.15 2.15]; % X-coordinates of the two bars being compared
%         y = [3.45 3.45]; % Y-coordinate (above the taller bar)
%         plot(x, y, '-k', 'LineWidth', 1.5); % Line connecting the bars (black)
%         % Add a significance annotation (assuming the difference is significant)
%         text(mean(x), y(1) + 0.01, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
        hold on;
        end


        xticklabels(x_labels);
        errorbar(x_err, conf_data([1,2,4],:), plotste([1,2,4],:), '.', 'LineWidth', 1.5);
        legend({'2 flash', '3 flash', '', ''});
        hold off;



% Plots of confidence per condition, for desired and undesired. Grouped by
% condition, for desired and undesired
else
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
    plotstds(:,1) = nanmean(cond_des_std, 2);
    plotstds(:,2) = nanmean(cond_undes_std, 2);
    % combine desired and undesired, such that they are both columns
    % how to handle nans?
    conf_data(:,1) = 4-(nanmean(desired, 2)-1);
    conf_data(:,2) = 4-(nanmean(undesired, 2)-1);
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

% this probably messes with the averages
%     conf_data(isnan(conf_data)) = 0;
%     plotstds(isnan(plotstds)) = 0;
    errorbar(x, conf_data, plotstds, '.', 'LineWidth', 1.5);

    hold off;
    %bar(undesired, 'LineWidth', 2);
    
    % Customize subplot title
    title([subjects(iSubject)]);
    
    % Add other customization as needed
    
    % Example: Add labels, legend, etc. (replace with your own code)
    xlabel('Conf for each condition');
    ylabel('Confidence');
    ylim([1 4])
    legend('desired', 'undesired');
end
end
% Build a plot of timings versus the times it should have

% Neuroimaging analysis

% pRF beta analysis