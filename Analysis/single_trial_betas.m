clear all; close all;

allSubjects = {'S02', 'S03', 'S07', 'S10', 'S12', 'S14', 'S15', 'S22', 'S24', 'S27', 'S30', 'S31', 'S35', 'S42', 'S46', 'S49','S56','S59','S62', 'S63', 'S70', 'S71', 'S50', 'S67'};
% allIdentifiers = {'MP02499', 'MP02507', 'MP02514', 'MP02515', 'MP02516', 'MP02517', 'MP02518', 'MP02525', 'MP02526', 'MP02527', ...
%     'MP02530', 'MP02531', 'MP02534', 'MP02537', 'MP02538', 'MP02539', 'MP02542', 'MP02543', 'MP02549', 'MP02553', ...
%     'MP02558', 'MP02561', 'MP02569', 'MP02576', 'MP02581', 'MP02585', 'MP02599', 'MP02600', 'MP02602'};

selSubjects = 1:24
% selSubjects = setdiff(selSubjects, [4 17 18 23 25])

subjects = allSubjects(selSubjects);
% identifiers = allIdentifiers(selSubjects);

% Find out which operating system we're running on
if ispc
    % set the root dir of the experiment
    
    rootDir = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations';
   % rootDir = 'C:\Users\pkok\Dropbox\WellcomeCentre\Projects\Learning_predictions_fMRI\Methods\Analysis\Analysis_scripts_PK';
    if ~exist(rootDir,'dir')
        fprintf('Root directory does not exist!\n%s\n',rootDir)
    end
    
    % set the path to the behavioural results (on Dropbox)
    %behSourceDir = '/Users/fa28/Dropbox/Learning_predictions_fMRI/Behavioural_data';
     behSourceDir = 'D:\Documents\PhD_project\postdiction_AV_fMRI\data_collection\Data';
   % behSourceDir = 'C:\Users\pkok\Dropbox\WellcomeCentre\Projects\Learning_predictions_fMRI\Behavioural_data';
    if ~exist(behSourceDir,'dir')
        fprintf('Behavioural results directory does not exist!\n%s\n',behSourceDir)
    end
    
    % set the path to SPM
    spmDir= 'D:\spm12';
    %spmDir = 'C:\spm12';
    addpath(spmDir)
elseif isunix 
    % set the root dir of the experiment
end

ROIs = {'V1'};
% nVox = [500, Inf]
roiCrossVal = [false, true]

% load SPM basis functions from localiser model; convenient.
SPMmatFile = fullfile(rootDir,'Subject_data', 'S02', 'FirstLevelModelBehavsplitTD','SPM.mat');
load(SPMmatFile);
xBF = SPM.xBF;
clear SPM
%disp('Warning: haven''t cleared SPM variable')
% hack it so that only the canonical HRF is used
%xBF.order = 1;
%xBF.bf = xBF.bf(:,1);

TR = 3.264;
convertToPerc = true

% PB: do we use this?
% height of regressors, for perc signal chance calculations
canonHeight = 0.0133;
tdHeight = 0.0047;

%% group some trial positions together, to boost signal to noise?
trialsPerBin = 6
nBins = 32 - trialsPerBin + 1;
% actualNVox = zeros(length(subjects),length(ROIs));
% presentedShapeEvidence = zeros(length(subjects),length(ROIs),nBins);
% predictedShapeEvidence = zeros(length(subjects),length(ROIs),nBins);
% validShapeEvidence = zeros(length(subjects),length(ROIs),nBins);
% invalidShapeEvidence = zeros(length(subjects),length(ROIs),nBins);
% presentedShapeAmplitude = zeros(length(subjects),length(ROIs),nBins);
% predictedShapeAmplitude = zeros(length(subjects),length(ROIs),nBins);
% validShapeAmplitude = zeros(length(subjects),length(ROIs),nBins);
% invalidShapeAmplitude = zeros(length(subjects),length(ROIs),nBins);
% if xBF.order == 2
%     presentedShapeAmplitudeTD = zeros(length(subjects),length(ROIs),nBins);
%     predictedShapeAmplitudeTD = zeros(length(subjects),length(ROIs),nBins);
%     validShapeAmplitudeTD = zeros(length(subjects),length(ROIs),nBins);
%     invalidShapeAmplitudeTD = zeros(length(subjects),length(ROIs),nBins);
% end
for iSubj = 1:length(subjects)
    
    fprintf('Subject %d / %d\n',iSubj,length(subjects))
    
    %% load behavioural data
    behaviourDirectory = fullfile(behSourceDir,subjects{iSubj}); %, 'FirstLevelModelBehavsplitTD'
    behMatrices = loadBehData(behaviourDirectory);
%     dirBeh = dir(fullfile(behaviourDirectory, 'cond*'));
%     for iBeh=1:length(dirBeh)
%         behfile = fullfile(dirBeh(iBeh).folder, dirBeh(iBeh).name)
%         behMatrices(iBeh) = load(behfile)
%     end
    %% load head motion parameters
    EPIfolders = dir(fullfile(rootDir,subjects{iSubj},'cmrr*'));
    RP = cell(1,length(EPIfolders));
    for iFolder = 1:length(EPIfolders)
        Rfile = spm_select('FPList',fullfile(EPIfolders(iFolder).folder, EPIfolders(iFolder).name,'^rp_extended'));
