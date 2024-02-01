% function designMatrix = getExperimentalDesign(totalTrials)

% Number of trials and conditions
numConditions = 4;
totalTrials = 52;

% Initialize the design matrix
designMatrix = zeros(totalTrials, 1);
trialsPerSubBlock = floor(totalTrials,4);
subBlocks = 4;
% foreach of n submatrix
for subblock = 1:numConditions
    remainder = mod(totalTrials,4);
    submatrix = repmat([1 2 3 4],subBlocks);
    startIndex = (subblock - 1) * subBlocks
end
% Display the design matrix
disp('Experimental Design Matrix:');
disp(designMatrix);
% add a random 1, 2, 3 or 4
% random permute
%put on start and endindex
% Randomly shuffle the conditions for each block
for block = 1:(totalTrials / trialsPerBlock)
    conditions = randperm(numConditions);
    startIndex = (block - 1) * trialsPerBlock + 1;
    endIndex = block * trialsPerBlock;
    
    % Assign conditions to trials in the block
    designMatrix(startIndex:endIndex, 1) = repmat(conditions, 1, trialsPerBlock / numConditions);
end

% Assign trial numbers
%designMatrix(:, 1) = 1:totalTrials;

