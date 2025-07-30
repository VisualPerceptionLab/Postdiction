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
% prfsubj = sprintf('Subject%02d', allSubjects(1));
allprfSubjects = {'Subject02','Subject03', 'Subject10', 'Subject12','Subject14','Subject07', 'Subject22', 'Subject15', 'Subject24', 'Subject30', 'Subject31', 'Subject35', 'Subject27', 'Subject42', 'Subject46', 'Subject49',  'Subject56', 'Subject59', 'Subject62', 'Subject63', 'Subject70', 'Subject71', 'Subject50', 'Subject67'};%, 'S15', 'S12', 'S22', 'S14', 'S24'}%, 'S03', 'S10', 'S12', 'S14'}%, 'S02','S03'};
selection = [1:6 8:24];
betaSubjects = allbetaSubjects(selection);
prfSubjects = allprfSubjects(selection);
nr_pps = length(prfSubjects);
withinsubject=false;
V2_thres = 0.5;
V1_thres = 2;
hypothesis_layer = 1;
for iSubj =1:length(betaSubjects)
    % layer effects per assigned voxel, we might need more sensitivity
    prfsubj = prfSubjects{iSubj};
    betasubj = sprintf('S%02d', betaSubjects(iSubj));
    

        % Create layer mask
    layering = fullfile(betadir, betasubj, 'LevelSets\Layering.nii');
    layer_vol  = spm_vol(layering);
    % layer_img(100,20,45,1:5)
    layer_img = spm_read_vols(layer_vol(2:4));

    %layer_app = layer_img(:,:,:,find(layer_img==max(layer_img(:,:,:,:))))
    
   % Assuming layer_img is a 100x20x45x5 double
    % Initialize the output array
    nifti_size = size(layer_img);
    nifti_size = nifti_size(1:3);
    layers = zeros(nifti_size);
    layer_threshold = .5;
    % Loop through each element in the 3D space
    for i = 1:nifti_size(1)
        for j = 1:nifti_size(2)
            for k = 1:nifti_size(3)
                % Extract the first three entries of the last dimension
                values = layer_img(i, j, k, 1:3);
                
                % Find the index of the maximum value
                [max_val, max_idx] = max(values);
                
                % Assign to layers only if the maximum value is greater than 0.5
                if max_val > layer_threshold
                    layers(i, j, k) = max_idx;
                end
            end
        end
    end


        % probably do all of this in a separate script
    % create an empty nifti of zeros to contain layer appointments
    % for each voxel, appoint the index that is highest within layer_img in
    % dimension 4 
    
    % create layer mask


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
    
    Mainvols = {spm_read_vols(Mainhead1), spm_read_vols(Mainhead2), spm_read_vols(Mainhead3), spm_read_vols(Mainhead4)};%, spm_read_vols(Mainhead7)};
    contrasts = length(Mainvols);
    visStimWidth = 0.28 * 1.5; 
    visStimLength = 1.2 * 1.5; 
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
    Sigmax = 1.5; %1.42 - (1/2)*visStimWidth; original: 1.5
    Sigmin = 0.1;
    varexpmin = .1; %change to sigmax 1 and varexpmin .2 original: .1
    Roi = cell(5, 4);

    brain_rois = {'V1'};
    func_dir_masks = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
    R_hdr = spm_vol(fullfile(func_dir_masks, betasubj, 'Masks', [brain_rois{1} '.nii']));
    R_maskV1 = spm_read_vols(R_hdr);
    R_vectV1 = reshape(R_maskV1,numel(R_maskV1),size(R_maskV1,4));
     disp(sprintf('%s: %d voxels',brain_rois{1},sum(R_vectV1)));

         % rROI extraction
    if V2_thres<1
    brain_roisV2 = {'V2'};
    func_dir_masksV2 = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
    R_hdrV2 = spm_vol(fullfile(func_dir_masksV2, betasubj, 'Masks', [brain_roisV2{1} '.nii']));
    R_maskV2 = spm_read_vols(R_hdrV2);
    R_vectV2 = reshape(R_maskV2,numel(R_maskV2),size(R_maskV2,4));
    disp(sprintf('%s: %d voxels',brain_roisV2{1},sum(R_vectV2)));
    else 
        R_maskV2 = 0;
    end
    
    func_dirHC= 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data';
    ROI_STS = {'STS'};
    R_hdrSTS = spm_vol(fullfile(func_dirHC, betasubj, 'hires_synth_noskull','mri', [ROI_STS{1} '.nii.gz']));
    R_maskSTS = spm_read_vols(R_hdrSTS);
    R_vectSTS = reshape(R_maskSTS,numel(R_maskSTS),size(R_maskSTS,4));
    disp(sprintf('%s: %d voxels',ROI_STS{1},sum(R_vectSTS)));
