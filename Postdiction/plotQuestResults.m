function [] = plotQuestResults(data)

questMean{1} = [];
questSd{1} = [];
questMean{2} = [];
questSd{2} = [];
stimDiff{1} = [];
stimDiff{2} = [];
correct{1} = [];
correct{2} = [];
for iBlock = 1:size(data,2)
    currentTask = 2 - mod(data{iBlock}.runType,2);
    questMean{currentTask} = [questMean{currentTask} 10.^data{iBlock}.qMean_updated];
    questSd{currentTask} = [questSd{currentTask} 10.^data{iBlock}.qSD_updated];
    if currentTask == 1
        stimDiff{currentTask} = [stimDiff{currentTask} abs(data{iBlock}.orientationDiff)];
    elseif currentTask == 2
        stimDiff{currentTask} = [stimDiff{currentTask} abs(data{iBlock}.contrastDiff)];
    end
    correct{currentTask} = [correct{currentTask} data{iBlock}.answeredCorrect];
end

% figure;
% for iTask = 1:2
%     subplot(2,1,iTask)
%     %errorbar(questMean{iTask},questSd{iTask})
%     plot(questMean{iTask})
%     text = sprintf('Staircase task %d',iTask);
%     title(text)
%     xlabel('Trial nr')
%     if iTask == 1
%         ylabel('Angle diff')
%     elseif iTask == 2
%         ylabel('Contrast diff')
%     end
% end

figure;
for iTask = 1:2
    subplot(2,1,iTask)
    %errorbar(questMean{iTask},questSd{iTask})
    plot(stimDiff{iTask},'sk')
    text = sprintf('Staircase task %d',iTask);
    title(text)
    xlabel('Trial nr')
    if iTask == 1
        ylabel('Angle diff')
    elseif iTask == 2
        ylabel('Contrast diff')
    end
    
    hold on
    %plot(abs(gratingDiff),'sk')
    correctPlot = abs(stimDiff{iTask}); correctPlot(correct{iTask}==0)=NaN;
    plot(correctPlot,'xg')
    correctPlot = abs(stimDiff{iTask}); correctPlot(correct{iTask}==1)=NaN;
    plot(correctPlot,'xr')
    
end

for iTask = 1:2
    if iTask == 1
        disp('Orientation task');
    elseif iTask == 2
        disp('Contrast task');
    end
    text = sprintf('Accuracy: %d percent correct.\n',round(100*nanmean(correct{iTask})));
    disp(text);
end

end