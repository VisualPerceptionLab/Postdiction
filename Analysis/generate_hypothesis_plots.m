% Data: rows = groups (Flash 2, Control), columns = subgroups (Real Flash, No Flash)
data = [0.9,   % Flash 2: Real Flash > No Flash
         0.5];  % Control: equal bars

% Create the grouped bar plot
figure;
bar(data, 'grouped');

% Customize axes and labels
% ylabel('Similarity');
% xlabel('Location');
title('Similarity of illusory representation');
xticks(1:2);
set(gca,'ytick',[])
xticklabels({'Flash 2', 'Control'});
% legend({'Real Flash', 'No Flash'}, 'Location', 'northeastoutside');

% Optional visual tweaks
set(gca, 'FontSize', 12);
ylim([0 1]);  % Adjust based on values

% Optional color map
colormap([0.2 0.6 1.0; 0.8 0.8 0.8]);  % Custom RGB colors for bars
