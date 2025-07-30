% Parameters for the Gaussians
means_x = [-1.5, 0, 1.5]; % x-coordinates of the Gaussian centers
means_y = [-2, -2, -2]; % y-coordinates of the Gaussian centers
sigs_x = [0.15, 0.15, 0.15]; % x standard deviations
sigs_y = [0.4, 0.4, 0.4]; % y standard deviations

% Create a grid from -5.5 to 5.5
[x, y] = meshgrid(-5.5:0.1:5.5, -5.5:0.1:5.5);
z = zeros(size(x));

% Evaluate each Gaussian
for i = 1:length(means_x)
    z = z + exp(-((x - means_x(i)).^2 / (2 * sigs_x(i)^2) + (y - means_y(i)).^2 / (2 * sigs_y(i)^2)));
end

% Create the heatmap
figure;
imagesc(x(1,:), y(:,1), z);
axis xy; % Correct axis orientation
colormap(jet); % Choose a color map
colorbar; % Show color scale
hold on;

% Draw the fixation point at the center
fixation_x = 0; % Center x-coordinate
fixation_y = 0; % Center y-coordinate
plot(fixation_x, fixation_y, 'k+', 'MarkerSize', 15, 'LineWidth', 2); % Fixation point
hold off;

% Set axis limits
xlim([-5.5, 5.5]);
ylim([-5.5, 5.5]);

% Add labels
xlabel('X-axis');
ylabel('Y-axis');
title('Heatmap of Three Gaussians with Variable Means and Fixation Point');