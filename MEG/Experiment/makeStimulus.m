function gaborPatch = makeStimulus(contrastGrating,noiseContrast,noisePatch,sizeGrating,phaseGrating,spatialFrequency_inDegrees, sizeInnerCircleDegrees)
% The grating is first created in terms of desired luminance values, and
% then these are converted to RGB. Slow, but (relatively) clean.
% spatialFrequency: cycles/degree

%tic
width = 2*degrees2pixels(sizeGrating/2);
if noiseContrast > 0
   % load noise patches
   noiseFile = sprintf('noisePatches_%dpix.mat',width);
   load(noiseFile,'noisePatches')
end

sizeInnerCircle = degrees2pixels(sizeInnerCircleDegrees);

%startLinearDecayDegrees = 1;
startLinearDecayDegrees = sizeGrating/15;
startLinearDecay = degrees2pixels(startLinearDecayDegrees);

nCycles = sizeGrating*spatialFrequency_inDegrees; % number of cycles in a stimulus

% compute the pixels per grating period
pixelsPerGratingPeriod = width / nCycles;

spatialFrequency = 1 / pixelsPerGratingPeriod; % How many periods/cycles are there in a pixel?
radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)

% Make luminance calculations based on the grating contrast value (this will change during staircasing)
[~, ~, ~, G_Lmin, G_Lmax, lum] = calibrateLum(1); %calibrateLum(contrastGrating);
G_background = (G_Lmin+G_Lmax)/2;
G_lumRange = G_Lmax - G_background;

halfWidthOfGrid = width / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

widthArray = setdiff(widthArray,0); % remove the zero in the middle to make consistent with noise patch.

% Creates a two-dimensional square grid.  For each element i = i(x0, y0) of
% the grid, x = x(x0, y0) corresponds to the x-coordinate of element "i"
% and y = y(x0, y0) corresponds to the y-coordinate of element "i"
[x y] = meshgrid(widthArray);

% make annulusMatrix (without using for loops)
stimRadii      = sqrt(x.^2 + y.^2);
annulusMatrix = stimRadii <= (width+1)/2;

% Creates a sinusoidal grating, where the period of the sinusoid is
% approximately equal to "pixelsPerGratingPeriod" pixels.
% Note that each entry of gratingMatrix varies between minus one and
% one; -1 <= gratingMatrix(x0, y0)  <= 1
stimulusMatrix = sin(radiansPerPixel * x + phaseGrating);

if noiseContrast > 0
    noiseMatrix = 2*(squeeze(noisePatches(noisePatch,:,:)) - 0.5); % scale noise to -1 to 1
    stimulusMatrix = contrastGrating*stimulusMatrix + noiseContrast*noiseMatrix;
else
    stimulusMatrix = contrastGrating*stimulusMatrix;
end

% Make a fading annulus, to use as a mask.
annulusMatrix = makeLinearMaskCircleAnn(width,width,sizeInnerCircle,startLinearDecay,width/2+1);

% figure;
% subplot(2,2,1)
% imagesc(stimulusMatrix)
% subplot(2,2,2)
% imagesc(annulusMatrix)

stimulusMatrix = stimulusMatrix .* annulusMatrix;

% subplot(2,2,3)
% imagesc(stimulusMatrix)

% create luminance-defined grating
gaborPatch = G_lumRange*stimulusMatrix + G_background;

% the gaborPatch is currently defined in terms of luminance; we need to
% convert it to RGB.
gaborVect = reshape(gaborPatch,numel(gaborPatch),1);
gaborVect = interp1(lum,0:255,gaborVect,'nearest');
gaborPatch = reshape(gaborVect,size(gaborPatch));

% subplot(2,2,4)
% imagesc(gaborPatch)
% colormap('gray')

end
