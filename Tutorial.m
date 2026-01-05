% Tutorial on extracting worm shapes over time
% SW, 24/12/26
%%%%%%

clear variables

%% --- Crop tiff file to worm path and save it as h5
inputpath = 'InputTiff\';
outputpath = 'OutputFolder\';
imthr = 10; %specify threshold for object detection
inspectrate = 300; %rate for inspecting worm movement
% The user will first be presented with the background-subtracted intensity
% plot to inspect whether the threshold is set correctly. Afterwards, can
% extract one or multipe region(s) of interest containing the worm path(s).
% If the time steps are too large the inspection rate can be adjusted. In
% our example the frame rate is 30Hz, which means we use worm images from
% every 10s. The outputs are h5-files, one for each region of interest.
Crop2PathTiff2H5(inputpath,outputpath,imthr,inspectrate);
% %% Inspect individual frames of inidividual h5-files, e.g. frame 8000
% [imH, imW, ~] = DataSizeh5('OutputFolder\Data1-2219-1538.h5');
% im1=h5read('OutputFolder\Data1-2219-1538.h5','/data',[1,1,8000],[imH,imW,1]);
% figure(1), clf
% imshow(im1)

%% --- Extract image background
dataid='Data1';
[imagebg,diffimage,inputfile]=ExtractBackground(outputpath,dataid, 25);
figure(1), clf, imshow(imagebg), title('Background')
%% Inspect result in individual image, either as grayscale image
figure(1), clf, imshow(mat2gray(diffimage(:,:,1)))
%% or as intensity plot
figure(1), clf, surf(diffimage(:,:,70)), shading interp

%% --- Extract all objects, which might be worms
intensethr=10; %intensity threshold to identify objects
sizethr=30; %remove small objects below this threshold
Nworms=10; %expected number of worms in recording
stepsize=1; %for sub-sampling frames, otherwise set 1, do first large steps as a test
IdentifyWorms(inputfile,outputpath,imagebg,intensethr,sizethr,Nworms,stepsize)

