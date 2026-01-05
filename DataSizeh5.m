% Extracts frame height, width and number of frames from a recording saved
% as h5-file
%
% Input:
% - data path
%
% Output:
% - frame height, width and number of frames
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [imH, imW, fileN] = DataSizeh5(inputdata)

myfileinfo=h5info(inputdata,"/data"); %Load data info
imH=myfileinfo.Dataspace.Size(1);
imW=myfileinfo.Dataspace.Size(2);
fileN=myfileinfo.Dataspace.Size(3);

end