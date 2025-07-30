% PB: This script should combine beta.nii into a contrast, weighting by the
% amount of illusions.
clear all; close all;
allbetaSubjects = [2 3 10 12 14 7 22 15 24 30 31 35 27 42 46 49 56 59 62 63 70 71]
selection = [1:17 19:22];
betaSubjects = allbetaSubjects(selection);
rootDir = 'D:\Documents\PhD_project\postdiction_AV_fMRI\fMRI_processing\LayerfMRI_Hallucinations\Subject_data'
for iSubj =1:length(betaSubjects)
    betasubj = sprintf('S%02d', betaSubjects(iSubj));
    firstleveldir = ['FirstLevelModelBehavsplit'];
    beta_dir = fullfile(rootDir, betasubj, firstleveldir);
    % Get the beta files.
    beta_files = spm_select('FPList',beta_dir,'^beta_00*');
    % Get the illusions.
    behFiles = dir(fullfile(rootDir, betasubj, 'Behaviour/results_mainexp_*'));
    runCount = length(behFiles);
    regressor_count_run = 0;

    % get the amount of illusions and relevant beta runs
    AV_illusions = {};
    IV_illusions = {};
    ver2 = {};
    ver3 = {};
    betafiles_idx = [];
    for iRun = 1:runCount
        load(fullfile(behFiles(iRun).folder, behFiles(iRun).name));
        
        AV_ill_count_run = 0;
        AV_noill_count_run = 0;
        IV_ill_count_run = 0;
        IV_noill_count_run = 0;
        ver2_count_run =0;
        ver3_count_run=0;
        for iBlock = 1:length(data)
            AV_ill_count_run = AV_ill_count_run + sum(data{iBlock}.condition == 2 & data{iBlock}.flashAnswer == 3);
            AV_noill_count_run = AV_noill_count_run + sum(data{iBlock}.condition == 2 & data{iBlock}.flashAnswer == 2);
            IV_ill_count_run = IV_ill_count_run + sum(data{iBlock}.condition == 3 & data{iBlock}.flashAnswer == 2);
            IV_noill_count_run = IV_noill_count_run + sum(data{iBlock}.condition == 3 & data{iBlock}.flashAnswer == 2);
            ver2_count_run = ver2_count_run + sum(data{iBlock}.condition == 1 & data{iBlock}.flashAnswer == 2);
            ver3_count_run = ver3_count_run + sum(data{iBlock}.condition == 4 & data{iBlock}.flashAnswer == 3);
        end
        AV_illusions{iRun} = AV_ill_count_run;
        IV_illusions{iRun} = IV_ill_count_run;
        ver2{iRun} = ver2_count_run;
        ver3{iRun} = ver3_count_run;


%         %betaRun = 
%         % Some have 95 and some have 96
%         betafiles_idx = [betafiles_idx; [1:4] + regressor_count_run];
%         
%         % is there a garbage regressor?
%         max_regressors = 24;
%         regressors = load(fullfile(beta_dir, "cond_run" + iRun));
%         total_nr_betas = length(beta_files(:,1));
%         % check for garbage regressor
%         if length(regressors.onsets) == 5
%                 regressor_count_run = regressor_count_run + max_regressors;
%         elseif length(regressors.onsets) == 4
%                 regressor_count_run = regressor_count_run + max_regressors - 1;
%                 %total_nr_betas
%                 %[1:4] + regressor_count_run
%         else 
%             disp(firstleveldir)
%         end

        
        %length(spmmat.SPM.Vbeta)

    end
    load(fullfile(beta_dir, "SPM.mat"))
    % Step 1: Extract the 'field' values into a cell array
    fields = {SPM.Vbeta.descrip};
    
    % Step 2: Use contains to check if each string contains 'AVill'
    containsAVill = contains(fields, 'AVill');
    
    % Step 3: Find the indices of the elements where 'AVill' is found
    indices = find(containsAVill);
    
    % AV
     condition = 2;
     av_regressors = beta_files(indices,:);
     func_vol  = spm_vol(av_regressors);
     func_data= spm_read_vols(func_vol);


     % average beta runs
     sum_beta = sum(func_data,4);
     size_niftii = size(func_data);
     weighted_con = zeros(size_niftii(1:3));
     validate = ones(size_niftii(1:3));
     divisor = 0;
     for iRun=1:runCount
         divisor = divisor+AV_illusions{iRun};
         weighted_con = weighted_con + func_data(:,:,:,iRun)*AV_illusions{iRun}; %func_data(:,:,:,iRun)
     end
     weighted_con = weighted_con/divisor*runCount;