%             clear allvols
%         allvols(1,:,:,:) = Mainvols{1};   
%         allvols(2,:,:,:) = Mainvols{2};
%         allvols(3,:,:,:) = Mainvols{3};
%         allvols(4,:,:,:) = Mainvols{4};
%         meanconditions = squeeze(mean(allvols, 1));
%         Mainvols{1} = Mainvols{1} - meanconditions;
%         Mainvols{2} = Mainvols{2} - meanconditions;
%         Mainvols{3} = Mainvols{3} - meanconditions;
%         Mainvols{4} = Mainvols{4} - meanconditions;
    %svm_X = zeros(pp,)
    for iLayer = 1:3
        

        ROI1_coord_ind = layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol  - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
        % visStimHorizEcc/2 + visStimWidth/2   visStimHorizEcc/2 + visStimWidth/2 
        ROI2_coord_ind = layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin; 
        %visStimHorizEcc/2 + visStimWidth/2 
        ROI3_coord_ind = layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
        % Remove elements from ROI2_coord_ind that are present in ROI3_coord_ind
        ROI2_coord_ind = ROI2_coord_ind & ~ROI3_coord_ind;
        
        % Remove elements from ROI2_coord_ind that are present in ROI1_coord_ind
        ROI2_coord_ind = ROI2_coord_ind & ~ROI1_coord_ind;
        flash1_logical_idx_control = layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol & Yvol <= -1*flash1.ymin + Sigvol & Yvol >= -1*flash1.ymax - Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
        flash2_logical_idx_control = layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Xvol>= flash2.xmin - Sigvol & Xvol<= flash2.xmax + Sigvol & Yvol <= -1*flash2.ymin + Sigvol & Yvol >= -1*flash2.ymax - Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
        flash3_logical_idx_control = layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Xvol>= flash3.xmin - Sigvol & Xvol<= flash3.xmax + Sigvol & Yvol <= -1*flash3.ymin + Sigvol & Yvol >= -1*flash3.ymax - Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin;
        pRF_betas.layers(iLayer).flash123contr(iSubj,1) = mean(Mainvols{1}((flash1_logical_idx_control | flash2_logical_idx_control | flash3_logical_idx_control) & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).flash123contr(iSubj,2) = mean(Mainvols{2}((flash1_logical_idx_control | flash2_logical_idx_control | flash3_logical_idx_control) & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).flash123contr(iSubj,3) = mean(Mainvols{3}((flash1_logical_idx_control | flash2_logical_idx_control | flash3_logical_idx_control) & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).flash123contr(iSubj,4) = mean(Mainvols{4}((flash1_logical_idx_control | flash2_logical_idx_control | flash3_logical_idx_control) & ~isnan(Mainvols{4})));
        
        % when plotting: for each layer, for each ROI, a pp by 4 double 
        % Flash 2

        pRF_betas.layers(iLayer).flash1(iSubj,1) = mean(Mainvols{1}(ROI1_coord_ind & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).flash1(iSubj,2) = mean(Mainvols{2}(ROI1_coord_ind & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).flash1(iSubj,3) = mean(Mainvols{3}(ROI1_coord_ind & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).flash1(iSubj,4) = mean(Mainvols{4}(ROI1_coord_ind & ~isnan(Mainvols{4})));

        pRF_betas.layers(iLayer).flash2(iSubj,1) = mean(Mainvols{1}(ROI2_coord_ind & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).flash2(iSubj,2) = mean(Mainvols{2}(ROI2_coord_ind & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).flash2(iSubj,3) = mean(Mainvols{3}(ROI2_coord_ind & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).flash2(iSubj,4) = mean(Mainvols{4}(ROI2_coord_ind & ~isnan(Mainvols{4})));

        pRF_betas.layers(iLayer).flash3(iSubj,1) = mean(Mainvols{1}(ROI3_coord_ind & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).flash3(iSubj,2) = mean(Mainvols{2}(ROI3_coord_ind & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).flash3(iSubj,3) = mean(Mainvols{3}(ROI3_coord_ind & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).flash3(iSubj,4) = mean(Mainvols{4}(ROI3_coord_ind & ~isnan(Mainvols{4})));

        pRF_betas.layers(iLayer).flash123(iSubj,1) = mean(Mainvols{1}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).flash123(iSubj,2) = mean(Mainvols{2}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).flash123(iSubj,3) = mean(Mainvols{3}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).flash123(iSubj,4) = mean(Mainvols{4}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{4})));
        
%         % dimensionality reduction to get few meaningful axes
%         % pca trained on all data
%         % then split data up in conditions
%         % apply svm
%         ROI1_svm = layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol  - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax;
%         ROI2_svm =
%         ROI3_svm =
%         deep_layerflash123(iSubj,2) = Mainvols{2}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{2}));
%         pRF_betas.layers(iLayer).flash123(iSubj,4) = Mainvols{4}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{4}));
%         pRF_betas.layers(iLayer).flash123(iSubj,1) = Mainvols{1}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{1}));
%         pRF_betas.layers(iLayer).flash123(iSubj,1) = Mainvols{1}((ROI1_coord_ind | ROI2_coord_ind | ROI3_coord_ind) & ~isnan(Mainvols{1}));

        pRF_betas.layers(iLayer).allV1(iSubj,1) = mean(Mainvols{1}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).allV1(iSubj,2) = mean(Mainvols{2}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).allV1(iSubj,3) = mean(Mainvols{3}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).allV1(iSubj,4) = mean(Mainvols{4}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4})));
        
        pRF_betas.layers(iLayer).v1minflash(iSubj,1) = mean(Mainvols{1}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres)  & Sigvol < Sigmax & Sigvol > Sigmin & Varvol > varexpmin & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).v1minflash(iSubj,2) = mean(Mainvols{2}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres)  & Sigvol < Sigmax & Sigvol > Sigmin & Varvol > varexpmin & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).v1minflash(iSubj,3) = mean(Mainvols{3}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres)  & Sigvol < Sigmax & Sigvol > Sigmin & Varvol > varexpmin & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).v1minflash(iSubj,4) = mean(Mainvols{4}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > V1_thres)  & Sigvol < Sigmax & Sigvol > Sigmin & Varvol > varexpmin & ~ROI1_coord_ind & ~ROI2_coord_ind & ~ROI3_coord_ind & ~isnan(Mainvols{4})));
        
        pRF_betas.layers(iLayer).STS(iSubj,1) = mean(Mainvols{1}(layers == iLayer & Varvol > 0.1 & (R_maskSTS > V1_thres) & ~isnan(Mainvols{1})));
        pRF_betas.layers(iLayer).STS(iSubj,2) = mean(Mainvols{2}(layers == iLayer & Varvol > 0.1 & (R_maskSTS > V1_thres) & ~isnan(Mainvols{2})));
        pRF_betas.layers(iLayer).STS(iSubj,3) = mean(Mainvols{3}(layers == iLayer & Varvol > 0.1 & (R_maskSTS > V1_thres) & ~isnan(Mainvols{3})));
        pRF_betas.layers(iLayer).STS(iSubj,4) = mean(Mainvols{4}(layers == iLayer & Varvol > 0.1 & (R_maskSTS > V1_thres) & ~isnan(Mainvols{4})));
        
        % Test hypothesis whether voxels in deep layer with higher e-X-entricity have higher
        % betas
    
        
        if iLayer == hypothesis_layer
            % Extract betas in flash 2
            AV_betas = Mainvols{2}(ROI2_coord_ind & ~isnan(Mainvols{4}));
            ver2_betas = Mainvols{1}(ROI2_coord_ind & ~isnan(Mainvols{1}));
            
            % Extract associated x and sigma
            AV_x = Xvol(ROI2_coord_ind & ~isnan(Mainvols{4}));
            ver2_x = Xvol(ROI2_coord_ind & ~isnan(Mainvols{1}));
            AV_sig = Sigvol(ROI2_coord_ind & ~isnan(Mainvols{4}));
            ver2_sig = Sigvol(ROI2_coord_ind & ~isnan(Mainvols{1}));

            AV_deep_precision= corr(AV_betas, abs(AV_x));
            ver2_deep_precision = corr(ver2_betas, abs(ver2_x));

            AV_deep_topdown= corr(AV_betas, abs(AV_sig));
            ver2_deep_topdown = corr(ver2_betas, abs(ver2_sig));

