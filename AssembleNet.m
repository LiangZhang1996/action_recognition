%% Build the new Network for video classification
% This is the follow-up of trainNet.m, it is base on the result of
% trainNet.m.
% Combine the googlenet(part) and LSTM for the new Network
%% drop layers of googlenet that afetr activations
cnnLayers = layerGraph(netCNN);
layerNames = ["data" "pool5-drop_7x7_s1" "loss3-classifier" "prob" "output"];
cnnLayers = removeLayers(cnnLayers,layerNames);

%% Add Sequence Iinput Layer
inputSize = netCNN.Layers(1).InputSize(1:2);
averageImage = netCNN.Layers(1).AverageImage;

inputLayer = sequenceInputLayer([inputSize 3], ...
    'Normalization','zerocenter', ...
    'Mean',averageImage, ...
    'Name','input');
layers = [
    inputLayer
    sequenceFoldingLayer('Name','fold')];
% add and connect layers
lgraph = addLayers(cnnLayers,layers);
lgraph = connectLayers(lgraph,"fold/out","conv1-7x7_s2");
%% Add LSTM Layers
lstmLayers = netLSTM.Layers;
lstmLayers(1) = [];
layers = [
    sequenceUnfoldingLayer('Name','unfold')
    flattenLayer('Name','flatten')
    lstmLayers];

lgraph = addLayers(lgraph,layers);
lgraph = connectLayers(lgraph,"pool5-7x7_s1","unfold/in");

lgraph = connectLayers(lgraph,"fold/miniBatchSize","unfold/miniBatchSize");
%% Assemble Network
analyzeNetwork(lgraph)
net = assembleNetwork(lgraph);
