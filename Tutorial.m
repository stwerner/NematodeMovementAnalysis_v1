% Tutotorial
%%%%%%

clear variables

%% Crop tiff file to worm path and save it as h5
inputpath = 'InputTiff\';
outputpath = 'OutputFolder\';
imthr = 10; %specify threshold for object detection
inspectrate = 300; %rate for inspecting worm movement
% The user will first be presented with the background-subtracted intensity
% plot to inspect whether the threshold is set correctly. Afterwards, can
% extract one or multipe window(s) of interesting containing the worm path.
% If the time steps are too large the inspection rate can be adjusted. In
% our example the frame rate is 30Hz, which means we use worm images from
% every 10s.
Crop2PathTiff2H5(inputpath,outputpath,imthr,inspectrate);

%%