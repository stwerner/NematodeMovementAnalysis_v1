% Associates objects by closest distance across adjacent time points
%
% Input:
% - all x-/y-positions and wormsizes
% - Nworms, Ntimep: number of worms and time points
%
% Output:
% - associated x-/y-positions and corresponding wormsizes
% - distances moved between time points
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [xsort, ysort, sizesort, distoutput]=TrackAdjacentTimepoints(wormxpos, ...
    wormypos, wormsizes, Nworms, Ntimep)

xsort=wormxpos; ysort=wormypos; sizesort=wormsizes;
distoutput=nan(Nworms,Ntimep-1); %log the distances
for i=2:size(xsort,2)
    distmat=nan(Nworms, Nworms); %new x old
    for j=1:Nworms 
        for k=1:Nworms
            distmat(j,k)=(ysort(j,i)-ysort(k,i-1))^2+(xsort(j,i)-xsort(k,i-1))^2;
        end
    end
    jcount=0;
    assoc=nan(Nworms,2);
    for j=1:Nworms
        [trackminval,trackminpos]=min(distmat,[],2);
        [trackminval2,trackminpos2]=min(trackminval);
        if trackminval2~=inf
            distoutput(trackminpos(trackminpos2),i-1)=trackminval2;
            distmat(trackminpos2,:)=inf;
            distmat(:,trackminpos(trackminpos2))=inf;
            jcount=jcount+1;
            assoc(jcount,:)=[trackminpos(trackminpos2),trackminpos2]; 
        end
    end
    if jcount<Nworms %if less than expected number of worms
        temp1=1:Nworms;
        temp1(assoc(1:jcount,1))=[];
        temp2=1:Nworms;
        temp2(assoc(1:jcount,2))=[];
        assoc(jcount+1:end,:)=[temp1',temp2']; %random association
    end
    xsortold=xsort(:,i:end); ysortold=ysort(:,i:end);
    sizesortold=sizesort(:,i:end);
    for j=1:Nworms %swap according association
        xsort(assoc(j,1),i:end)=xsortold(assoc(j,2),:);
        ysort(assoc(j,1),i:end)=ysortold(assoc(j,2),:);
        sizesort(assoc(j,1),i:end)=sizesortold(assoc(j,2),:);
    end
end


end