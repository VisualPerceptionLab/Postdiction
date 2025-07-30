% This analysis is going to implement the correlation analysis.
% Per participant, extract the contrasts per condition per run. So:
% TO-DO:
% DONE: participant, ROI, condition, run. Save it. 
% ROIs are the 3 flashes, all of V1 within pRF, all of V1.
% Load it. 
% For each participant, for each condition, compute average correlation
% between odd/even and even/odd runs.
% remove nans? might have unequal amount of voxels for correlation?



% close all;
clear all; %close all;
spm = 'D:\spm12';

visStimWidth = 0.28; 
visStimLength = 1.2; 
visStimHorizEcc = 1.42* 1.5;
visStimVertEcc = 4.3;

% ROI 1 - left flash
flash1.xmin = 0 - visStimHorizEcc-(1/2)*visStimWidth;
flash1.xmax = 0 - visStimHorizEcc+(1/2)*visStimWidth;
flash1.ymin = 0 - visStimVertEcc-(1/2)*visStimLength;
flash1.ymax = 0 - visStimVertEcc+(1/2)*visStimLength;
flash1.center = (abs(flash1.xmin) + abs(flash1.xmax))/2;
% ROI 2 - middle flash
flash2.xmin = 0 -(1/2)*visStimWidth;
flash2.xmax = 0 +(1/2)*visStimWidth;
flash2.ymin = 0 - visStimVertEcc-(1/2)*visStimLength;
flash2.ymax = 0 - visStimVertEcc+(1/2)*visStimLength;
flash2.center = (abs(flash2.xmin) + abs(flash2.xmax))/2;
% ROI 3 - right flash
flash3.xmin = 0 + visStimHorizEcc-(1/2)*visStimWidth;
flash3.xmax = 0 + visStimHorizEcc+(1/2)*visStimWidth;
flash3.ymin = 0 - visStimVertEcc-(1/2)*visStimLength;
flash3.ymax = 0 - visStimVertEcc+(1/2)*visStimLength;
flash3.center = (abs(flash3.xmin) + abs(flash3.xmax))/2;
% ROI 4 - top-half visual field flash
control.xmin = 0 -(1/2)*visStimWidth;
control.xmax = 0 +(1/2)*visStimWidth;
control.ymin = 0 + visStimVertEcc-(1/2)*visStimLength;
control.ymax = 0 + visStimVertEcc+(1/2)*visStimLength;
control.center = (abs(control.xmin) + abs(control.xmax))/2;

bullseye.xmin = -0.21;
bullseye.xmax = 0.21;
bullseye.ymin = -0.9;
bullseye.ymax = 0.9;
ROI_boundary = .0;

% Roi_ind: ROI x condition indices
Sigmax = 1.5; %1.42 - (1/2)*visStimWidth; original: 1.5
Sigmin = 0.2;
varexpmin = .1; %change to sigmax 1 and varexpmin .2 original: .1

smoothed_betas = false;
smoothed_prfs = false;
normalize = false;

if smoothed_betas == true
    betasubdir = 'FirstLevelModelBehavsplitSmooth'
else betasubdir = 'FirstLevelModelBehavsplitRun'
end
if smoothed_prfs == true
    prfsubdir = 'MrVistaWarped_motionRegress'
else prfsubdir = 'MrVistaWarped_motionRegress_unsmooth'
end

