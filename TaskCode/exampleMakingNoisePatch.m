global distFromScreen pixelsPerCm

gratingContrast = 0.04;
noiseContrast = .2;
noisePatch = 2;
gratingSize_degrees = 10;
gratingPhase = rand*2*pi;
spatFreq = .5;
innerDegree = 1.5;
gratingRotAngle = -45;
distFromScreen = 91;
pixelsPerCm = 1920/31;

gaborPatch = makeStimulus(gratingContrast,noiseContrast,noisePatch,gratingSize_degrees,gratingPhase,spatFreq,innerDegree);
gaborPatch = mat2gray(gaborPatch,[min(min(gaborPatch)) max(max(gaborPatch))]);
gaborPatch = gaborPatch + .0001;
gaborPatch = imrotate(gaborPatch,gratingRotAngle,'crop');
gaborPatch(gaborPatch == 0) = gaborPatch(length(gaborPatch)/2,length(gaborPatch)/2); % make corners gaborPatch same colour as middle
imshow(gaborPatch)