%      thisstring = spm_select('FPList',beta_dir,'^con_0002');
%      con_vol = spm_vol(thisstring)
%      concheck = spm_read_vols(con_vol);
    param_vol  = spm_vol(func_vol(1));
    param_vol.fname = fullfile(beta_dir,'PBcon_0002.nii');
    spm_write_vol(param_vol,weighted_con);
    
    % IV
    containsIVill = contains(fields, 'IVill');

     % Step 3: Find the indices of the elements where 'IVill' is found
    indices = find(containsIVill);
    
   
     condition = 3;
     iv_regressors = beta_files(indices,:);
     func_vol  = spm_vol(iv_regressors);
     func_data= spm_read_vols(func_vol);


     % average beta runs
     sum_beta = sum(func_data,4);
     size_niftii = size(func_data);
     weighted_con = zeros(size_niftii(1:3));
     validate = ones(size_niftii(1:3));
     divisor = 0;
     for iRun=1:runCount
         divisor = divisor+IV_illusions{iRun};
         weighted_con = weighted_con + func_data(:,:,:,iRun)*IV_illusions{iRun}; %func_data(:,:,:,iRun)
     end
     weighted_con = weighted_con/divisor*runCount;
%      thisstring = spm_select('FPList',beta_dir,'^con_0002');
%      con_vol = spm_vol(thisstring)
%      concheck = spm_read_vols(con_vol);
    param_vol  = spm_vol(func_vol(1));
    param_vol.fname = fullfile(beta_dir,'PBcon_0003.nii');
    spm_write_vol(param_vol,weighted_con);


% Ver2

    containsver2 = contains(fields, '2F2B');

     % Step 3: Find the indices of the elements where 'IVill' is found
    indices = find(containsver2);
    
   
     condition = 1;
     ver2_regressors = beta_files(indices,:);
     func_vol  = spm_vol(ver2_regressors);
     func_data= spm_read_vols(func_vol);


     % average beta runs
     sum_beta = sum(func_data,4);
     size_niftii = size(func_data);
     weighted_con = zeros(size_niftii(1:3));
     validate = ones(size_niftii(1:3));
     divisor = 0;
     for iRun=1:runCount
         divisor = divisor+ver2{iRun};
         weighted_con = weighted_con + func_data(:,:,:,iRun)*ver2{iRun}; %func_data(:,:,:,iRun)
     end
     weighted_con = weighted_con/divisor*runCount;
%      thisstring = spm_select('FPList',beta_dir,'^con_0002');
%      con_vol = spm_vol(thisstring)
%      concheck = spm_read_vols(con_vol);
    param_vol  = spm_vol(func_vol(1));
    param_vol.fname = fullfile(beta_dir,'PBcon_0001.nii');
    spm_write_vol(param_vol,weighted_con);

    % Ver3

    containsver3= contains(fields, '3F3B');

     % Step 3: Find the indices of the elements where 'IVill' is found
    indices = find(containsver3);
    
   
     condition = 4;
     ver3_regressors = beta_files(indices,:);
     func_vol  = spm_vol(ver3_regressors);
     func_data= spm_read_vols(func_vol);


     % average beta runs
     sum_beta = sum(func_data,4);
     size_niftii = size(func_data);
     weighted_con = zeros(size_niftii(1:3));
     validate = ones(size_niftii(1:3));
     divisor = 0;
     for iRun=1:runCount
         divisor = divisor+ver3{iRun};
         weighted_con = weighted_con + func_data(:,:,:,iRun)*ver3{iRun}; %func_data(:,:,:,iRun)
     end
     weighted_con = weighted_con/divisor*runCount;
%      thisstring = spm_select('FPList',beta_dir,'^con_0002');
%      con_vol = spm_vol(thisstring)
%      concheck = spm_read_vols(con_vol);
    param_vol  = spm_vol(func_vol(1));
    param_vol.fname = fullfile(beta_dir,'PBcon_0004.nii');
    spm_write_vol(param_vol,weighted_con);


end