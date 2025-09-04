% Crop C. elegans recordings to worm path by user input to specify region
% of interest.
% Input: folder with subfolders of tiff files corresponding recordings
% Output: h5 files
% SW, 10/04/24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Crop2PathTiff2H5(inputpath,outputpath,imthr,inspectrate)

%% Find all image folders in input path
mkdir(outputpath);
dinfo = dir(inputpath);
dinfo(ismember( {dinfo.name}, {'.', '..'})) = [];
dirFlags = [dinfo.isdir]; % Extract only those that are directories.
allfolders = dinfo(dirFlags);
allfoldersN = size(allfolders,1);

%% Choose ROI for each recording
icount=0;
wormlog=[];
while icount<allfoldersN
    icount=icount+1;
    datapath = [inputpath,allfolders(icount).name,'\'];

    %% Find all image files in image location
    filelist=dir([datapath,'*.tiff']);
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

    %% Compute background
    %This is done by taking the median pixel intensity of 5 frames, between
    %which the worm position should not overlap. The frames are specified as
    %1*mystep, 2*mystep, ... 5*mystep with mystep being chosen appropriately
    %(depending on the total number of frames). Check overlap between worms!
    mystep=round(fileN/4);
    mysteps=[1,mystep,2*mystep,3*mystep,fileN];
    im1=imread([datapath,filelist(1).name]);
    Nrow=size(im1,1); Ncol=size(im1,2);
    imagebggroup=nan(Nrow,Ncol,5);
    for i=1:5
        imagebggroup(:,:,i)=imread([datapath,filelist(mysteps(i)).name]);
    end
    imagebg=uint8(median(imagebggroup,3));

    %% Inspect worm allocation
    im1=imread([datapath,filelist(1).name]);
    diffimage=imcomplement(im1)-imcomplement(imagebg);
    im2=medfilt2(diffimage,[3,3]);
    figure(1), clf, surf(im2), shading interp 
    view(2), title('Press enter to continue.')
    pause

    %% Check whether the image can be roughly cropped for processing
    combimage=zeros(Nrow,Ncol);
    for i=[1:inspectrate:fileN,fileN]
        im1=imread([datapath,filelist(i).name]);
        diffimage=imcomplement(im1)-imcomplement(imagebg);
        im2=medfilt2(diffimage,[3,3]);
        bw1=im2>imthr;
        combimage=combimage+bw1;
    end

    %% Choose region of interest
    figure(1), clf
    imshow(imcomplement(combimage))
    title('Click twice to select area.')
    [xval,yval]=ginput(2);
    xval=round(sort(xval)); yval=round(sort(yval));
    hold on, rectangle('Position',[xval(1),yval(1),diff(xval),diff(yval)])
    immask=combimage.*0;
    immask(yval(1):yval(2),xval(1):xval(2))=1;
    [pathrow,pathcol]=find(combimage.*immask);
    pathymin=min(pathrow)-100; pathxmin=min(pathcol)-100;
    pathymax=max(pathrow)+100; pathxmax=max(pathcol)+100;
    imH=size(combimage,1); imW=size(combimage,2);
    if ((pathymin<1)+(pathxmin<1)+(pathymax>imH)+(pathxmax>imW))==0
        wormlog=[wormlog; icount,pathymin,pathymax,pathxmin,pathxmax];
        title('Click inside if done / outside for another window.')
        [xvalok,yvalok]=ginput(1);
        if ((xvalok<xval(1))+(xvalok>xval(2))+(yvalok<yval(1))+(yvalok>yval(2)))>0
            icount=icount-1;
        end
    else
        error('Path too close to boundary. Consider tighter box.')
    end

end


%% Crop and save it
wormlogsize=size(wormlog,1);
for j=1:wormlogsize
    myra=wormlog(j,2:5);

    fileout=[outputpath,allfolders(wormlog(j,1)).name,...
        '-',num2str(myra(1)),'-',num2str(myra(3)),'.h5'];
    imH=myra(2)-myra(1)+1;
    imW=myra(4)-myra(3)+1;

    datapath = [inputpath,allfolders(wormlog(j,1)).name,'\'];

    % Find all image files in image location
    filelist=dir([datapath,'*.tiff']);
    fileN=size(filelist,1);

    % Put file names in the right order [just run it to be save]
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

    h5create(fileout,"/data",[imH imW fileN],'Datatype','uint8') %create file
    for i=1:fileN
        im1=imread([datapath,filelist(i).name],'PixelRegion',{myra(1:2),myra(3:4)});
        h5write(fileout,"/data",im1,[1 1 i],[imH imW 1])
        if mod(i,100)==0, disp([j,i]); end
    end

    copyfile([datapath,filelist(1).name],...
        [outputpath,allfolders(wormlog(j,1)).name,'Ref.tiff'])
end

end