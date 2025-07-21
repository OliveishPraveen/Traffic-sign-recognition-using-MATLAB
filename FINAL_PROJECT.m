% Define the dataset folder path
dataFolder = 'C:\Users\namde\OneDrive\Desktop\Image_Processing\GTSRB';

% Check if the folder exists
if ~isfolder(dataFolder)
    error('The folder specified in dataFolder does not exist. Please check the path.');
end

% Display dataset validation process
disp('Creating and validating ImageDatastore...');
imds = validateAndCleanImageDatastore(dataFolder);

% Define the desired input size for resizing
inputSize = [32 32];

% Set the ReadFcn to resize images
imds.ReadFcn = @(loc) imresize(imread(loc), inputSize);

% Split into training and testing datasets
[trainSet, testSet] = splitEachLabel(imds, 0.8, 'randomized');

% Assign the same ReadFcn to training and testing sets
trainSet.ReadFcn = imds.ReadFcn;
testSet.ReadFcn = imds.ReadFcn;

% Display label counts in training and testing sets
disp('Training Set:');
disp(countEachLabel(trainSet));

disp('Testing Set:');
disp(countEachLabel(testSet));

% Verify image sizes in training and testing datasets
disp('Verifying image sizes...');
verifyImageSizes(trainSet, inputSize, 'Training');
verifyImageSizes(testSet, inputSize, 'Testing');

% Test a random sample image from the training set
sampleIndex = randi(numel(trainSet.Files));
sampleImg = readimage(trainSet, sampleIndex);
imshow(sampleImg);
title('Sample Training Image');

% Define CNN architecture
disp('Defining CNN architecture...');
numClasses = numel(categories(trainSet.Labels)); % Determine the number of unique classes
layers = [
    imageInputLayer([32 32 3], 'Name', 'InputLayer')
    convolution2dLayer(3, 8, 'Padding', 'same', 'Name', 'Conv1')
    batchNormalizationLayer('Name', 'BatchNorm1')
    reluLayer('Name', 'ReLU1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'MaxPool1')
    convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'Conv2')
    batchNormalizationLayer('Name', 'BatchNorm2')
    reluLayer('Name', 'ReLU2')
    fullyConnectedLayer(numClasses, 'Name', 'FullyConnected') % Updated number of neurons
    softmaxLayer('Name', 'Softmax')
    classificationLayer('Name', 'Output')];
% Visualize and verify the architecture
disp('Analyzing network...');
analyzeNetwork(layers);

% Prepare training options
options = trainingOptions('adam', ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 5, ...
    'MiniBatchSize', 32, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', true, ...
    'Plots', 'training-progress');

% Train the network
disp('Training the network...');
net = trainNetwork(trainSet, layers, options);

% Evaluate the network on the testing set
disp('Evaluating the network...');
predictedLabels = classify(net, testSet);
actualLabels = testSet.Labels;

% Calculate accuracy
accuracy = sum(predictedLabels == actualLabels) / numel(actualLabels);
disp(['Accuracy on the testing set: ', num2str(accuracy * 100), '%']);

% --- Supporting Functions ---

function imds = validateAndCleanImageDatastore(folder)
    % Validate and clean ImageDatastore by removing corrupted files
    imds = imageDatastore(folder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    allFiles = imds.Files;
    validFiles = {};
    for i = 1:numel(allFiles)
        try
            % Try reading the file
            imread(allFiles{i});
            validFiles{end + 1} = allFiles{i}; % Add valid files
        catch
            % Log and skip corrupted files
            fprintf('Corrupted file removed: %s\n', allFiles{i});
        end
    end
    % Create a new datastore with valid files
    imds = imageDatastore(validFiles, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
end

function verifyImageSizes(dataStore, inputSize, setName)
    % Verify image sizes in the datastore
    imgs = readall(dataStore);
    isCorrectSize = all(cellfun(@(img) isequal(size(img, 1:2), inputSize), imgs));
    if isCorrectSize
        disp([setName ' dataset: All images are correctly resized to ' num2str(inputSize(1)) 'x' num2str(inputSize(2)) '.']);
    else
        disp([setName ' dataset: Some images are not correctly resized!']);
    end
end