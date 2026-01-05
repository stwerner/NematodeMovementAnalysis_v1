% Crop frames to tracked worms and save as h5-files
%
% Input:
% - folder with the files
% - structure with data set IDs [multiple data sets can be processed]
%
% Output:
% - none but generates h5-files
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Crop2WormH5(inputpath,dataids)

dataidslen=size(dataids,1);

for dataidi = 1:dataidslen
    dataid=dataids{dataidi};
    load([inputpath,'TrackResultRaw-',dataid,'.mat'])
    load([inputpath,dataid,'Para.mat'])
    Npieces=size(startpiece,1);
    imH=size(imagebg,1); imW=size(imagebg,2);
    inputdata=pathfromfileid(inputpath,[dataid,'-'],'h5');
    disp(['Running: ',dataid])
    tic;
    for mych=1:Npieces
        outputfile=[inputpath,dataid,'W',num2str(mych),'.h5'];
        load([inputpath,dataid,'W',num2str(mych),'CMtrack.mat']);
        xpiece=CMtrack(:,1); ypiece=CMtrack(:,2);
        pieceN=sum(~isnan(ypiece));
        h5create(outputfile,"/data",[2*hsize+1 2*hsize+1 pieceN],...
            'Datatype','uint8')
        for i = 1:pieceN
            im1=h5read(inputdata,'/data',...
                [1,1,(i+startpiece(mych)-1)*stepsize],[imH,imW,1]);
        
            wormxpos=round(xpiece(i)); wormypos=round(ypiece(i));
            im3=uint8(zeros(2*hsize+1, 2*hsize+1));
        
            flag=0;
            if wormxpos<hsize+1, dx=wormxpos-1;
                flag=10;
            elseif wormxpos>imW-hsize, dx=imW-wormxpos;
                flag=20;
            else, dx=hsize;
            end
            if wormypos<hsize+1, dy=wormypos-1;
                flag=flag+1;
            elseif wormypos>imH-hsize, dy=imH-wormypos;
                flag=flag+2;
            else, dy=hsize;
            end
        
            temp=im1(wormypos-dy:wormypos+dy,wormxpos-dx:wormxpos+dx);
            if flag==0, im3=temp;
            elseif flag==1, im3(end-size(temp,1)+1:end,:)=temp;
            elseif flag==2, im3(1:size(temp,1),:)=temp;
            elseif flag==10, im3(:,end-size(temp,2)+1:end)=temp;
            elseif flag==20, im3(:,1:size(temp,2))=temp;
            elseif flag==11, im3(end-size(temp,1)+1:end,end-size(temp,2)+1:end)=temp;
            elseif flag==12, im3(1:size(temp,1),end-size(temp,2)+1:end)=temp;
            elseif flag==21, im3(end-size(temp,1)+1:end,1:size(temp,2))=temp;
            elseif flag==22, im3(1:size(temp,1),1:size(temp,2))=temp;
            end
        
            h5write(outputfile,"/data",im3,[1 1 i],[2*hsize+1 2*hsize+1 1])
        
            if mod(i,100)==0, disp(i); toc; end
        end
        toc;
    end
end


end