%         Rfile = fullfile(EPIfolders(iFolder).folder,EPIfolders(iFolder).name,'rp_extended.mat');
        load(Rfile)
        RP{iFolder} = R;
    end
    
    % load ROI data
    % PB: how does this data structure work? why does it contain betas and
    % ... T contrasts or something?
    ROIdataFolder = fullfile(rootDir, subjects{iSubj},'ROIdata');
    for iROI = 1:length(ROIs)
     
        ROIdataFile = fullfile(ROIdataFolder,sprintf('%s_data.mat',ROIs{iROI}));
        load(ROIdataFile, 'EPIdata'); %, 'SPMTdata', 'betaData'
        
%         if nVox(iROI) < Inf
% %             [val, sortedVox] = sort(SPMTdata,'descend');
% %             SPMTdata = SPMTdata(sortedVox(1:nVox(iROI)));
% %             betaData = betaData(sortedVox(1:nVox(iROI)),:);
%             for i = 1:length(EPIdata)
%                 EPIdata{i} = EPIdata{i}(sortedVox(1:nVox(iROI)),:);
%             end
%         end

% estimate single trial regressors for prediction runs
        % PB: 512? Trials?
%         predTrialBetas = zeros(length(SPMTdata),512);
        predTrialInfo = [];
%         if xBF.order == 2 ; predTrialBetasTD = zeros(length(SPMTdata),512); end
        for iRun = 1:4
            nScans = size(EPIdata{iRun},2);
            timecourse_upSamp = zeros(1,nScans * (1/xBF.dt));
            % PB: which pp has 3 runs?
%             if strcmp(subjects{iSubj},'S00')
%                 % some scans missing for some runs..
%                 timecourse_upSamp = zeros(1,(nScans+100) * (1/xBF.dt));
%             end
            
            % create a regressor for every trial
            nTrials = size(behMatrices{iRun},1);
            designMatrix_upSamp = [];
            for iTrial = 1:nTrials
                % create stick functions
                stickRegressor = timecourse_upSamp;
                onset = round(behMatrices{iRun}(iTrial,1) * (1/xBF.dt) - (0.5*TR/xBF.dt)); % subtract half a TR
                stickRegressor(onset) = 1;
                
                 % convolve with basis functions
                for iBF = 1:xBF.order
                    regressor = conv(stickRegressor,xBF.bf(:,iBF));
                    %figure; plot(regressor)
                    designMatrix_upSamp = [designMatrix_upSamp regressor'];
                end
            end
            trialRegressors = designMatrix_upSamp(1:(1/xBF.dt):(nScans*(1/xBF.dt)),:);
            if xBF.order == 2
                trialRegressors = [trialRegressors(:,1:2:end) trialRegressors(:,2:2:end)]; % split canonical and td regressors
            end
            % PB: ?
            % now do ls-s style models for trials 1-32
            for selTrial = 1:32
                designMatrix = [];
                trialInds = find(behMatrices{iRun}(:,5) == selTrial);
                for i = 1:length(trialInds)
                    designMatrix = [designMatrix trialRegressors(:,trialInds(i))]; 
                end
                if xBF.order == 2
                    % add  TD regressors
                    for i = 1:length(trialInds)
                        designMatrix = [designMatrix trialRegressors(:,trialInds(i) + nTrials)];
                    end
                end
                % now create regressors for the other trials
                otherTrialInds = find(behMatrices{iRun}(:,5) ~= selTrial);
                designMatrix = [designMatrix sum(trialRegressors(:,otherTrialInds),2)];
                if xBF.order == 2
                    designMatrix = [designMatrix sum(trialRegressors(:,otherTrialInds + nTrials),2)];
                end
                
                % append head motion parameters
                designMatrix = [designMatrix RP{iRun}];
                
                % high-pass filter data and design matrix
                %disp('Warning: no high-pass filter implemented')
                K = [];
                K.RT = TR;
                % PB: do we need high pass?
                K.HParam = 128;
                K.row = 1:nScans;
                Y = EPIdata{iRun}';
                Y = spm_filter(K,Y); % high-pass filter data
                designMatrix = spm_filter(K,designMatrix); % high-pass filter design matrix
                
                % add constant to design matrix
                designMatrix = [designMatrix ones(nScans,1)];
                
                % estimate betas
                betas = pinv(designMatrix) * Y;
                % now sort these betas into a convenient variable.
                predTrialBetas(:,trialInds + (iRun-2)*128) = betas(1:length(trialInds),:)';
                if xBF.order == 2
                    predTrialBetasTD(:,trialInds + (iRun-2)*128) = betas((1:length(trialInds)) + length(trialInds),:)';
                end
            end
            predTrialInfo = [predTrialInfo ; behMatrices{iRun}];
        end
    end
end