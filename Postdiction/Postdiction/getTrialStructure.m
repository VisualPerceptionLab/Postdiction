function [trialStructure] = getTrialStructure(nTrials, propOmission)
% [trialStructure]  = getTrialStructure(nTrials)
%
% Creates a 2D matrix of nTrials x nFeatures, such that the features are
% counterbalanced.
%

% number of omission trials should be a multiple of 16 in order to counterbalance everything
% properly.
if mod(propOmission.prob*nTrials,16) ~= 0
    disp('WARNING: propOmission*nTrials is not a multiple of 16, counterbalancing will fail!');
    abort = input('Abort experiment?: (1: yes, 2: no): ');
    if abort == 1
        abort = aaa; % force error
    end
end
if mod((1-propOmission.prob)*nTrials,16) ~= 0
    disp('WARNING: (1-propOmission)*nTrials is not a multiple of 16, counterbalancing will fail!');
    abort = input('Abort experiment?: (1: yes, 2: no): ');
    if abort == 1
        abort = aaa; % force error
    end
end

if propOmission.prob > 0 && propOmission.alwaysValid == false
    
    trialStructure = zeros(nTrials,4);
    trialStructure(1:end*(1-propOmission.prob),1) = 1; % 1 = predicted orientation, 0 = omission
    trialStructure(1:2:end,2) = 1;  % half of the trials get low tone as the cue, the other half get high tone
    trialStructure(2:2:end,2) = 2;
    trialStructure([1:4:end 2:4:end],3) = 1; % half of the trials get one response mapping, the rest get the other.
    trialStructure([1:16:end 2:16:end 3:16:end 4:16:end],4) = 1; % noise patch 1
    trialStructure([5:16:end 6:16:end 7:16:end 8:16:end],4) = 2; % noise patch 2
    trialStructure([9:16:end 10:16:end 11:16:end 12:16:end],4) = 3; % noise patch 3
    trialStructure([13:16:end 14:16:end 15:16:end 16:16:end],4) = 4; % noise patch 4
    
elseif propOmission.prob == 0 && propOmission.alwaysValid == true
    trialStructure = zeros(nTrials,4);
    trialStructure(1:end*(1-propOmission.prob),1) = 1; % 1 = predicted orientation, 0 = omission
    trialStructure(1:2:end,2) = 1;  % half of the trials get low tone as the cue, the other half get high tone
    trialStructure(2:2:end,2) = 2;
    trialStructure([1:4:end 2:4:end],3) = 1; % half of the trials get one response mapping, the rest get the other.
    trialStructure([1:16:end 2:16:end 3:16:end 4:16:end],4) = 1; % noise patch 1
    trialStructure([5:16:end 6:16:end 7:16:end 8:16:end],4) = 2; % noise patch 2
    trialStructure([9:16:end 10:16:end 11:16:end 12:16:end],4) = 3; % noise patch 3
    trialStructure([13:16:end 14:16:end 15:16:end 16:16:end],4) = 4; % noise patch 4
    
elseif propOmission.prob > 0 && propOmission.alwaysValid == false
    disp('Nonsense probOmission variable')
    
elseif propOmission.prob == 0 & propOmission.alwaysValid == false
    
    % No omissions, so will introduce 25% invalid trials.
    propInvalid = 0.25;
    
    if mod(propInvalid*nTrials,16) == 0 && mod((1-propInvalid)*nTrials,16) == 0
        % counterbalancing will be fine.
        trialStructure = zeros(nTrials,4);
        trialStructure(1:end*(1-propInvalid),1) = 1; % 1 = predicted orientation
        trialStructure(end*(1-propInvalid)+1:end,1) = 2; % 2 = unpredicted orientation
        trialStructure(1:2:end,2) = 1; % half of the trials get low tone as the cue, the other half get high tone
        trialStructure(2:2:end,2) = 2;
        trialStructure([1:4:end 2:4:end],3) = 1; % half of the trials get one response mapping, the rest get the other.
        trialStructure([1:16:end 2:16:end 3:16:end 4:16:end],4) = 1; % noise patch 1
        trialStructure([5:16:end 6:16:end 7:16:end 8:16:end],4) = 2; % noise patch 2
        trialStructure([9:16:end 10:16:end 11:16:end 12:16:end],4) = 3; % noise patch 3
        trialStructure([13:16:end 14:16:end 15:16:end 16:16:end],4) = 4; % noise patch 4
    elseif nTrials < 64
        % Too short a block to properly counterbalance, e.g. a practice
        % block. Do a bit of hacking.
        nValidTrials = nTrials*(1-propInvalid);
        nInvalidTrials = nTrials*propInvalid;
        trialStructure = zeros(nTrials,4); 
        trialStructure(1:end*(1-propInvalid),1) = 1; % 1 = predicted orientation
        trialStructure(end*(1-propInvalid)+1:end,1) = 2; % 2 = unpredicted orientation
        % pseudorandomly assign the valid and invalid trials a cue, response
        % mapping and noise patch.
        trialStructure(trialStructure(:,1)==1,2) = mod(randperm(nValidTrials),2) + 1;  % half of the trials get low tone as the cue, the other half get high tone
        trialStructure(trialStructure(:,1)==2,2) = mod(randperm(nInvalidTrials),2) + 1;  % half of the trials get low tone as the cue, the other half get high tone
        trialStructure(trialStructure(:,1)==1,3) = mod(randperm(nValidTrials),2);  % half of the trials get one response mapping, the rest get the other.
        trialStructure(trialStructure(:,1)==2,3) = mod(randperm(nInvalidTrials),2);  % half of the trials get one response mapping, the rest get the other.
        trialStructure(trialStructure(:,1)==1,4) = mod(randperm(nValidTrials),4) + 1;  % noise patch 1-4
        trialStructure(trialStructure(:,1)==2,4) = mod(randperm(nInvalidTrials),4) + 1;  % noise patch 1-4
    else
        % something has gone wrong.
        disp('WARNING: propInvalid*nTrials and/or (1-propInvalid)*nTrials is not a multiple of 16, counterbalancing will fail!');
        abort = input('Abort experiment?: (1: yes, 2: no): ');
        if abort == 1
            abort = aaa; % force error
        end
    end
    
end

end