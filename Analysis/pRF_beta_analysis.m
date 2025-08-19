% close all;
clear all; close all;
spm = 'D:\spm12';

smoothed_betas = false;
smoothed_prfs = false;
normalize = false;
if smoothed_betas == true
    betasubdir = 'FirstLevelModelBehavsplitSmooth'
else betasubdir = 'FirstLevelModelBehavsplitTD'
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
selection = [1:6 8:24];
betaSubjects = allbetaSubjects(selection);
prfSubjects = allprfSubjects(selection);
nr_pps = length(prfSubjects);
withinsubject=false;
for iSubj =1:length(betaSubjects)
    prfsubj = prfSubjects{iSubj};
    betasubj = sprintf('S%02d', betaSubjects(iSubj));
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
    
    Mainhead1 = spm_vol(char(fullfile(betadir, betasubj, betasubdir,'con_0001.nii')));
    Mainhead2 = spm_vol(char(fullfile(betadir, betasubj, betasubdir,'con_0002.nii')));
    % hacky solution for S59
    Mainhead3 = spm_vol(char(fullfile(betadir, betasubj, betasubdir,'con_0003.nii')));
    Mainhead4 = spm_vol(char(fullfile(betadir, betasubj, betasubdir,'con_0004.nii')));
    %Mainhead7 = spm_vol(char(fullfile(betadir, betasubj, betasubdir,'con_0007.nii')));
    
    % prepare layers




    Mainvols = {spm_read_vols(Mainhead1), spm_read_vols(Mainhead2), spm_read_vols(Mainhead3), spm_read_vols(Mainhead4)};%, spm_read_vols(Mainhead7)};
    contrasts = length(Mainvols);
    visStimWidth = 0.28; 
    visStimLength = 1.2; 
    visStimHorizEcc = 1.42* 1.5;
    visStimVertEcc = 4.3;
    individual_var_mult = 4;
    % ROI 1 - left flash
    flash1.xmin = 0 - visStimHorizEcc-(1/2)*visStimWidth;
    flash1.xmax = 0 - visStimHorizEcc+(1/2)*visStimWidth;
    flash1.ymin = 0 - visStimVertEcc-(1/2)*visStimLength;
    flash1.ymax = 0 - visStimVertEcc+(1/2)*visStimLength;
    flash1.center = (abs(flash1.xmin) + abs(flash1.xmax))/2;
    % ROI 2 - middle flash
    flash2.xmin = 0 -(1/2)*visStimWidth * individual_var_mult;
    flash2.xmax = 0 +(1/2)*visStimWidth * individual_var_mult;
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
    Sigmax = 1.3; %1.42 - (1/2)*visStimWidth; original: 1.5
    Sigmin = 0.1;
    varexpmin = .1; %change to sigmax 1 and varexpmin .2 original: .1
    Roi = cell(5, 4);

    brain_rois = {'V1'};
    func_dir_masks = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
    R_hdr = spm_vol(fullfile(func_dir_masks, betasubj, 'Masks', [brain_rois{1} '.nii']));
    R_mask = spm_read_vols(R_hdr);
     R_vect = reshape(R_mask,numel(R_mask),size(R_mask,4));
     disp(sprintf('%s: %d voxels',brain_rois{1},sum(R_vect)));

    func_dirHC= 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
    ROI_HC = {'STS'};
    R_hdrHC = spm_vol(fullfile(func_dirHC, betasubj, 'hires_synth_noskull','mri', [ROI_HC{1} '.nii.gz']));
    R_maskHC = spm_read_vols(R_hdrHC);
    R_vectHC = reshape(R_maskHC,numel(R_maskHC),size(R_maskHC,4));
    disp(sprintf('%s: %d voxels',ROI_HC{1},sum(R_vectHC)));
    %Sigvol=0.01;
    % select a subset of voxels, based on some criteria
%     sel_indx = find(R_mask > 0.5);
    %size_mask = size(R_mask)
    %rs_sel_indx = reshape(sel_indx, size_mask)
