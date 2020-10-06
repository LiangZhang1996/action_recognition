%% test the video, make them can be read successfully

%% get the file name
Path = './hmdb51_org/';
Folder = dir(fullfile(Path,'*'));
n = length(Folder);
% store the file
Files = cell(n-2,1);
for i=3:n
   Files{i-2} =  dir(fullfile([Path,Folder(i).name,'/'],'*.avi'));  
end
%% read the .avi file 
for i=1:n-2
    file = {Files{i}.name}';
    m = length(file);
    Path1 = [Path,Folder(i+2).name,'/'];
    for j=1:m
        fname = [Path1,file{j}];
        obj = VideoReader(fname);
    end
end
        
