%function designMatrix = getExperimentalDesign(totalTrials)

% Number of trials and conditions
numConditions = 4;
totalTrials = 52;
trialsPerSubBlock = totalTrials/numConditions;
% Initialize the design matrix
designMatrix = zeros(totalTrials, 1);
subBlocks = 4;
RepsPerSubBlock = floor((totalTrials/subBlocks)/4);
remainder = totalTrials - RepsPerSubBlock * numConditions * subBlocks;
%%
% foreach of n submatrix
numbers = 1:4;
for subblock = 1:numConditions
    indexToRemove = randi(length(numbers));
    removedNumber = numbers(indexToRemove);
    numbers(indexToRemove) = [];
    submatrix = [repmat([1 2 3 4], 1, RepsPerSubBlock) removedNumber];
    newsubmatrix = submatrix(randperm(length(submatrix)));
    startIndex = (subblock - 1) * trialsPerSubBlock + 1;
    endIndex = subblock*trialsPerSubBlock;
    designMatrix(startIndex:endIndex, 1) = newsubmatrix;
end

% Display the design matrix
disp('Experimental Design Matrix:');
disp(designMatrix);
hist(designMatrix);
% add a random 1, 2, 3 or 4
% random permute
%put on start and endindex
% Randomly shuffle the conditions for each block
% for block = 1:(totalTrials / trialsPerBlock)
%     conditions = randperm(numConditions);
%     startIndex = (block - 1) * trialsPerBlock + 1;
%     endIndex = block * trialsPerBlock;
%     
%     % Assign conditions to trials in the block
%     designMatrix(startIndex:endIndex, 1) = repmat(conditions, 1, trialsPerBlock / numConditions);
% end

% Assign trial numbers
%designMatrix(:, 1) = 1:totalTrials;