%     disp(sprintf('Selected: %d voxels',length(sel_indx)));
    %nvox = length(sel_indx)
    % convert 1D list of voxel indices to 4D list of 3D
    % voxel coordinates
%     sel_coords = zeros(3,length(sel_indx));
%     [sel_coords(1,:), sel_coords(2,:), sel_coords(3,:)] = ind2sub(size(Mainvols{1}),sel_indx);
%% mean subtraction
%     clear allvols
%     allvols(1,:,:,:) = Mainvols{1};   
%     allvols(2,:,:,:) = Mainvols{2};
%     allvols(3,:,:,:) = Mainvols{3};
%     allvols(4,:,:,:) = Mainvols{4};
%     meanconditions = squeeze(mean(allvols, 1));
%     Mainvols{1} = Mainvols{1} - meanconditions;
%     Mainvols{2} = Mainvols{2} - meanconditions;
%     Mainvols{3} = Mainvols{3} - meanconditions;
%     Mainvols{4} = Mainvols{4} - meanconditions;
    % flash 1
    %R_maskV2 > V2_thres | 
    ROI1_coord_ind = (R_mask > 0.5) & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    ROI2_coord_ind = (R_mask > 0.5) & Xvol>= flash2.xmin + ROI_boundary & Xvol<= flash2.xmax - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    ROI3_coord_ind = (R_mask > 0.5) & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    % Remove elements from ROI2_coord_ind that are present in ROI3_coord_ind
ROI2_coord_ind = ROI2_coord_ind & ~ROI3_coord_ind;

