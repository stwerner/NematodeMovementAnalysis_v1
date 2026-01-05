% Extracts worm skeletons and ratio area/perimeter
%
% Input:
% - folder with the files
% - structure with data set IDs [multiple data sets can be processed]
% - number of points along the perimeter
% - undersampling rate for the calculation of the curvature
% - parameter to find the skeleton
% - adjustment of skeleton skeleton points
%
% Output:
% - none but generates h5-files
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function ExtractSkeleton(inputpath,dataids,num,usamp,thresholdskel,delta)

dataidslen=size(dataids,1);

for dataidi = 1:dataidslen
    dataid=dataids{dataidi};
    load([inputpath,'TrackResultRaw-',dataid,'.mat'])
    load([inputpath,dataid,'Para.mat'])
    Npieces=size(startpiece,1);
    disp(['Running: ',dataid])
    tic;
    for mych=1:Npieces
        myfileinfo=h5info([inputpath, dataid,'W',num2str(mych),'.h5'],"/data");
        imH=myfileinfo.Dataspace.Size(1);
        imW=myfileinfo.Dataspace.Size(2);
        fileN=myfileinfo.Dataspace.Size(3);
        im1all=h5read([inputpath,dataid,'W',num2str(mych),'.h5'],'/data',...
                [1,1,1],[imH,imW,fileN],[1,1,1]); %load all images
        load([inputpath,dataid,'W',num2str(mych),'CMtrack.mat'])

        tic;

        skeletonx=nan(fileN,round(num/2)); skeletony=nan(fileN,round(num/2));
        thcurv=nan(fileN,2);
        ratiotest=nan(fileN,1);
        for i=1:fileN
            wormxpos=round(CMtrack(i,1)); wormypos=round(CMtrack(i,2));
            im1=im1all(:,:,i);
            imagebg1=imagebg(wormypos-hsize:wormypos+hsize,wormxpos-hsize:wormxpos+hsize);
            diffimage=imcomplement(im1)-imcomplement(imagebg1);
            im2=medfilt2(diffimage,[3,3]);
            im2=imgaussfilt(im2,1);
            im2(im2<intensethr)=0;
            bw1=edge(im2,'Canny');
            bw1=bwareaopen(bw1,50);
            bw2=imerode(imfill(imdilate(bw1,strel("disk",3)),'holes'),strel("disk",3));
        
            [BWL,BWLn]=bwlabel(bw2); 
            currmaxsize=0; currj=0;
            for j=1:BWLn
                wormonly=(BWL==j);
                temp=sum(sum(wormonly));
                if temp>currmaxsize
                    currmaxsize=temp;
                    currj=j;
                end
            end
            bw3=(BWL==currj);
            bound = bwboundaries(bw3); bound=bound{1};
            if(~(bound(1,1)==bound(end,1))||~(bound(1,2)==bound(end,2)))
                bound1=[bound;bound(1,:)];
            else, bound1=bound;
            end
        
            boundlength=sum(sqrt(sum((bound1(2:end,:)-bound1(1:end-1,:)).^2,2)));
            ratiotest(i)=currmaxsize/boundlength;
        
            bound1=myinterpolfunction(bound1(:,1),bound1(:,2),num,'pchip');
            bound2=[bound1(end-2*usamp:end-1,:);bound1;bound1(2:2*usamp,:)];
            curv = zeros(1,length(bound1)-1);
            for j = 2*usamp+1:length(bound1)+2*usamp-1
                yp = bound2(j+usamp,1) - bound2(j-usamp,1);
                ypp = bound2(j+2*usamp,1)-2*bound2(j,1)+bound2(j-2*usamp,1);
                xpp = bound2(j+2*usamp,2)-2*bound2(j,2)+bound2(j-2*usamp,2);
                xp = bound2(j+usamp,2) - bound2(j-usamp,2);
                curv(j-2*usamp) = -((yp*xpp-xp*ypp)/(sqrt(yp^2+xp^2))^3);
            end
            filtersize = round(num/10)-1+mod(round(num/10),2);
            curvgolay = smooth([curv(end-filtersize+1:end)'; curv';...
                curv(1:filtersize)'],filtersize,'sgolay',3);
            curv = curvgolay(filtersize+1:end-filtersize,:)';
            %Tail position is position of largest curvature
            [tcurvtemp, tpos] = max(curv);
            curvord=[curv(tpos:end) curv(1:tpos-1)]; %sort from tail on
                        
            % Sort boundary starting from the tail
            boundord=[bound1(tpos:end-1,:); bound1(1:tpos-1,:)];
            
            %set the curvature values around tpos to be zero
            curvt = curvord;
            curvt(1:round(num/5)) = 0;
            curvt(end-round(num/5):end) = 0;
            %find the head position by finding the max curv of the rest
            [hcurvtemp, hpos] = max(curvt);
        
            if i==1
                thvecx = boundord(1,2)-boundord(hpos,2);
                thvecy = boundord(1,1)-boundord(hpos,1);
                thvecnorm=sqrt(thvecx^2+thvecy^2);
                thvecx=thvecx/thvecnorm;
                thvecy=thvecy/thvecnorm;
                thcurv(i,:)=[tcurvtemp,hcurvtemp];
            else
                thvecxN = boundord(1,2)-boundord(hpos,2);
                thvecyN = boundord(1,1)-boundord(hpos,1);
                thvecnorm=sqrt(thvecxN^2+thvecyN^2);
                thvecxN=thvecxN/thvecnorm;
                thvecyN=thvecyN/thvecnorm;
                if (thvecx*thvecxN+thvecy*thvecyN)<0
                    boundord = [boundord(hpos:end,:); boundord(1:hpos-1,:)];
                    hpos = size(boundord,1)-hpos+2;
                    thvecx = boundord(1,2)-boundord(hpos,2);
                    thvecy = boundord(1,1)-boundord(hpos,1);
                    thvecnorm=sqrt(thvecx^2+thvecy^2);
                    thvecx=thvecx/thvecnorm;
                    thvecy=thvecy/thvecnorm;
                    thcurv(i,:)=[hcurvtemp,tcurvtemp];
                else, thvecx = thvecxN; thvecy = thvecyN;
                    thcurv(i,:)=[tcurvtemp,hcurvtemp];
                end
            end
            
            %create 2 vectors for the 2 sides
            side1 = boundord(1:hpos,:);
            side0 = boundord(end:-1:hpos+1,:);
        
            % Find the body midline:
            % Searching for points inside the worm that have the
            % distance 'thresholdskel' to the boundaries
            [row, col] = find(bw3);
            pointsinside = [row col]; %points inside the worm
            skelpoints = nan(length(pointsinside),2);  skelcounter=1;
            for j = 1:length(pointsinside)
                ro = pointsinside(j,1);
                co = pointsinside(j,2);
                %find out minimum distance from side 1
                diff1y = ro - side1(:,1);
                diff1x = co - side1(:,2);
                diff1 = sqrt(diff1x.^2 + diff1y.^2);
                [min1v, min1pos]= min(diff1);
                %find out minimum distance from side 0
                diff0y = ro - side0(:,1);
                diff0x = co - side0(:,2);
                diff0 = sqrt(diff0x.^2 + diff0y.^2);
                [min0v, min0pos]= min(diff0);
                %find straight distance between the two boundary points
                dist12 = sqrt((side1(min1pos,1)-side0(min0pos,1))^2+...
                    (side1(min1pos,2)-side0(min0pos,2))^2);
            
                % Compare the distances to both sides:
                % if they are approximately equal (difference below
                % thresholdskel) and the straight distance is not so
                % much different from the sum of those and if they are
                % larger than 4 pixel, move the skeleton point and
                % search for most accurate position
                if abs(min1v - min0v)<thresholdskel...
                        && abs(min1v + min0v - dist12)<2*thresholdskel...
                        && min1v>1 && min0v>1
                    tr = ro;
                    tc = co;
                    tminv = abs(min1v - min0v);
                    tdiff01 = zeros(9,1); ty = zeros(9,1); tx = zeros(9,1);
                    while tminv > delta*2
                          counter = 0;
                          for l = -1:1
                          for m = -1:1
                              counter = counter+1;
                              ty(counter) = tr+(l*delta);
                              tx(counter) = tc+(m*delta);
                              %find out minimum distance from side 1
                              tdiff1y = ty(counter) - side1(min1pos,1);                  
                              tdiff1x = tx(counter) - side1(min1pos,2);
                              tdiff1 = sqrt(tdiff1x.^2 + tdiff1y.^2);
                              %find out minimum distance from side 0
                              tdiff0y = ty(counter) - side0(min0pos,1);
                              tdiff0x = tx(counter) - side0(min0pos,2);
                              tdiff0 = sqrt(tdiff0x.^2 + tdiff0y.^2);
                              tdiff01(counter) = abs(tdiff0 - tdiff1);
                          end
                          end
                          [tminv, tminpos]= min(tdiff01);  
                          tr = ty(tminpos);
                          tc = tx(tminpos);
                    end
                    skelpoints(skelcounter,:) = [tr tc];
                    skelcounter = skelcounter+1;
                end
            end
            if skelcounter>5 %has to find at least 6 skeleton points
                skelpoints(skelcounter:end,:) = [];
                % Sort the skeleton elements by starting from the tail and
                % finding the nearest neighbor, delete dublicated positions
                skeleton = sortingskeleton(skelpoints, boundord(1,:),...
                            boundord(hpos,:));
                
                % Interpolate the skeleton
                skeleton = myinterpolfunction(skeleton(:,1), skeleton(:,2),...
                    round(num/2)-1,'pchip');
                
                skeletonx(i,:) = skeleton(:,2)';
                skeletony(i,:) = skeleton(:,1)';
            
            % figure(1), clf
            % imshow(bw3), hold on
            % plot(bound1(:,2), bound1(:,1), 'r', 'LineWidth', 2)
            % plot(skeleton(:,2),skeleton(:,1), 'g', 'LineWidth', 2)
            % pause
        
            end

            if mod(i,100)==0, disp(i); toc; end

            % figure(1), clf
            % imshow(im1)
            % hold on, plot(bound1(:,2),bound1(:,1),'r','Linewidth', 2)
            % surf(im1.*uint8(bw2)), shading interp


        end
        
        toc;
        % Save result
        save([inputpath,dataid,'W',num2str(mych),'Skel.mat'],...
            "ratiotest","thcurv","skeletonx","skeletony")

    end

end

end