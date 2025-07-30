% Define the data for the bars (4 groups, 3 bars per group)
data = [15, 15, 15; 
        5, 12, 15; 
        15, 15, 15; 
        2, 2, 2];

% Create a bar plot with grouped bars
figure;
bar(data, 'grouped')

% Customizing axes and labels
%xlabel('Location');
ylabel('Activity');
title('Hypothesized activation per location');
xticks(1:4);
xticklabels({'Flash 1', 'Flash 2', 'Flash 3', 'Control'});
legend({'No Flash', 'Illusion', 'Real Flash'}, 'Location', 'northeastoutside');

% Customize the appearance
set(gca, 'FontSize', 12);

% Hide the y-axis numbers
set(gca, 'YTick', []);

% Change the colors (optional)
colormap(jet);  % You can use other colormaps like 'parula', 'hsv', etc.

% Customize axis limits
ylim([0 20]);  % Adjust according to your data