% Remove elements from ROI2_coord_ind that are present in ROI1_coord_ind
ROI2_coord_ind = ROI2_coord_ind & ~ROI1_coord_ind;
    contr_coord_ind = (R_mask > 0.5) & Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    bullseye_coord_ind = (R_mask > 0.5) & Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
    Roi{1,1} = Mainvols{1}(ROI1_coord_ind & ~isnan(Mainvols{1})); %+ visStimHorizEcc/2 - visStimWidth/2 -
    Roi{1,2} = Mainvols{2}(ROI1_coord_ind & ~isnan(Mainvols{2}));
    Roi{1,3} = Mainvols{3}(ROI1_coord_ind & ~isnan(Mainvols{3}));
    Roi{1,4} = Mainvols{4}(ROI1_coord_ind & ~isnan(Mainvols{4}));
    %Roi{1,5} = Mainvols{5}(Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + visStimHorizEcc/2 - visStimWidth/2 - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    %+ visStimHorizEcc/2 - visStimWidth/2
    Roi{2,1} = Mainvols{1}(ROI2_coord_ind & ~isnan(Mainvols{1}));   
    Roi{2,2} = Mainvols{2}(ROI2_coord_ind & ~isnan(Mainvols{2})); 
    Roi{2,3} = Mainvols{3}(ROI2_coord_ind & ~isnan(Mainvols{3})); 
    Roi{2,4} = Mainvols{4}(ROI2_coord_ind & ~isnan(Mainvols{4})); 
    %Roi{2,5} = Mainvols{5}(Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin); 

    Roi{3,1} = Mainvols{1}(ROI3_coord_ind & ~isnan(Mainvols{1}));
    Roi{3,2} = Mainvols{2}(ROI3_coord_ind & ~isnan(Mainvols{2}));
    Roi{3,3} = Mainvols{3}(ROI3_coord_ind & ~isnan(Mainvols{3}));
    Roi{3,4} = Mainvols{4}(ROI3_coord_ind & ~isnan(Mainvols{4}));
    %Roi{3,5} = Mainvols{5}(Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    Roi{4,1} = Mainvols{1}(contr_coord_ind & ~isnan(Mainvols{1}));
    Roi{4,2} = Mainvols{2}(contr_coord_ind & ~isnan(Mainvols{2}));
    Roi{4,3} = Mainvols{3}(contr_coord_ind & ~isnan(Mainvols{3}));
    Roi{4,4} = Mainvols{4}(contr_coord_ind & ~isnan(Mainvols{4}));
    %Roi{4,5} = Mainvols{5}(Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    Roi{5,1} = Mainvols{1}(bullseye_coord_ind & ~isnan(Mainvols{1}));
    Roi{5,2} = Mainvols{2}(bullseye_coord_ind & ~isnan(Mainvols{2}));
    Roi{5,3} = Mainvols{3}(bullseye_coord_ind & ~isnan(Mainvols{3}));
    Roi{5,4} = Mainvols{4}(bullseye_coord_ind & ~isnan(Mainvols{4}));
    
    ROI1_coord_ind_excl = R_mask > 0.5 & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol  - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol;
    % visStimHorizEcc/2 + visStimWidth/2   visStimHorizEcc/2 + visStimWidth/2 
    ROI2_coord_ind_excl = R_mask > 0.5 & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol; 
    %visStimHorizEcc/2 + visStimWidth/2 
    ROI3_coord_ind_excl = R_mask > 0.5 & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol;
    % rest of V1
%     Roi{6,1} = Mainvols{1}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}) & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind);
%     Roi{6,2} = Mainvols{2}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}) & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind);
%     Roi{6,3} = Mainvols{3}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}) & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind);
%     Roi{6,4} = Mainvols{4}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}) & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind);
    Roi{5,1} = Mainvols{1}(R_maskHC > 0.5 & ~isnan(Mainvols{1}));
    Roi{5,2} = Mainvols{2}(R_maskHC > 0.5 & ~isnan(Mainvols{2}));
    Roi{5,3} = Mainvols{3}(R_maskHC > 0.5 & ~isnan(Mainvols{3}));
    Roi{5,4} = Mainvols{4}(R_maskHC > 0.5 & ~isnan(Mainvols{4}));

    
    % Test hypothesis whether voxels with higher eccentricity have higher
    % betas

    % Extract betas in flash 2
    AV_betas = Roi{2,4};
    ver2_betas = Roi{2,1};

    % Extract associated x and sigma
    AV_x = Xvol(ROI2_coord_ind & ~isnan(Mainvols{4}));
    ver2_x = Xvol(ROI2_coord_ind & ~isnan(Mainvols{1}));
    AV_sig = Sigvol(ROI2_coord_ind & ~isnan(Mainvols{4}));
    ver2_sig = Sigvol(ROI2_coord_ind & ~isnan(Mainvols{1}));

    % Does a lower x mean a higher beta?
    AV_precision = corr(AV_betas, abs(AV_x));
    ver2_precision= corr(ver2_betas, abs(ver2_x));
    
    AV_topdown= corr(AV_betas,abs(AV_sig));
    ver2_topdown = corr(ver2_betas, abs(ver2_sig));
    
    precision_hyp(iSubj,:) = [ver2_precision, AV_precision];
    topdown_hyp(iSubj,:) = [AV_topdown, ver2_topdown];


    
    subject_pRF_betas{iSubj} = Roi;
