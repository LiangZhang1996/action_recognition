%% test
filename = "your video name";
video = readVideo(filename);
numFrames = size(video,4);
figure
for i = 1:numFrames
    frame = video(:,:,:,i);
    imshow(frame/255);
    drawnow
end
video = centerCrop(video,inputSize);
YPred = classify(net,{video})


