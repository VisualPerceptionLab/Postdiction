% 1st Level analysis for Localiser
clear all; close all;

% Find out which operating system we're running on
if ispc
    % set the path to SPM
    spmDir = 'D:\spm12';
    addpath(spmDir)
elseif isunix
    
    % set the path to SPM
    spmDir = '/Users/peterkok/Documents/spm12';
    addpath(spmDir)
end

TR = 3.264;
dt = 32;

SOAbase = 5/TR % base SOA between trials, in TRs
SOAjitter = 3/TR
%SOAbase = 14/TR % base SOA between trials, in TRs
%SOAjitter = 0

%nTrials = 200;
%nscans = ceil(nTrials * (SOAbase+(1/2)*SOAjitter) + 10);
nscans = 3 * 2 * ceil(360/TR)
nTrials = ceil((nscans-10)/(SOAbase+(1/2)*SOAjitter))

time = (1:(nscans*dt))/dt;

nIters = 1000 % how many iterations to average over?
betas = NaN(3,4,nIters); % simulated voxels x conditions x iterations
tValues = NaN(3,4,nIters);
illusionT = NaN(3,nIters);
for i = 1:nIters
    
    twoflashtwobeep = zeros(1,nscans*dt);
    twoflashthreebeep = zeros(1,nscans*dt);
    threeflashtwobeep = zeros(1,nscans*dt);
    threeflashthreebeep = zeros(1,nscans*dt);
    
    % simulate neural responses to the four trial types:
    % 1) 2 flashes & beeps
    % 2) 2 flashes, 3 beeps
    % 3) 3 flashes, 2 beeps
    % 4) 3 flashes & beeps
    curScan = 2;
    trialType = mod(randperm(nTrials),4) + 1;
    for iTrial = 1:nTrials
        switch trialType(iTrial)
            case 1
                % no middle flash
                twoflashtwobeep(1,round(curScan*dt)) = 1;
            case 2
                % illusory flash
                twoflashthreebeep(1,round(curScan*dt)) = 1;
            case 3
                % suppressed flash
                threeflashtwobeep(1,round(curScan*dt)) = 1;
            case 4
                % veridical flash
                threeflashthreebeep(1,round(curScan*dt)) = 1;
        end
        curScan = curScan + SOAbase + rand*SOAjitter;
    end
    
    % convolve with canonical HRF to get simulated BOLD timecourses.
    [hrf, p] = spm_hrf(TR/dt,[],dt);
    twoflashtwobeep = conv(twoflashtwobeep,hrf,'full');
    twoflashtwobeep = twoflashtwobeep(1:length(time));
    twoflashthreebeep = conv(twoflashthreebeep,hrf,'full');
    twoflashthreebeep = twoflashthreebeep(1:length(time));
    threeflashtwobeep = conv(threeflashtwobeep,hrf,'full');
    threeflashtwobeep = threeflashtwobeep(1:length(time));
    threeflashthreebeep = conv(threeflashthreebeep,hrf,'full');
    threeflashthreebeep = threeflashthreebeep(1:length(time));
    
    if i == 1
    figure;
    plot(time, twoflashtwobeep)
    hold on;
    plot(time, twoflashthreebeep)
    plot(time, threeflashtwobeep)
    plot(time, threeflashthreebeep)
    xlabel('time (scans)')
    end
    
    % subsample to get a simulated response for each TR.
    twoflashtwobeep = twoflashtwobeep(dt/2:dt:end);
    twoflashthreebeep = twoflashthreebeep(dt/2:dt:end);
    threeflashtwobeep = threeflashtwobeep(dt/2:dt:end);
    threeflashthreebeep = threeflashthreebeep(dt/2:dt:end);
    
    % simulate three voxels; one that responds to the middle flash location, 
    % one that responds to the real flashes on the left,
    % and one that doesn't respond to anything.
    groundtruth = zeros(3,4);
    groundtruth(1,:) = [0 0.6 0.3 1];
    groundtruth(2,:) = [1 1 1 1];
    simulatedVoxels = 100 + rand(3,nscans);
    simulatedVoxels(1,:) = simulatedVoxels(1,:) + groundtruth(1,:) * [twoflashtwobeep ; twoflashthreebeep ; threeflashtwobeep ; threeflashthreebeep];
    simulatedVoxels(2,:) = simulatedVoxels(2,:) + groundtruth(2,:) * [twoflashtwobeep ; twoflashthreebeep ; threeflashtwobeep ; threeflashthreebeep];

    % high-pass filter data and regressors
    %disp('Warning: no high-pass filter implemented')
    K = [];
    K.RT = TR;
    K.HParam = 128;
    K.row = 1:nscans;
    simulatedVoxels = (spm_filter(K,simulatedVoxels'))'; % high-pass filter data
    twoflashtwobeep = (spm_filter(K,twoflashtwobeep'))'; % high-pass filter data
    twoflashthreebeep = (spm_filter(K,twoflashthreebeep'))'; % high-pass filter data
    threeflashtwobeep = (spm_filter(K,threeflashtwobeep'))'; % high-pass filter data
    threeflashthreebeep = (spm_filter(K,threeflashthreebeep'))'; % high-pass filter data

%     figure;
%     plot(simulatedVoxels');
    
    % create design matrix.
    %designmatrix = [greenneedle ; brainstorm ; silentscans ; ones(size(greenneedle))];
    designmatrix = [twoflashtwobeep ; twoflashthreebeep ; threeflashtwobeep ; threeflashthreebeep]; % ; silentscans];
    designmatrix = [designmatrix ; ones(size(twoflashtwobeep))]; % add a constant term
%     figure;
%     subplot(1,2,1)
%     plot(designmatrix');
%     subplot(1,2,2)
%     imagesc(corr(designmatrix'));
%     colorbar;

    % estimate betas
    tmpBetas = (pinv(designmatrix') * simulatedVoxels')';
    betas(:,:,i) = tmpBetas(:,1:end-1);
    % calculate T values for betas in a GLM
    % standard error of the model:
    df = size(designmatrix,2) - size(designmatrix,1);
    residuals = simulatedVoxels' - designmatrix' * tmpBetas';
    s = sum(residuals.^2,1) * (1/df);
    % estimated covariance matrix of the coefficients:
    covb = pinv(designmatrix * designmatrix');
    SE = sqrt(diag(covb) * s);
    tmpTs = (tmpBetas' ./ SE)';
    tValues(:,:,i) = tmpTs(:,1:end-1);

    % also get T-values for some contrasts

    % AV rabbit illusion vs. two flash
    contrastVec = zeros(1,size(designmatrix,1));
    contrastVec([1 2]) = [-1 1];
    desVar = contrastVec*covb*contrastVec'; % Define design variance.
    SE = sqrt(desVar * s); % SE is the square root of the design variance times noise
    illusionT(:,i) = (contrastVec*tmpBetas')./SE;
    
end

betas = mean(betas,3);
tValues = mean(tValues,3);
illusionT = mean(illusionT,2);

figure;
subplot(2,3,1)
imagesc(groundtruth);
colorbar;
title('ground truth');
subplot(2,3,2)
imagesc(betas);
colorbar;
title('betas');
subplot(2,3,3)
imagesc(tValues);
colorbar;
title('tvalues');
subplot(2,3,6)
imagesc(illusionT)
colorbar;
title('illusion T');
