% Identify all moving objects above a certain size, which might thus be
% worms
%
% Input:
% - path to input data
% - location where results are stored
% - background
% - intensity threshold for worms
% - size threshold for worms
% - expected number of worms
% - stepsize for sub-sampling [mainly for testing parameters]
%
% Output:
% - mat-file containing tracking results and parameters
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function IdentifyWorms(inputdata,outputpath,imagebg,intensethr,sizethr,Nworms,stepsize)

[imH, imW, fileN] = DataSizeh5(inputdata);

tic;
Nworms=Nworms*2;
Ntimep=floor((fileN-1)/stepsize)+1;
template1=repmat(1:imW,imH,1);
template2=repmat((1:imH)',1,imW);
wormsizes=nan(Nworms,Ntimep); %log worm size
wormxpos=nan(Nworms,Ntimep); %log center of mass position
wormypos=nan(Nworms,Ntimep);
disp('Currently processing:')
%only allows for fileN being multiples of 15 currently, needs to be fixed
%in future release. It's fine for our data with 30 fps!!!!!!!!!!!!!!!!!!!!
for k=1:floor(fileN/15/stepsize)
    currpos=15*stepsize*(k-1)+stepsize;
    im1=h5read(inputdata,'/data',[1,1,currpos],[imH,imW,15],[1,1,stepsize]);
    for i=1:15
        diffimage=imcomplement(im1(:,:,i))-imcomplement(imagebg);
        im2=medfilt2(diffimage,[3,3]);
        im3=imgaussfilt(im2,[3,3]);
        bw1 = im3>intensethr;
        bw2 = bwareaopen(bw1,sizethr);

        [BWL,BWLn]=bwlabel(bw2);
        wormsizelist=nan(1,BWLn);
        for j=1:BWLn
            wormsizelist(j)=sum(sum(BWL==j));
        end
        [~,sizeindex]=sort(wormsizelist,'descend');
        realNworms=min(BWLn,Nworms);
        sizeindex=sizeindex(1:realNworms);

        for j=1:realNworms
            bw3=(BWL==sizeindex(j));
            wormsizes(j,i+(k-1)*15)=sum(sum(bw3));
            temp=template1.*bw3;
            wormxpos(j,i+(k-1)*15)=sum(sum(temp))/wormsizes(j,i+(k-1)*15);
            temp=template2.*bw3;
            wormypos(j,i+(k-1)*15)=sum(sum(temp))/wormsizes(j,i+(k-1)*15);
        end

    end
    if mod(k,10)==1, disp(currpos); end
end
wormsizes(sum(isnan(wormypos),2)==Ntimep,:)=[];
wormxpos(sum(isnan(wormypos),2)==Ntimep,:)=[];
wormypos(sum(isnan(wormypos),2)==Ntimep,:)=[];
toc;
%Save result
t1=strfind(inputdata,'-'); t1=t1(1)-1;
t2=strfind(inputdata,'\'); t2=t2(end)+1;
save([outputpath,'TrackResultRaw-',inputdata(t2:t1),'.mat'],...
    "wormxpos","wormypos","wormsizes","imagebg","intensethr","sizethr","stepsize")

end