pRFdir = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\pRF_analysis\pRF_analysis\petkok_analysis_2016_PB\SubjectData';
betadir = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
pRFpostfix = fullfile(prfsubdir, 'Session');
addpath(spm);
allbetaSubjects = [2 3 10 12 14 7 22 15 24 30 31 35 27 42 46 49 56 59 62 63 70 71 50 67];%2,3,10,12, 14]%,12, 14];% 2];
allprfSubjects = {'Subject02','Subject03', 'Subject10', 'Subject12','Subject14','Subject07', 'Subject22', 'Subject15', 'Subject24', 'Subject30', 'Subject31', 'Subject35', 'Subject27', 'Subject42', 'Subject46', 'Subject49',  'Subject56', 'Subject59', 'Subject62', 'Subject63', 'Subject70', 'Subject71', 'Subject50', 'Subject67'};%, 'S15', 'S12', 'S22', 'S14', 'S24'}%, 'S03', 'S10', 'S12', 'S14'}%, 'S02','S03'};
selection = [1:24];
betaSubjects = allbetaSubjects(selection);
prfSubjects = allprfSubjects(selection);
nr_pps = length(prfSubjects);
withinsubject=false;
for iSubj =1:length(betaSubjects)
    
    prfsubj = prfSubjects{iSubj};
    betasubj = sprintf('S%02d', betaSubjects(iSubj));
    disp(betasubj)
    prffullfile = char(fullfile(pRFdir, prfsubj, pRFpostfix, 'x0.nii'));
    Xhead = spm_vol(char(prffullfile));
    Xvol = spm_read_vols(Xhead);
    Yhead = spm_vol(char(fullfile(pRFdir, prfsubj, pRFpostfix, 'y0.nii')));
    Yvol = spm_read_vols(Yhead);
    %Sighead = spm_vol('D:\Documents\MATLAB\PRF\pRF_analysis\pRF_analysis\petkok_analysis_2016\SubjectData\Subject01\MrVistaWarped_motionRegress\Session\x0.nii');
    %Sigvol = spm_read_vols(Sighead);
    Varhead = spm_vol(char(fullfile(pRFdir, prfsubj, pRFpostfix, 'varexp.nii')));
    Varvol = spm_read_vols(Varhead);
    Sighead = spm_vol(char(fullfile(pRFdir, prfsubj, pRFpostfix, 'sigma.nii')));
    Sigvol = spm_read_vols(Sighead);
    
    % Make this the beta per condition, so first four betas
    beta_pattern = fullfile(betadir,betasubj, betasubdir, 'con_*');
    beta_file_list = dir(beta_pattern);
    condition_data = {};
    total_runs = size(beta_file_list);
    for con=1:total_runs
        con_vol = fullfile(beta_file_list(con).folder,beta_file_list(con).name);
        condition = mod(con,5);
        run = ceil(con/5);
        % group niftis per condition and run, remove the averaged niftis.
        if condition > 0
        thisvol = spm_read_vols(spm_vol(con_vol));
        condition_data{condition}{run} = thisvol;
        end
    end
    
    % ROI extraction
    
   for iCond=1:4
       runs_per_cond = size(condition_data{iCond})
       for iRun=1:runs_per_cond
        current_run = condition_data{iCond}{iRun};
        
    % Initialize the struct with the right levels. What ROIs should we use?
    % we can do rest of V1 etc later
%     correlation_data = struct();
%     rROI_names = {'flash1', 'flash2', 'flash3', 'allV1'};
%     % Loop to fill the structure
%     for rROI = 1:size(rROI_names)
%         for pps = 1:nr_pps
%             for cond = 1:4
%                 for run=1:total_runs
%                 % Create a 21-element array within each nested entry
%                 correlation_data.(rROI_names{rROI})(pps).conditions(cond).runs(run).values = [];
%                 end
%             end
%         end
%     end
%     
%     Roi = cell(5, 4);

    brain_rois = {'V1'};
    func_dir_masks = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
    R_hdr = spm_vol(fullfile(func_dir_masks, betasubj, 'Masks', [brain_rois{1} '.nii']));
    R_mask = spm_read_vols(R_hdr);
     R_vect = reshape(R_mask,numel(R_mask),size(R_mask,4));
     disp(sprintf('%s: %d voxels',brain_rois{1},sum(R_vect)));
    
     % extract ROIs
    flash1_logical_idx = R_mask > 0.5 & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    flash2_logical_idx = R_mask > 0.5 & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    flash3_logical_idx = R_mask > 0.5 & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    correlation_data.flash1(iSubj).conditions(iCond).runs{iRun} = current_run(flash1_logical_idx & ~isnan(current_run));
    correlation_data.flash2(iSubj).conditions(iCond).runs{iRun} = current_run(flash2_logical_idx & ~isnan(current_run)); %& ~isnan(Mainvols{1})
    correlation_data.flash3(iSubj).conditions(iCond).runs{iRun} = current_run(flash3_logical_idx & ~isnan(current_run));
    correlation_data.allV1(iSubj).conditions(iCond).runs{iRun} = current_run(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(current_run));
    
    correlation_data.v1minflash(iSubj).conditions(iCond).runs{iRun} = current_run(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~flash1_logical_idx & ~flash2_logical_idx & ~flash3_logical_idx & ~isnan(current_run));
    
    save('D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\Decoding\Pieter','correlation_data')
