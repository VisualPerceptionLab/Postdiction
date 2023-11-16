function [] = makeFixCross(fixColour, fixDiam, background)

global window;
global fixCrossTexture fixRect fixCrossTexture_ITI fixCrossTexture_dim fixCrossTexture_miss;

fixRect = [0 0 fixDiam fixDiam];
fixBgd = zeros(fixDiam,fixDiam,2)+background;
fixCrossTexture = Screen('MakeTexture', window, fixBgd);
elDiam = floor(fixDiam/4);
Screen('FillArc',fixCrossTexture,fixColour,CenterRect([0 0 elDiam elDiam],fixRect),0,360);
Screen('FrameArc',fixCrossTexture,fixColour,CenterRect([0 0 elDiam*4 elDiam*4],fixRect),0,360,elDiam/3,elDiam/3);
% Also make version without the surrounding circle, to present during ITI
fixCrossTexture_ITI = Screen('MakeTexture', window, fixBgd);
elDiam = floor(fixDiam/4);
Screen('FillArc',fixCrossTexture_ITI,fixColour,CenterRect([0 0 elDiam elDiam],fixRect),0,360);
%Screen('FrameArc',fixCrossTexture_error,fixColour,CenterRect([0 0 elDiam*3 elDiam*3],fixRect),0,360,elDiam/3,elDiam/3);

% And a version with a dim dot, to do a fixation dimming task on.
fixCrossTexture_dim = Screen('MakeTexture', window, fixBgd);
elDiam = floor(fixDiam/4);
dimColour = (fixColour + 2*background)/3;
Screen('FillArc',fixCrossTexture_dim,dimColour,CenterRect([0 0 elDiam elDiam],fixRect),0,360);
Screen('FrameArc',fixCrossTexture_dim,fixColour,CenterRect([0 0 elDiam*4 elDiam*4],fixRect),0,360,elDiam/3,elDiam/3);

% And a version with a dim dot, to do a fixation dimming task on.
fixCrossTexture_miss = Screen('MakeTexture', window, fixBgd);
elDiam = floor(fixDiam/4);
dimColour = [255 0 0];
Screen('FillArc',fixCrossTexture_miss,dimColour,CenterRect([0 0 elDiam elDiam],fixRect),0,360);
Screen('FrameArc',fixCrossTexture_miss,fixColour,CenterRect([0 0 elDiam*4 elDiam*4],fixRect),0,360,elDiam/3,elDiam/3);

end