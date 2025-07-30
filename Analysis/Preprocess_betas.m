clear all; close all;

allSubjects = {'S02', 'S03', 'S07', 'S10', 'S12', 'S14', 'S15', 'S22', 'S24', 'S27', 'S30', 'S31', 'S35', 'S42', 'S46', 'S49','S56','S59','S62', 'S63', 'S70', 'S71', 'S50', 'S67'};

% allIdentifiers = {'MQ05740', 'MQ05747', 'MQ05751', 'MQ05759', 'MQ05761', 'MQ05773', 'MQ05819', 'MQ05824', 'MQ05833', 'MQ05839', 'MQ05840', ...
%     'MQ05847', 'MQ05848', 'MQ05850', 'MQ05851', 'MQ05857', 'MQ05867', 'MQ05868', 'MQ05876', 'MQ05877', 'MQ05880', ...
%     'MQ05886', 'MQ05887', 'MQ05890', 'MQ05891', 'MQ05895', 'MQ05913', 'MQ05921', 'MQ05939', 'MQ05954', 'MQ05956', 'MQ05968'};
% 
% selSubjects = [0 1 3 4 5 8 9 10 11 13 15 16 17 19 22 23 24 25 26 27 28 29 30 31]+1; % doing the +1 to skip S90.

selSubjects = [1:17 19:24];

% allSubjects = {'S06_sess1'};
% allIdentifiers = {'MQ05819'};
% selSubjects = 1

% allSubjects = {'S06_sess2'};
% allIdentifiers = {'MQ05826'};
% selSubjects = 1

% note, for S01, T2 scan was done in a separate session; MQ05752.

% For S06, the last two functional runs were done in a separate
% session: MQ05826
% realign and unwarp failed, probably because the head position was so
% different in the two sessions. It turns out we can't correct fully for
% the difference in distortions in the two sessions, so this participant
% should be excluded.

% Exclude S07? Probably too much head motion. They also did poorly at the
% task; 40-50% missed responses and 50-60% accuracy on remaining trials.

% S10's firstlevel T maps look pretty crappy. Not sure why, movement is
% good, except that they closed their eyes quite a lot during (part of) the
% experiment. Exclude?

% S18 will probably have to be excluded; so much head motion between runs
% that the distortions are very different (and we did not collect new
% fieldmaps).

subjects = allSubjects(selSubjects);
% identifiers = allIdentifiers(selSubjects);

% Find out which operating system we're running on
if ispc
    % set the root dir of the experiment
    
    rootDir = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
   % rootDir = 'C:\Users\pkok\Dropbox\WellcomeCentre\Projects\Learning_predictions_fMRI\Methods\Analysis\Analysis_scripts_PK';
    if ~exist(rootDir,'dir')
        fprintf('Root directory does not exist!\n%s\n',rootDir)
    end
    
    % set the path to the behavioural results (on Dropbox)
    %behSourceDir = '/Users/fa28/Dropbox/Learning_predictions_fMRI/Behavioural_data';
     behSourceDir = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
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


%% write code that extracts EPI data for selected ROIs.
extractTimecourses = true
if extractTimecourses
    disp('Extracting timecourses.')
%     ROIs = {'V1', 'V2', 'LateralOccipital_FS', 'Caudate_FS', 'Putamen_FS', 'Hippocampus', 'CA1', 'CA23', 'DGCA4', 'CA234DG', 'SUB', 'ERC', 'PRC', 'PHC'};
%     ROIs = [ROIs {'Hippocampus_ant', 'CA1_ant', 'CA23_ant', 'DGCA4_ant', 'CA234DG_ant', 'SUB_ant', ...
%         'Hippocampus_post', 'CA1_post', 'CA23_post', 'DGCA4_post', 'CA234DG_post', 'SUB_post', ...
%         'lh.Hippocampus', 'lh.CA1', 'lh.CA23', 'lh.DGCA4', 'lh.CA234DG', 'lh.SUB', ...
%         'rh.Hippocampus', 'rh.CA1', 'rh.CA23', 'rh.DGCA4', 'rh.CA234DG', 'rh.SUB'}];
    ROIs = {'V1'};
    for iSubj = 1:length(subjects)
        fprintf('Subject %d / %d\n',iSubj,length(subjects));
        ROIfolder = fullfile(rootDir,subjects{iSubj},'Masks');
        ROIdataFolder = fullfile(rootDir, subjects{iSubj},'ROIdata');
        if ~exist(ROIdataFolder,'dir')
            mkdir(ROIdataFolder);
        end
        % find EPI folders
        EPIfiles = dir(fullfile(rootDir,subjects{iSubj},'Niftis', 'Realigned', 'rNORDIC*.nii'));
