% Corrects for cases where the worm body is split
% This deals with the case that suddenly a second object comes into
% existence close to a worm, which is likely a part of this worm.
% This is different from a separation event of two worms because to be
% considered part of the same worm body, the two objects have to stay close
% the whole time.
%
% Input:
% - threshold to define what is close
% - xsort, ysort: x and y position
% - sizesort: size values
% - Nworms, Ntimep: number of worms and time points
%
% Output:
% - adjusted xsort, ysort, sizesort
% - transition time points where worms appear or disappear
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [xsort, ysort, sizesort, transpoints]=MergeSplitWorms(distthr1, ...
    xsort,ysort, sizesort, Nworms, Ntimep)

transpoints=isnan(xsort(:,2:end))-isnan(xsort(:,1:end-1));
openarray=zeros(1,Nworms); %logs for each track whether it is open (1) or closed (0)
for i=1:Ntimep-1 %all time points
    if sum(transpoints(:,i)==-1)>0 %does anything close? i.e. comes into existence
        openarray(transpoints(:,i)==-1)=0; %this one will be not open anymore
        for j=1:Nworms %all worms
            if transpoints(j,i)==-1 %only consider the worms which were closed
                klist=1:Nworms; klist(j)=[]; klist(openarray(klist)~=0)=[];
                klist(isnan(xsort(klist,i+1)))=[];
                distlist=ones(1,Nworms)*inf;
                for k=klist %go through all closed and compute distance
                    distlist(k)=(xsort(j,i+1)-xsort(k,i+1))^2+...
                        (ysort(j,i+1)-ysort(k,i+1))^2;
                end
                %idea: is there any existing (i.e. tracked) worm (i.e. not
                %open, openarray==0) in the viscinity to the one that comes
                %into existence?
                [mindistlist,mindistlistind]=min(distlist);
                if mindistlist<distthr1 %any other track close by for merging?
                    %find out which of these two tracks ends it existence
                    %earlier
                    mergend1=find(transpoints(j,i+1:end)==1,1,"first");
                    if isempty(mergend1), mergend1=size(xsort,2)-i; end
                    mergend2=find(transpoints(mindistlistind,i+1:end)==1,1,"first");
                    if isempty(mergend2), mergend2=size(xsort,2)-i; end
                    %both tracks need to stay close until one of them
                    %ceases to exist again
                    distrange=(xsort(j,i+1:i+min(mergend1,mergend2))-...
                        xsort(mindistlistind,i+1:i+min(mergend1,mergend2))).^2+...
                        (ysort(j,i+1:i+min(mergend1,mergend2))-...
                        ysort(mindistlistind,i+1:i+min(mergend1,mergend2))).^2;
                    if sum(distrange>distthr1)==0
                        if mergend2<mergend1
                            %if the pre-existing track stops to exist
                            %first, average their positions till this
                            %point, but also flip the traces afterwards to
                            %continue with the new track
                            xsort(mindistlistind,i+1:i+mergend2)=...
                                (xsort(mindistlistind,i+1:i+mergend2)+...
                                xsort(j,i+1:i+mergend2))/2;
                            xsort(j,i+1:i+mergend2)=nan;
                            ysort(mindistlistind,i+1:i+mergend2)=...
                                (ysort(mindistlistind,i+1:i+mergend2)+...
                                ysort(j,i+1:i+mergend2))/2;
                            ysort(j,i+1:i+mergend2)=nan;
                            sizesort(mindistlistind,i+1:i+mergend2)=...
                                (sizesort(mindistlistind,i+1:i+mergend2)+...
                                sizesort(j,i+1:i+mergend2));
                            %flip rest
                            xsortold=xsort(:,i+mergend2+1:end);
                            ysortold=ysort(:,i+mergend2+1:end);
                            sizesortold=sizesort(:,i+mergend2+1:end);
                            transpointsold=transpoints(:,i+mergend2+1:end);
                            xsort(mindistlistind,i+mergend2+1:end)=xsortold(j,:);
                            xsort(j,i+mergend2+1:end)=xsortold(mindistlistind,:);
                            ysort(mindistlistind,i+mergend2+1:end)=ysortold(j,:);
                            ysort(j,i+mergend2+1:end)=ysortold(mindistlistind,:);
                            sizesort(mindistlistind,i+mergend2+1:end)=sizesortold(j,:);
                            sizesort(j,i+mergend2+1:end)=sizesortold(mindistlistind,:);
                            transpoints(mindistlistind,i+mergend2+1:end)=transpointsold(j,:);
                            transpoints(j,i+mergend2+1:end)=transpointsold(mindistlistind,:);
                            transpoints(mindistlistind,i+mergend2)=0;
                        else
                            %if the one that came into existence, stops first again,
                            % just average their positions during this
                            % interval and remove this second track
                            xsort(mindistlistind,i+1:i+mergend1)=...
                                (xsort(mindistlistind,i+1:i+mergend1)+...
                                xsort(j,i+1:i+mergend1))/2;
                            xsort(j,i+1:i+mergend1)=nan;
                            ysort(mindistlistind,i+1:i+mergend1)=...
                                (ysort(mindistlistind,i+1:i+mergend1)+...
                                ysort(j,i+1:i+mergend1))/2;
                            ysort(j,i+1:i+mergend1)=nan;
                            sizesort(mindistlistind,i+1:i+mergend1)=...
                                (sizesort(mindistlistind,i+1:i+mergend1)+...
                                sizesort(j,i+1:i+mergend1));
                            sizesort(j,i+1:i+mergend1)=nan;
                            transpoints(j,i+mergend1)=0;
                        end
                        transpoints(j,i)=0;
                        openarray(j)=1;
                    end
                end
            end
        end
    end
end

end