%     Roi{1,1} = Mainvols{1}(R_mask > 0.5 & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1})); %+ visStimHorizEcc/2 - visStimWidth/2 -
%     Roi{1,2} = Mainvols{2}(R_mask > 0.5 & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}));
%     Roi{1,3} = Mainvols{3}(R_mask > 0.5 & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}));
%     Roi{1,4} = Mainvols{4}(R_mask > 0.5 & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}));
%     %Roi{1,5} = Mainvols{5}(Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + visStimHorizEcc/2 - visStimWidth/2 - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
%     %+ visStimHorizEcc/2 - visStimWidth/2
%     Roi{2,1} = Mainvols{1}(R_mask > 0.5 & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}));   
%     Roi{2,2} = Mainvols{2}(R_mask > 0.5 & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2})); 
%     Roi{2,3} = Mainvols{3}(R_mask > 0.5 & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3})); 
%     Roi{2,4} = Mainvols{4}(R_mask > 0.5 & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4})); 
%     %Roi{2,5} = Mainvols{5}(Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin); 
% 
%     Roi{3,1} = Mainvols{1}(R_mask > 0.5 & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}));
%     Roi{3,2} = Mainvols{2}(R_mask > 0.5 & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}));
%     Roi{3,3} = Mainvols{3}(R_mask > 0.5 & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}));
%     Roi{3,4} = Mainvols{4}(R_mask > 0.5 & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}));
%     %Roi{3,5} = Mainvols{5}(Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
%     
%     Roi{4,1} = Mainvols{1}(R_mask > 0.5 & Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}));
%     Roi{4,2} = Mainvols{2}(R_mask > 0.5 & Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}));
%     Roi{4,3} = Mainvols{3}(R_mask > 0.5 & Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}));
%     Roi{4,4} = Mainvols{4}(R_mask > 0.5 & Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}));
%     %Roi{4,5} = Mainvols{5}(Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
%     
%     Roi{5,1} = Mainvols{1}(R_mask > 0.5 & Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}));
%     Roi{5,2} = Mainvols{2}(R_mask > 0.5 & Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}));
%     Roi{5,3} = Mainvols{3}(R_mask > 0.5 & Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}));
%     Roi{5,4} = Mainvols{4}(R_mask > 0.5 & Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}));
%     
%     ROI1_coord_ind_excl = R_mask > 0.5 & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol  - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol;
%     % visStimHorizEcc/2 + visStimWidth/2   visStimHorizEcc/2 + visStimWidth/2 
%     ROI2_coord_ind_excl = R_mask > 0.5 & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol; 
%     %visStimHorizEcc/2 + visStimWidth/2 
%     ROI3_coord_ind_excl = R_mask > 0.5 & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol;
%     % rest of V1
%     Roi{6,1} = Mainvols{1}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
%     Roi{6,2} = Mainvols{2}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
%     Roi{6,3} = Mainvols{3}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
%     Roi{6,4} = Mainvols{4}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
    
       end
   end
end