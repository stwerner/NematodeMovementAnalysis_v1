% Save tiff files in hdf5 container fromat
%
% This allows to have a single file (and thus faster transfer).
% Loading the h5 files was 2.5x faster than loading tif files
% Further speed advantages when loading could come from the option to load
% multiple files together. It is also possible to load just a subsection of
% the image. (A multi-page tif file has a size constraint and is actually 
% slower to load.)
% SW, 01/05/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear variables

%% Specify path to data and output folder for cropped images
datapath='InputTiff\Data1\'; %image location
fileout='Data1.h5'; %output folder

%% Find all image files in image location
filelist=dir([datapath,'*.tiff']); %maybe they are called .tif!
fileN=size(filelist,1);

%% Put file names in the right order [just run it to be save]
sortlist=nan(1,fileN);
for i=1:fileN
    pos1=strfind(filelist(i).name,'_');
    pos1=pos1(end)+1;
    pos2=strfind(filelist(i).name,'.')-1;
    sortlist(i)=str2double(filelist(i).name(pos1:pos2));
end
filelistunsorted=filelist;
sortlistmin=min(sortlist)-1;
filelist(sortlist-sortlistmin)=filelistunsorted;

%% Save in h5 file
im1=imread([datapath,filelist(1).name]);
imH=size(im1,1);
imW=size(im1,2);
tic;
h5create(fileout,"/data",[imH imW fileN],'Datatype','uint8') %create file
for i=1:fileN
    im1=imread([datapath,filelist(i).name]);
    h5write(fileout,"/data",im1,[1 1 i],[imH imW 1])
end
toc;