%         if length(EPIfolders) ~= 6
%             fprintf('\nWarning: I expected to find 6 EPI folders but I found %d.\n',length(EPIfolders));
%         end
        ROIdata = cell(length(EPIfiles),length(ROIs));
        % load EPI data and pass through ROI masks
        runs = 4;
        for iFile = 1:1
            fprintf('Run %d / %d\n',iFile,length(EPIfiles));
            % input EPIs
            EPIfile = spm_select('FPList',fullfile(EPIfiles(iFile).folder, EPIfiles(iFile).name), 'r');%,'^uf.*\.nii$'
            EPIfile = EPIfile(1,1:end-21);
            EPIheader = spm_vol(EPIfile);
            EPIdata = spm_read_vols(EPIheader);
            nVox = numel(EPIdata(:,:,:,1));
            nScans = size(EPIdata,4);
            EPIdata = reshape(EPIdata,nVox,nScans); % reshape 4D matrix to 2D (nVox x nScans)
            for iROI = 1:length(ROIs)
                ROIfile = fullfile(ROIfolder,sprintf('%s.nii',ROIs{iROI})); %.gz
                ROIheader = spm_vol(ROIfile);
                ROImask = spm_read_vols(ROIheader);
                ROImask = reshape(ROImask,nVox,1);
                
                ROIdata{iFile,iROI} = EPIdata(ROImask >= 1,:);
            end
            clear EPIdata
        end
%         % also pass SPMT and beta maps from localiser analysis through ROIs
%         SPMTfile = fullfile(rootDir,subjects{iSubj},'firstlevel','localiser_1deriv','spmT_0001.nii');
%         SPMTheader = spm_vol(SPMTfile);
%         SPMTdata = spm_read_vols(SPMTheader);
%         SPMTdata = reshape(SPMTdata,nVox,1);
%         betaInds = [1:2:9 29:2:37];
%         betaData = zeros(numel(SPMTdata),length(betaInds));
%         for iBeta = 1:length(betaInds)
%             betaFile = fullfile(rootDir,'fMRI',subjects{iSubj},'firstlevel','localiser_1deriv',sprintf('beta_%04g.nii',betaInds(iBeta)));
%             betaHeader = spm_vol(betaFile);
%             tmp = spm_read_vols(betaHeader);
%             betaData(:,iBeta) = reshape(tmp,nVox,1);
%         end
%         SPMT_ROIdata = cell(1,length(ROIs));
%         beta_ROIdata = cell(1,length(ROIs));
%         for iROI = 1:length(ROIs)
%             ROIfile = fullfile(ROIfolder,sprintf('%s.nii',ROIs{iROI})); %.gz
%             ROIheader = spm_vol(ROIfile);
%             ROImask = spm_read_vols(ROIheader);
%             ROImask = reshape(ROImask,nVox,1);
%             
%             SPMT_ROIdata{iROI} = SPMTdata(ROImask >= 1,:);
%             beta_ROIdata{iROI} = betaData(ROImask >= 1,:);
%         end
            
        % save ROI data
        for iROI = 1:length(ROIs)
            ROIdataFile = fullfile(ROIdataFolder,sprintf('%s_data.mat',ROIs{iROI}));
            EPIdata = ROIdata(:,iROI);
%             SPMTdata = SPMT_ROIdata{iROI};
%             betaData = beta_ROIdata{iROI};
            % bit of a hack; for visual cortex, only save the 1000 most
            % active voxels.
%             if strcmp(ROIs{iROI},'V1') || strcmp(ROIs{iROI},'V2') || strcmp(ROIs{iROI},'LateralOccipital_FS')
% %                 [val, ind] = sort(SPMTdata,'descend');
%                 
%                 for i = 1:length(EPIdata)
%                    EPIdata{i} = EPIdata{i}(selVox,:);
%                 end
% %                 SPMTdata = SPMTdata(selVox);
% %                 betaData = betaData(selVox,:);
%             end
            save(ROIdataFile, 'EPIdata');%, 'SPMTdata', 'betaData');
        end
    end
end

