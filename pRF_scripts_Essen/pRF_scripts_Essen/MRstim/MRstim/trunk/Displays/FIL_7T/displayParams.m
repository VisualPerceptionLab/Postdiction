function params = displayParams
% Projector at 7T in Essen
% Critical parameters
params.numPixels = [1920 1200];
params.dimensions = [35.5 22]; %[38.5 29.5]
params.distance = 113;
params.frameRate = 60;
params.cmapDepth = 10;
params.screenNumber = 0; %0; %check in scanner
% Descriptive parameters
params.computerName = 'FIL_7T';
params.monitor = 'Epson Projector';
%params.card = 'RadeonMobility7500';
%params.position = 'Jordan 474';

% pixels per cm in 7T
%mean(params.numPixels ./ params.dimensions)