%% Discribe of this script.
 % 1. Read in the '.avi' and reshape the video frames;
 % 2. Use pretrained googlenet extract features about the video of each frame, generate sequenced features;
 %    save these sequences as .mat file , This take much time;
 % 3. Then use LSTM networks train the sequence data;
 % 4. Evaluate the result.

%% Load pretrained googlenet
netCNN = googlenet;

%% Load the Data
dataFolder = "hmdb51_use";% the file contains the .avi 
[files,labels] = hmdb51Files(dataFolder);

%% Convert Frames to Feature Vectors with googlenet
inputSize = netCNN.Layers(1).InputSize(1:2);
layerName = "pool5-7x7_s1";

tempFile = fullfile('./',"hmdb51_org.mat");% the file contains sequence data, takes much time;

if exist(tempFile,'file') % decide the training data at the first time
    load(tempFile,"sequences")
else
    numFiles = numel(files);
    sequences = cell(numFiles,1);    
    for i = 1:numFiles
        fprintf("Reading file %d of %d...\n", i, numFiles)
        % read and reshape video
        video = readVideo(files(i));
        video = centerCrop(video,inputSize);
        % extract the features 
        sequences{i,1} = activations(netCNN,video,layerName,'OutputAs','columns');
    end   
    save(tempFile,"sequences","-v7.3");% save the sequece feature
end

%% Training Data
numObservations = numel(sequences);
% random split
idx = randperm(numObservations);
N = floor(0.9 * numObservations);
% train data
idxTrain = idx(1:N);
TrainX = sequences(idxTrain);
TrainY = labels(idxTrain);
% validation data
idxValidation = idx(N+1:end);
ValidationX = sequences(idxValidation);
ValidationY = labels(idxValidation);

%% Create LSTM Network
numFeatures = size(TrainX{1},1);
numClasses = numel(categories(TrainY));
% define the layers
layers = [
    sequenceInputLayer(numFeatures,'Name','sequence')
    bilstmLayer(2000,'OutputMode','last','Name','bilstm')
    dropoutLayer(0.5,'Name','drop')
    fullyConnectedLayer(numClasses,'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];

%% Training Options
miniBatchSize = 16;
numObservations = numel(TrainX);
numIterationsPerEpoch = floor(numObservations / miniBatchSize);
options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',1e-4, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{ValidationX,ValidationY}, ...
    'ValidationFrequency',numIterationsPerEpoch, ...
    'Plots','training-progress', ...
    'Verbose',false);

%% Train LSTM NetWork
[netLSTM,info] = trainNetwork(TrainX,TrainY,layers,options);

%% Tset the accuracy
YPred = classify(netLSTM,ValidationX,'MiniBatchSize',miniBatchSize);
YValidation = ValidationY;
% the accuracy
accuracy = mean(YPred == YValidation);
disp(accuracy)