%             AV_Y_corr = corr(AV_betas,abs(AV_Y));
%             ver2_Y_corr = corr(ver2_betas, abs(ver2_Y));
            
            precision_hyp(iSubj,:) = [ver2_deep_precision, AV_deep_precision];
            topdown_hyp(iSubj,:) = [AV_deep_topdown, ver2_deep_topdown];
        end
        
   
        % 
%         pRF_betas.layers(iLayer).flash123control(iSubj,1) = mean(Mainvols{1}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1})));
%         pRF_betas.layers(iLayer).flash123control(iSubj,2) = mean(Mainvols{2}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2})));
%         pRF_betas.layers(iLayer).flash123control(iSubj,3) = mean(Mainvols{3}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3})));
%         pRF_betas.layers(iLayer).flash123control(iSubj,4) = mean(Mainvols{4}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4})));

%         % V1
%         Roi{3,1} = Mainvols{1}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}));
%         Roi{3,2} = Mainvols{2}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}));
%         Roi{3,3} = Mainvols{4}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}));
%         Roi{3,4} = Mainvols{3}(layers == iLayer & (R_maskV2 > V2_thres | R_maskV1 > 0.5) & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}));

%         pRF_data.layers(iLayer)
%         
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
%    % rest of V1
%     Roi{6,1} = Mainvols{1}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{1}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
%     Roi{6,2} = Mainvols{2}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{2}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
%     Roi{6,3} = Mainvols{3}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{3}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
%     Roi{6,4} = Mainvols{4}(R_mask > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~isnan(Mainvols{4}) & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
%     
%     if strcmp(betasubj, 'S59')
%         for rroi=1:6
%             sizeroi = size(Roi{rroi,3});
%             Roi{rroi,3} = repmat(NaN, 1, sizeroi(1));
%         end
%     end
    


    if smoothed_prfs
        prftext = 'smooth prf';
    else prftext = 'unsmooth prf';
    end
    if smoothed_betas
        betatext = 'smooth betas, ';
    else betatext = 'unsmooth betas, ';
    end
    end

    

end

[h1,p1,t1]=ttest(precision_hyp(:,1),precision_hyp(:,2), 'tail','right');
disp(['The p-value for more precise illusory activity is: ', num2str(p1)])
[h2,p2,t2]=ttest(topdown_hyp(:,1),topdown_hyp(:,2), 'tail','right');
disp(['The p-value for higher illusory activity with ecc: ', num2str(p2)])

%%
close all;
% plotmeans = zeros(4,3);
% plotmeans(:,1) = 
for iLayer=1:3
    layer_names = {'deep', 'middle', 'superficial'};
   
    flash123means = pRF_betas.layers(iLayer).flash123;
    flash2means = pRF_betas.layers(iLayer).flash2;
    allV1means = pRF_betas.layers(iLayer).allV1;
    STSmeans = pRF_betas.layers(iLayer).STS;
    
    ROImeans= flash2means;
    conditions = 4;
    ROI_nr = 3;%length(Roi);
   
    if iLayer== hypothesis_layer 
%          pp_betas = 
    ill_roi1 = pRF_betas.layers(1).flash1(:,2);
    ver2_roi1 = pRF_betas.layers(1).flash1(:,1);
    ver3_roi1 = pRF_betas.layers(1).flash1(:,4);
    ill_roi2 = pRF_betas.layers(1).flash2(:,2);
    ver2_roi2 = pRF_betas.layers(1).flash2(:,1);
    ver3_roi2 = pRF_betas.layers(1).flash2(:,4);
    ill_roi3 = pRF_betas.layers(1).flash3(:,2);
    ver2_roi3 = pRF_betas.layers(1).flash3(:,1);
    ver3_roi3 = pRF_betas.layers(1).flash3(:,4);

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
    
    for column=1:conditions
        ploterrors(column) = nanstd(ROImeans(:,column)) / sqrt(length(ROImeans(:,column)));%(~isnan(group_data_means_cat(row,column,:)
    end
   
    [h, p, t]=ttest(ROImeans(:,1), ROImeans(:,2))

    figure;
    plotmeans = nanmean(ROImeans,1);
    plotmeans = plotmeans([1 2 4]);
    ploterrors = ploterrors([1 2 4]);
    % Create a subplot in the 4x4 grid
   
    % Plot a bar chart for the corresponding data
    bar(plotmeans);
    hold on;
    
    
    errorbar(plotmeans, ploterrors, 'o-', 'LineWidth', 1.5, 'MarkerSize', 8);
%     hold on;
%     for cond = 1:conditions
%         x = (1:ROI_nr) - .48 + cond*0.19;  % Adjust x-coordinates for each set of bars
%         errorbar(x, plotmeans(:,cond), ploterrors(:,cond), '.', 'LineWidth', 1.5);
%     end
%     hold off;
   
    title(['Betas: ', num2str(length(prfSubjects)), ' subjects; ', layer_names{iLayer}, ' layer.']); % betatext, prf text, [', ']
    ylim([0 14])
    xlabel('Condition');
    ylabel('Beta');
%      legend('congr2', 'rabbit', 'congr3');
    hold off; % Release the hold
    grid on;

%     figure;
%     hold on;
%     
%     % Plot density for Normal distribution
%     [f_normal, xi_normal] = ksdensity(ROImeans(:,1));
%     plot(xi_normal, f_normal, 'r', 'LineWidth', 1.5, 'DisplayName', 'Ver2');
%     
%     % Plot density for Uniform distribution
%     [f_uniform, xi_uniform] = ksdensity(ROImeans(:,2));
%     plot(xi_uniform, f_uniform, 'g', 'LineWidth', 1.5, 'DisplayName', 'Rabbit');
%     
%     % Plot density for Exponential distribution
%     [f_exponential, xi_exponential] = ksdensity(ROImeans(:,3));
%     plot(xi_exponential, f_exponential, 'b', 'LineWidth', 1.5, 'DisplayName', 'Mask');
%     
%     % Plot density for Beta distribution
%     [f_beta, xi_beta] = ksdensity(ROImeans(:,4));
%     plot(xi_beta, f_beta, 'm', 'LineWidth', 1.5, 'DisplayName', 'Ver3');
%     
%     % Customize plot
%     title(['Density Plot of Betas per condition, ', layer_names{iLayer}]);
%     xlabel('Value');
%     ylabel('Density');
%     legend show;
%     grid on;
%     hold off;


end
%%
figure;
    N = nr_pps; 
% subjects = [1:iSubj]
subjects = [];
Y = [];
layer = [];
Condition = [];
for i=[1:23]
%      current_participant = subject_pRF_betas{i};
    for iLayer=1:3
        betas = pRF_betas.layers(iLayer).flash2(i,:);
        % specify conditions here
        for cond=[1 2]
            betas_cond = betas(cond);
%             voxels_cell = size(voxels{1});
%             voxels_nr = voxels_cell(1);
            subjects = [subjects; i];
            layer = [layer; iLayer];
            Condition = [Condition; cond];
            Y = [Y; betas_cond];
        end
    end
end

[p, table, stats] = anovan(Y, {layer, Condition, subjects}, ...
                           'model', 'full', ...  % Full model including interaction
                           'random', 3, ...      % Subject as a random factor
                           'varnames', {'layer', 'Condition', 'Subject'});

% Display ANOVA results
disp('ANOVA Results:');
disp(table);
%%
% Y = [repmat(1,21,1);repmat(2,21,1)]
% ill = pRF_betas.layers(1).flash123(:,2);
% ver3 = pRF_betas.layers(1).flash123(:,4);
% X = [ill;ver3]
% XY = [X,Y]
% % Randomly permute rows
% numRows = size(X, 1);        % Get the number of rows
% randomOrder = randperm(numRows);  % Generate a random permutation of row indices
% 
% X_shuffled = X(randomOrder);  % Shuffle rows of X
% Y_shuffled = Y(randomOrder);
% %X(:,2) = categorical([1:21 1:21])
% % Train a linear SVM
% SVMModel = fitcsvm(X_shuffled, Y_shuffled, 'KernelFunction', 'linear', 'Standardize', true);
% 
% % View model details
% disp(SVMModel);
% % Perform 10-fold cross-validation
% CVSVMModel = crossval(SVMModel, 'KFold', 10);
% 
% % Predict and calculate accuracy
% predictedLabels = kfoldPredict(CVSVMModel);
% accuracy = sum(predictedLabels== Y) / length(Y) * 100;
% fprintf('Cross-Validation Accuracy: %.2f%%\n', accuracy);

%%

    %%
    % + visStimHorizEcc/2 - visStimWidth/2
    ROI1_coord_ind = find(Xvol>= flash1.xmin - Sigvol & Xvol<= flash1.xmax + Sigvol  - ROI_boundary & Yvol >= flash1.ymin - Sigvol & Yvol <= flash1.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    % visStimHorizEcc/2 + visStimWidth/2   visStimHorizEcc/2 + visStimWidth/2 
    ROI2_coord_ind = find(Xvol>= flash2.xmin - Sigvol + ROI_boundary & Xvol<= flash2.xmax + Sigvol - ROI_boundary & Yvol >= flash2.ymin -  Sigvol & Yvol <= flash2.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin); 
    %visStimHorizEcc/2 + visStimWidth/2 
    ROI3_coord_ind = find(Xvol>= flash3.xmin - Sigvol + ROI_boundary & Xvol<= flash3.xmax + Sigvol & Yvol >= flash3.ymin - Sigvol & Yvol <= flash3.ymax + Sigvol  & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    
    ROI4_coord_ind = find(Xvol>= control.xmin - Sigvol & Xvol<= control.xmax + Sigvol & Yvol >= control.ymin - Sigvol & Yvol <= control.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
    ROI5_coord_ind = find(Xvol>= bullseye.xmin - Sigvol & Xvol<= bullseye.xmax + Sigvol & Yvol >= bullseye.ymin - Sigvol & Yvol <= bullseye.ymax + Sigvol & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin);
%     ROI6_coord_ind = find(R_maskV1 > 0.5 & Varvol > varexpmin & Sigvol < Sigmax & Sigvol > Sigmin & ~ROI1_coord_ind_excl & ~ROI2_coord_ind_excl & ~ROI3_coord_ind_excl);
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
    scatter(Xvol(ROI5_coord_ind), Yvol(ROI5_coord_ind), [], RGB_cont, 'DisplayName', 'Dataset 5', 'Marker', 'o')
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
%     N = pp; 
% %subjects = [1:pp]
% % subjects = [];
% Y = [];
% ROI = [];
% Condition = [];
% for i=1:N
%     current_participant = subject_pRF_betas{i};
%     for roi=1:3
%         % specify conditions here
%         for cond=[2 4]
%             voxels = current_participant(roi,cond);
%             voxels_cell = size(voxels{1});
%             voxels_nr = voxels_cell(1);
%             subjects = [subjects; repmat(i, voxels_nr, 1)];
%             ROI = [ROI; repmat(roi,voxels_nr,1)];
%             Condition = [Condition; repmat(cond,voxels_nr,1)];
%             Y = [Y; [voxels{1}]];
%         end
%     end
% end
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
% % for subj = 1:N
% %     values = randn(V, 1); % Random voxel values
% %     ROI = randi(5, V, 1); % Random ROI assignment (1 to 5)
% %     Condition = randi(4, V, 1); % Random Condition assignment (1 to 4)
% %     data{subj} = struct('values', values, 'ROI', ROI, 'Condition', Condition);
% % end
% 
% % % Initialize empty arrays for reshaped data and factor arrays
% % reshaped_data = [];
% % ROI = [];
% % Condition = [];
% % Subject = [];
% % 
% % % Loop through each subject
% % for subj = 1:N
% %     current_data = data{subj}; % Get the current subject's data
% %     
% %     % Append the voxel values
% %     reshaped_data = [reshaped_data; current_data.values];
% %     
% %     % Append the corresponding ROIs and Conditions
% %     ROI = [ROI; current_data.ROI];
% %     Condition = [Condition; current_data.Condition];
% %     
% %     % Append the subject identifier (repeated for each voxel)
% %     Subject = [Subject; repmat(subj, V, 1)];
% % end
% 
% % Perform two-way ANOVA with 'ROI' and 'Condition' as fixed factors,
% % and 'Subject' as a random factor
% [p, table, stats] = anovan(Y, {Condition, subjects}, ... %ROI, 
%                            'model', 'full', ...  % Full model including interaction
%                            'random', 2, ...      % Subject as a random factor
%                            'varnames', {'Condition', 'Subject'}); %'ROI', 
% 
% % Display ANOVA results
% disp('ANOVA Results:');
% disp(table);