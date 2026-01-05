% Extracts background and background-subtracted frames
%
% Input:
% - path2file: path to the file location
% - dataid: part or the file name to identify it uniquely
% - sampinterval: interval at which data is sampled to compute background
%
% Output:
% - background without moving objects
% - all loaded images without background
% - input file
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [imagebg,diffimage,inputfile]=ExtractBackground(path2file,dataid, sampinterval)

inputfile=pathfromfileid(path2file,dataid,'h5');
[imH, imW, fileN] = DataSizeh5(inputfile);
%% Load every xth image to compute background
Nofframes=floor(fileN/sampinterval);
%structure: starting values, number of data points, intervals
imall=h5read(inputfile,'/data',[1,1,1],...
    [imH,imW,Nofframes],[1,1,sampinterval]);

imagebg=sort(imall,3); %Instead of median, 93% threshold, to allow worms to
imagebg=uint8(squeeze(imagebg(:,:,round(0.93*Nofframes)))); %not move most of the time
diffimage=imcomplement(imall)-imcomplement(imagebg(:,:,ones(1,Nofframes)));

end