%% --- Inspect tracking result and associate with worms
clear variables
inputpath='OutputFolder\';
dataid='Data1';
inputfile=pathfromfileid(inputpath,['TrackResultRaw-',dataid],'mat');
load(inputfile)
Nworms=size(wormxpos,1); Ntimep=size(wormxpos,2);
imH=size(imagebg,1); imW=size(imagebg,2);
inputdata=pathfromfileid(inputpath,dataid,'h5');
%% Quality checks (tracking)
im1=h5read(inputdata,'/data',[1,1,1],[imH,imW,1],[1,1,1]);
diffimage=imcomplement(im1)-imcomplement(imagebg);
figure(1), clf, imshow(mat2gray(diffimage))
hold on, plot(wormxpos(:),wormypos(:),'.')
%% Quality checks (worm sizes)
figure(1), clf
plot(wormsizes','.')
legend
%% Remove small objects/worms, which are likely misidentifications or strong body bends
%[Run only once]
sizethr2=350;
wormxpos(wormsizes<sizethr2)=nan; wormypos(wormsizes<sizethr2)=nan;
wormsizes(wormsizes<sizethr2)=nan;
wormsizes(sum(isnan(wormypos),2)==Ntimep,:)=[];
wormxpos(sum(isnan(wormypos),2)==Ntimep,:)=[];
wormypos(sum(isnan(wormypos),2)==Ntimep,:)=[];
Nworms=size(wormxpos,1); Ntimep=size(wormxpos,2);
%% Track worm identity (first only adjacent time points)
[xsort, ysort, sizesort, distoutput]=TrackAdjacentTimepoints(wormxpos, wormypos, ...
    wormsizes, Nworms, Ntimep);
%Quality checks (temporal sorting)
im1=h5read(inputdata,'/data',[1,1,1],[imH,imW,1],[1,1,1]);
diffimage=imcomplement(im1)-imcomplement(imagebg);
figure(1), clf, imshow(mat2gray(diffimage))
for i=1:Nworms
    hold on, plot(xsort(i,:),ysort(i,:),'.')
end
legend
%% Identify typical movement distance between frames
figure(1), clf
semilogy(distoutput','o')
legend
%% Merging of split worms
distthr1=10;
[xsort, ysort, sizesort, transpoints]=MergeSplitWorms(distthr1,xsort,ysort, ...
    sizesort, Nworms, Ntimep);
%Quality checks (temporal sorting)
im1=h5read(inputdata,'/data',[1,1,1],[imH,imW,1],[1,1,1]);
diffimage=imcomplement(im1)-imcomplement(imagebg);
figure(1), clf, imshow(mat2gray(diffimage))
for i=1:Nworms
    hold on, plot(xsort(i,:),ysort(i,:),'.')
end
legend
%% Identify threshold for cutting out large sizes, corresponding to touching worms
% [currently only global!]
% Manually check all worms to identify threshold
sizethr1=700;
figure(1), clf
for i=1:Nworms
    subplot(2,5,i)
    plot(sizesort(i,:),'-')
    hold on, plot([1,Ntimep],[1,1]*sizethr1)
    axis tight, title(['Worm',num2str(i)]), ylim([0,inf])
end
%% Remove large objects (typically collisions or turns, only run once) 
xsort(sizesort>sizethr1)=nan; ysort(sizesort>sizethr1)=nan;
sizesort(sizesort>sizethr1)=nan;
xsort(sum(isnan(xsort),2)==Ntimep,:)=[]; ysort(sum(isnan(xsort),2)==Ntimep,:)=[];
sizesort(sum(isnan(xsort),2)==Ntimep,:)=[];
Nworms=size(xsort,1); transpoints=isnan(xsort(:,2:end))-isnan(xsort(:,1:end-1));
%% Inspect the distribution of intervals of continuous tracking
allstretches=ContIntervalLengths(transpoints);
figure(1), clf, plot(sort(allstretches),'o')
xlabel('Continuously tracked objects'), ylabel('Tracked interval length')
ylim([0, inf])
%% Actually extract individual time pieces
allstretchthr=200; %choose threshold
[Npieces,xpiece,ypiece,sizepiece,startpiece]=...
    ExtractContinuousPiece(allstretches,allstretchthr,transpoints,xsort,ysort,sizesort);
%removelist=[];
%Inspect result (all time traces)
im1=h5read(inputdata,'/data',[1,1,1],[imH,imW,1],[1,1,1]);
diffimage=imcomplement(im1)-imcomplement(imagebg);
figure(1), clf, imshow(mat2gray(diffimage)), hold on
plot(xpiece',ypiece','.')
legend
%In this example, we see that there are 10 worms but 11 time intervals
%If we had chosen a larger threshold, there would have been only one
%interval per worm. Yet, now we have to manually link two intervals.
%% Generate start, duration, and end times for each object
disp('Start frame:')
disp(startpiece')
disp('Length:')
disp(sum(~isnan(ypiece),2)')
disp('End:')
disp(startpiece'+sum(~isnan(ypiece),2)'-1)
%This example is easy. Only object 10 starts later than the first frame.
%From the remaining objects, only object 9 is not tracked till the end. So,
%object 9 and 10 is the same worm, which is tracked from frame 1 till 445
%and again from frame 658 till the end. 
%% Especially if there are collisions between worms, one might want to zoom in
mywormchoice=[9,10];
mwclen=size(mywormchoice,2); x1=inf; x2=0; y1=inf; y2=0;
for i=201:20:1200 %specify time points
    myhandle = zeros(1,mwclen);
    im1=h5read(inputdata,'/data',[1,1,i],[imH,imW,1],[1,1,1]);
    diffimage=imcomplement(im1)-imcomplement(imagebg);
    figure(1), clf, imshow(mat2gray(diffimage)), hold on
    for j=1:mwclen
        mych=mywormchoice(j);
        myhandle(1)=plot(xpiece(mych,:),ypiece(mych,:));
        if min(xpiece(mych,:))<x1, x1=min(xpiece(mych,:)); end
        if max(xpiece(mych,:))>x2, x2=max(xpiece(mych,:)); end
        if min(ypiece(mych,:))<y1, y1=min(ypiece(mych,:)); end
        if max(ypiece(mych,:))>y2, y2=max(ypiece(mych,:)); end
        plot(xpiece(mych,1),ypiece(mych,1),'or')
    end
    xlim([max(x1-50,1),min(x2+50,imW)]), ylim([max(y1-50,1),min(y2+50,imH)])
    title(i)
    pause(0.5)
end
%% Potentially remove objects that are not worms [Only run once!!!!]
%removelist=[13];
xpiece(removelist,:)=[];
ypiece(removelist,:)=[];
sizepiece(removelist,:)=[];
Npieces=size(xpiece,1);
startpiece(removelist)=[];
%% otherwise specify
removelist=[];
%% Define a vector, which associates objects
%[1;1;0]: piece 1 is worm 1; piece 2 is worm 1; piece 3 is left out
%note that removing worms will change piece order
linkvec=[1;2;3;4;5;6;7;8;9;9;10];
%% Save results
hsize=60;
for mych=1:Npieces
    namepos=strfind(inputdata,'-');
    CMtrack=[xpiece(mych,:)',ypiece(mych,:)'];
    save([inputdata(1:namepos(1)-1),'W',num2str(mych),'CMtrack.mat'],...
        "CMtrack")
end
save([inputdata(1:namepos(1)-1),'Para.mat'],"sizethr2","distthr1",...
    "sizethr1","allstretchthr","removelist","startpiece","hsize","linkvec")

%% --- Save continuously tracked intervals cropped to worm h5
clear variables
inputpath='OutputFolder\'; dataids={'Data1'}; %multiple data sets possible
Crop2WormH5(inputpath,dataids);


%% --- Extract skeleton and perimeter from tracked worms
clear variables
inputpath = 'OutputFolder\'; %Specify input data
num = 200;      %number of points along the perimeter
usamp = 10;     %undersampling rate for the calculation of the curvature
thresholdskel = 0.5; %parameter to find the skeleton
delta = 0.01;        %adjustment of skeleton skeleton points
dataids={'Data1'}; %multiple data sets possible {...; ...}
ExtractSkeleton(inputpath,dataids,num,usamp,thresholdskel,delta)

%% --- Combine tracked pieces belonging to the same worm
clear variables
inputpath = 'OutputFolder\'; %Specify input data
dataids={'Data1'}; %multiple data sets possible {...; ...}
fileN=1800;
CombineContinuousPieces(inputpath,dataids,fileN)