%     disp(prfsubj)
%     disp(size(Roi{2,2}))

    if smoothed_prfs
        prftext = 'smooth prf';
    else prftext = 'unsmooth prf';
    end
    if smoothed_betas
        betatext = 'smooth betas, ';
    else betatext = 'unsmooth betas, ';
    end
    



    if withinsubject


    ROI1_coord_ind = find(Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol  - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    % visStimHorizEcc/2 + visStimWidth/2   visStimHorizEcc/2 + visStimWidth/2 
%     ROI2_coord_ind = find(Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin); 
    %visStimHorizEcc/2 + visStimWidth/2 
    ROI3_coord_ind = find(Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    ROI4_coord_ind = find(Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    ROI5_coord_ind = find(Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    % Create a scatter plot
    figure;
    %scatter(X, Y, 'DisplayName', 'Dataset 1', 'Marker', 'o');
    %scatter(Xvol(:,:), Yvol(:,:), 2, 'filled');
    hold on;
    RGB_cont = [170 170 170]/256 ;
    RGB_flash = [100 100 100]/256 ;
    RGB_ill = [20 20 20]/256 ;
%     scatter(Xvol(ROI1_coord_ind), Yvol(ROI1_coord_ind), [], RGB_flash, 'DisplayName', 'Dataset 1','Marker', 'square')
    scatter(Xvol(ROI2_coord_ind), Yvol(ROI2_coord_ind), [], RGB_ill, 'DisplayName', 'Dataset 2','Marker', '*')
%     scatter(Xvol(ROI3_coord_ind), Yvol(ROI3_coord_ind), [], RGB_flash, 'DisplayName', 'Dataset 3', 'Marker', 'square')
%     scatter(Xvol(ROI4_coord_ind), Yvol(ROI4_coord_ind), [], RGB_cont, 'DisplayName', 'Dataset 4', 'Marker', 'x')
%     scatter(Xvol(ROI5_coord_ind), Yvol(ROI5_coord_ind), [], RGB_cont, 'DisplayName', 'Dataset 5', 'Marker', 'o')
    %scatter(Xvol(ROI6_coord_ind), Yvol(ROI6_coord_ind), 'DisplayName', 'Dataset 5', 'Marker', 'o');
    xlim([-5.5 5.5]);
    ylim([-5.5 5.5]);
    xlabel('degrees');
    ylabel('degrees');
    % Customize plot appearance
    title('Voxels per ROI');
    hold off;

        % Create a barplot for each condition, where the betas per ROI are
        % displayed.
        conditions = contrasts;
        ROI_nr = length(Roi);
        plotmeans = cell(ROI_nr,conditions);
        ploterrors = cell(ROI_nr,conditions);
        for cond=1:conditions
            % ROI(roi,cond)
            ROI1_mean = nanmean(Roi{1,cond});
            ROI2_mean = nanmean(Roi{2,cond});
            ROI3_mean = nanmean(Roi{3,cond});
            ROI4_mean = nanmean(Roi{4,cond});
            ROI5_mean = nanmean(Roi{5,cond});
            
            ROI1_ste = nanstd(Roi{1,cond}) / sqrt(length(Roi{1,cond}(~isnan(Roi{1,cond}))));
            ROI2_ste = nanstd(Roi{2,cond}) / sqrt(length(Roi{2,cond}(~isnan(Roi{2,cond}))));
            ROI3_ste = nanstd(Roi{3,cond}) / sqrt(length(Roi{3,cond}(~isnan(Roi{3,cond}))));
            ROI4_ste = nanstd(Roi{4,cond}) / sqrt(length(Roi{4,cond}(~isnan(Roi{4,cond}))));
            ROI5_ste = nanstd(Roi{5,cond}) / sqrt(length(Roi{5,cond}(~isnan(Roi{5,cond}))));
            plotmeans(:,cond) = {ROI1_mean, ROI2_mean, ROI3_mean, ROI4_mean, ROI5_mean};
            ploterrors(:,cond) = {ROI1_ste, ROI2_ste, ROI3_ste, ROI4_ste, ROI5_ste};
        end

         figure;
    
        % Create a subplot in the 4x4 grid
        
        % Plot a bar chart for the corresponding data
        bar(cell2mat(plotmeans));
        hold on;
        for cond = 1:conditions
            x = (1:ROI_nr) - .48 + cond*0.19;  % Adjust x-coordinates for each set of bars
            errorbar(x, cell2mat(plotmeans(:,cond)), cell2mat(ploterrors(:,cond)), '.', 'LineWidth', 1.5);
        end
        hold off;
        

        title([num2str(betaSubjects(iSubj)),' betas, ', prftext, betatext]);
        xlabel('ROIs');
        ylabel('Beta');
        legend('C1', 'C2', 'C3', 'C4');
        %set(gca, 'xticklabel', categories); % Set x-axis labels
        hold off; % Release the hold
        grid on;

    end
end

[h1,p1,t1]=ttest(precision_hyp(:,1),precision_hyp(:,2), 'tail','right');
disp(['The p-value for more precise real activity is: ', num2str(p1)])
[h2,p2,t2]=ttest(topdown_hyp(:,1),topdown_hyp(:,2), 'tail','right');
disp(['The p-value for higher real activity with ecc: ', num2str(p2)])
%%
if ~withinsubject
        % Create a barplot for each condition, where the betas per ROI are
    % displayed.
    conditions = contrasts;
    ROI_nr = 5;%length(Roi);
    ppmeans = zeros(ROI_nr,conditions);
    ploterrors = zeros(ROI_nr,conditions);
    group_data_means = zeros(nr_pps,ROI_nr,contrasts);
    plotmeans = zeros(ROI_nr, conditions);
    for pp=1:nr_pps
        Roi = subject_pRF_betas{pp};
        for cond=1:conditions
            % ROI(roi,cond)
            ROI1_mean = nanmean(Roi{1,cond});
            ROI2_mean = nanmean(Roi{2,cond});
            ROI3_mean = nanmean(Roi{3,cond});
            ROI4_mean = nanmean(Roi{4,cond});
            ROI5_mean = nanmean(Roi{5,cond});     
            ppmeans(:,cond) = [ROI1_mean, ROI2_mean, ROI3_mean, ROI4_mean, ROI5_mean];
        end
        % divide by total to get normalized power
       if normalize == true
           ppmeans = ppmeans/sum(nansum(ppmeans));
       end
        group_data_means(pp,:,:) = ppmeans;
        % problem 1: how to add nans as zeroes
        % problem 2: how to ensure not divided by pps that have nan ROIs
        ppmeans(isnan(ppmeans)) = 0;
        plotmeans = plotmeans + ppmeans/nr_pps;
    
%         ploterrors(:,cond) = {ROI1_ste, ROI2_ste, ROI3_ste, ROI4_ste, ROI5_ste};

    end
    %group_data_means_cat = cat(3, group_data_means{:});
    for row=1:ROI_nr
        for column=1:conditions
            ploterrors(row,column) = nanstd(group_data_means(:,row,column)) / sqrt(length(group_data_means));%(~isnan(group_data_means_cat(row,column,:)
        end
    end
    
    % stats
    ROI2_cond1_betas = group_data_means(:,2,1);
    ROI2_cond2_betas = group_data_means(:,2,2);
    ROI2_cond3_betas = group_data_means(:,2,3);
    ROI2_cond4_betas = group_data_means(:,2,4);

    cond4ROI2 =group_data_means(:,2,4);%[group_data_means(:,1,4);group_data_means(:,2,4); group_data_means(:,3,4)];
    cond1ROI2 =group_data_means(:,2,1);%[group_data_means(:,1,2);group_data_means(:,2,2); group_data_means(:,3,2)];
    cond3ROI2 =group_data_means(:,3,1);
    ROI4_mean = nanmean(group_data_means(:,4,:),3);
    ROI3_mean = nanmean(group_data_means(:,3,:),3);
    ROI1_mean = nanmean(group_data_means(:,1,:),3);
    control_mean = mean([ROI3_mean, ROI1_mean],2);
    % successful illusions
%     ROI2_cond5_betas = group_data_means(:,2,5)
    [h,p_ill,ci,stats] = ttest(cond4ROI2, cond1ROI2, Tail='right');
    [h,p_ver2,ci,stats] = ttest(cond4ROI2, cond1ROI2, Tail='right');
    [h,p_control,ci,stats] = ttest(ROI4_mean, control_mean, Tail='left');
    [h,p_mask,ci,stats] = ttest(cond4ROI2, cond3ROI2, Tail='left');
%     [h,p_control_1,ci,stats] = ttest(ROI4_mean, ROI1_mean, Tail='left')

%     mean(group_data_means(:,2,1))
%     mean(group_data_means(:,2,2))
%     std(group_data_means(:,2,1))
%     std(group_data_means(:,2,2))
%     std(group_data_means(:,2,3))
%     std(group_data_means(:,2,4))
    
    % Create a figure
figure;
hold on;

% % Plot density for Normal distribution
% [f_normal, xi_normal] = ksdensity(group_data_means(:,2,1));
% plot(xi_normal, f_normal, 'r', 'LineWidth', 1.5, 'DisplayName', 'Ver2');
% 
% % Plot density for Uniform distribution
% [f_uniform, xi_uniform] = ksdensity(group_data_means(:,2,2));
% plot(xi_uniform, f_uniform, 'g', 'LineWidth', 1.5, 'DisplayName', 'Rabbit');
% 
% % Plot density for Exponential distribution
% [f_exponential, xi_exponential] = ksdensity(group_data_means(:,2,3));
% plot(xi_exponential, f_exponential, 'b', 'LineWidth', 1.5, 'DisplayName', 'Mask');
% 
% % Plot density for Beta distribution
% [f_beta, xi_beta] = ksdensity(group_data_means(:,2,4));
% plot(xi_beta, f_beta, 'm', 'LineWidth', 1.5, 'DisplayName', 'Ver3');
% 
% % Customize plot
% title('Density Plot of Betas per condition');
% xlabel('Value');
% ylabel('Density');
% legend show;
% grid on;
% hold off;
    
    % Create a subplot in the 4x4 grid
    
    % Plot a bar chart for the corresponding data
    bar(plotmeans);
    hold on;
    for cond = 1:conditions
        x = (1:ROI_nr) - .48 + cond*0.19;  % Adjust x-coordinates for each set of bars
        errorbar(x, plotmeans(:,cond), ploterrors(:,cond), '.', 'LineWidth', 1.5);
    end
    hold off;
    
    % hold on;
    % errorbar(1:4, cell2mat(plotmeans), cell2mat(ploterrors), 'k.', 'LineWidth', 1.5);
    % hold off;
    % Customize subplot appearance if needed
    %title(['Row ' num2str(i) ', Col ' num2str(j)]);
    
    title(['Activation per rROI: ', num2str(length(prfSubjects)), ' subjects']); % betatext, prf text, [', ']
    ylim([0 20]);
    xlabel('rROIs');
    ylabel('Beta');
%     x_labels = {"1", "rROI2", "rROI3", "rROI4", "rROI5"};
%     xticklabels(x_labels)
     p_values = [p_ver2, p_ill, p_control];
%     sigPairs = {{1.7,2.28}, {1.9,2.28}, {3,4}}
%     sigstar(sigPairs,p_values)
    legend('congr2', 'rabbit', 'mask', 'congr3');

   
    %set(gca, 'xticklabel', categories); % Set x-axis labels
    hold off; % Release the hold
    grid on;
%     p_values = 
%     paring = {}
%     sigstar
    % Generate three one-dimensional data sets
             % x-coordinates (common for all)
    y1 = group_data_means(:,2,1);  % First data set
    y2 = group_data_means(:,2,2);  % Second data set (offset for clarity)
    y3 = group_data_means(:,2,4);  % Third data set (offset for clarity)
    x= 1:size(y3);
    % Plot the data sets
    figure;               % Open a new figure window
    plot(x, y1, '-o', 'DisplayName', 'C1'); hold on; % Plot first data set
    plot(x, y2, '-x', 'DisplayName', 'C2');          % Plot second data set
    plot(x, y3, '-s', 'DisplayName', 'C4');          % Plot third data set
    hold off;
    
    % Add labels, title, and legend
    xlabel('X-axis');
    ylabel('Y-axis');
    title('Plotting betas');
    legend('Location', 'best');
    grid on; % Add a grid for better visualization

    % Testing relative increase hypothesis

    pp_betas = group_data_means;
    ill_roi1 = pp_betas(:,1,2);
    ver2_roi1 = pp_betas(:,1,1);
    ver3_roi1 = pp_betas(:,1,4);
    ill_roi2 = pp_betas(:,2,2);
    ver2_roi2 = pp_betas(:,2,1);
    ver3_roi2 = pp_betas(:,2,4);
    ill_roi3 = pp_betas(:,3,2);
    ver2_roi3 = pp_betas(:,3,1);
    ver3_roi3 = pp_betas(:,3,4);
    
    % Get participant betas per ROI
    ROI13_avg = [mean([ver2_roi1, ver2_roi3],2), mean([ill_roi1, ill_roi3],2), mean([ver3_roi1, ver3_roi3],2)];
    ROI2_avg = [ver2_roi2, ill_roi2, ver3_roi2];

    % Get ratio of activity for flash 2 vs flash13
    ill_quot = ill_roi2./mean([ill_roi1, ill_roi3],2);
    ver2_quot = ver2_roi2./mean([ver2_roi1, ver2_roi3],2);
    ver3_quot = ver3_roi2./mean([ver3_roi1, ver3_roi3],2);

    % Is the ratio higher than ver2?
    
    [h3,p3,t3] = ttest(ill_quot, ver2_quot, 'tail','right');
    disp(['The chance that AV has relative increase in flash 2, compared to ver2: ', num2str(p3)]);
    % Is the ratio closer to ver3 than to ver2?
    [h4,p4,t4] = ttest(ver3_quot-ill_quot, ver3_quot-ver2_quot, 'tail','right');
    disp(['The chance that the relative increase in AV is closer to ver3, compared to ver2: ', num2str(p4)]);

end
    %%
    % + visStimHorizEcc/2 - visStimWidth/2
    ROI1_coord_ind = find(Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol  - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    % visStimHorizEcc/2 + visStimWidth/2   visStimHorizEcc/2 + visStimWidth/2 
    ROI2_coord_ind = find(Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin); 
    %visStimHorizEcc/2 + visStimWidth/2 
    ROI3_coord_ind = find(Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    ROI4_coord_ind = find(Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    ROI5_coord_ind = find(Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    ROI6_coord_ind = find(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
    X=Xvol(ROI1_coord_ind);
    Y=Yvol(ROI1_coord_ind);
    
    % Create a scatter plot
    figure;
    %scatter(X, Y, 'DisplayName', 'Dataset 1', 'Marker', 'o');
    %scatter(Xvol(:,:), Yvol(:,:), 2, 'filled');
    hold on;
    RGB_cont = [170 170 170]/256 ;
    RGB_flash = [100 100 100]/256 ;
    RGB_ill = [20 20 20]/256 ;
    scatter(Xvol(ROI1_coord_ind), Yvol(ROI1_coord_ind), [], RGB_flash, 'DisplayName', 'Dataset 1','Marker', 'square')
    scatter(Xvol(ROI2_coord_ind), Yvol(ROI2_coord_ind), [], RGB_ill, 'DisplayName', 'Dataset 2','Marker', '*')
    scatter(Xvol(ROI3_coord_ind), Yvol(ROI3_coord_ind), [], RGB_flash, 'DisplayName', 'Dataset 3', 'Marker', 'square')
    scatter(Xvol(ROI4_coord_ind), Yvol(ROI4_coord_ind), [], RGB_cont, 'DisplayName', 'Dataset 4', 'Marker', 'x')
%     scatter(Xvol(ROI5_coord_ind), Yvol(ROI5_coord_ind), [], RGB_cont, 'DisplayName', 'Dataset 5', 'Marker', 'o')
    %scatter(Xvol(ROI6_coord_ind), Yvol(ROI6_coord_ind), 'DisplayName', 'Dataset 5', 'Marker', 'o');
    xlim([-5.5 5.5]);
    ylim([-5.5 5.5]);
    xlabel('degrees');
    ylabel('degrees');
    % Customize plot appearance
    title('Voxels per ROI');
    hold off;
%%



    % ANOVA
    % Convert matrix to table
    N = pp; 
%subjects = [1:pp]
subjects = [];
Y = [];
ROI = [];
Condition = [];
for i=1:N
    current_participant = subject_pRF_betas{i};
    for roi=1:3
        % specify conditions here
        for cond=[2 4]
            voxels = current_participant(roi,cond);
            voxels_cell = size(voxels{1});
            voxels_nr = voxels_cell(1);
            subjects = [subjects; repmat(i, voxels_nr, 1)];
            ROI = [ROI; repmat(roi,voxels_nr,1)];
            Condition = [Condition; repmat(cond,voxels_nr,1)];
            Y = [Y; [voxels{1}]];
        end
    end
end
% for subj = 1:N
%     values = randn(V, 1); % Random voxel values
%     ROI = randi(5, V, 1); % Random ROI assignment (1 to 5)
%     Condition = randi(4, V, 1); % Random Condition assignment (1 to 4)
%     data{subj} = struct('values', values, 'ROI', ROI, 'Condition', Condition);
% end

% % Initialize empty arrays for reshaped data and factor arrays
% reshaped_data = [];
% ROI = [];
% Condition = [];
% Subject = [];
% 
% % Loop through each subject
% for subj = 1:N
%     current_data = data{subj}; % Get the current subject's data
%     
%     % Append the voxel values
%     reshaped_data = [reshaped_data; current_data.values];
%     
%     % Append the corresponding ROIs and Conditions
%     ROI = [ROI; current_data.ROI];
%     Condition = [Condition; current_data.Condition];
%     
%     % Append the subject identifier (repeated for each voxel)
%     Subject = [Subject; repmat(subj, V, 1)];
% end

% Perform two-way ANOVA with 'ROI' and 'Condition' as fixed factors,
% and 'Subject' as a random factor
[p, table, stats] = anovan(Y, {ROI, Condition, subjects}, ...
                           'model', 'full', ...  % Full model including interaction
                           'random', 3, ...      % Subject as a random factor
                           'varnames', {'ROI', 'Condition', 'Subject'});

% Display ANOVA results
disp('ANOVA Results:');
disp(table);

%%

% Specifying ROI123 vs. Rest of V1

% ROI123 is all betas combined of ROI{1:3,:}
% with Label ROI=1
% Rest of V1 is all V1&sigmax&sigmin&varexp etc, without ROI123.

    % ANOVA
    % Convert matrix to table
%     N = pp; 
% %subjects = [1:pp]
% subjects = [];
% Y = [];
% ROI = [];
% Condition = [];
% for i=1:N
%     current_participant = subject_pRF_betas{i};
%     for roi=[2]% 6]
%         % specify conditions here
%         for cond=[1 4]
%             voxels = current_participant(roi,cond);
%             voxels_cell = size(voxels{1});
%             voxels_nr = voxels_cell(1);
%             subjects = [subjects; repmat(i, voxels_nr, 1)];
%             if roi < 4
%                 roi_name = 1;
%             else 
%                 roi_name = 2;
%             end
%             ROI = [ROI; repmat(roi_name,voxels_nr,1)];
%             Condition = [Condition; repmat(cond,voxels_nr,1)];
%             Y = [Y; [voxels{1}]];
%         end
%     end
% end
% g1 = Y(Condition==1);
% g2 = Y(Condition==4);
% [h,p]=ttest(g2,g1,'tail','right')
% for subj = 1:N
%     values = randn(V, 1); % Random voxel values
%     ROI = randi(5, V, 1); % Random ROI assignment (1 to 5)
%     Condition = randi(4, V, 1); % Random Condition assignment (1 to 4)
%     data{subj} = struct('values', values, 'ROI', ROI, 'Condition', Condition);
% end

% % Initialize empty arrays for reshaped data and factor arrays
% reshaped_data = [];
% ROI = [];
% Condition = [];
% Subject = [];
% 
% % Loop through each subject
% for subj = 1:N
%     current_data = data{subj}; % Get the current subject's data
%     
%     % Append the voxel values
%     reshaped_data = [reshaped_data; current_data.values];
%     
%     % Append the corresponding ROIs and Conditions
%     ROI = [ROI; current_data.ROI];
%     Condition = [Condition; current_data.Condition];
%     
%     % Append the subject identifier (repeated for each voxel)
%     Subject = [Subject; repmat(subj, V, 1)];
% end

% Perform two-way ANOVA with 'ROI' and 'Condition' as fixed factors,
% and 'Subject' as a random factor
[p, table, stats] = anovan(Y, {Condition, subjects}, ... %ROI, 
                           'model', 'full', ...  % Full model including interaction
                           'random', 2, ...      % Subject as a random factor
                           'varnames', {'Condition', 'Subject'}); %'ROI', 

% Display ANOVA results
disp('ANOVA Results:');
disp(table);