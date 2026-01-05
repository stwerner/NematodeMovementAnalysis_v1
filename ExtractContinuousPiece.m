% Extract all continuously tracked snippet above a certain length.
%
% Input:
% - length of all continuously tracked pieces
% - threshold for the piece length
% - matrix of #worms x #time points-1, where 1 denotes a start of a tracked
% interval, -1 for the end of a tracked interval and 0 if no transition
% occurs
% - x position, y position, size of continuously tracked objects
%
% Output:
% - Number of tracked intervals
% - x position, y position, size of object in the interval
% - start point of interval
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Npieces,xpiece,ypiece,sizepiece,startpiece]=...
    ExtractContinuousPiece(allstretches,allstretchthr,transpoints,xsort,ysort,sizesort)

Nworms=size(transpoints,1);
Ntimep=size(transpoints,2)+1;

Npieces=sum(allstretches>allstretchthr);
Maxpieces=max(allstretches);
xpiece=nan(Npieces,Maxpieces);
ypiece=nan(Npieces,Maxpieces);
sizepiece=nan(Npieces,Maxpieces);
startpiece=nan(Npieces,1);
icount=0;
for i=1:Nworms
    ind1=find(transpoints(i,:)==1);
    ind2=find(transpoints(i,:)==-1);
    if isempty(ind1), ind1=Ntimep; end
    if isempty(ind2), ind2=0; end
    if ind1(1)<ind2(1), ind2=[0,ind2]; end
    if ind1(end)<ind2(end), ind1=[ind1,Ntimep]; end
    for j=1:size(ind1,2)
        if ind1(j)-ind2(j)>allstretchthr
            icount=icount+1;
            xpiece(icount,1:ind1(j)-ind2(j))=xsort(i,ind2(j)+1:ind1(j));
            ypiece(icount,1:ind1(j)-ind2(j))=ysort(i,ind2(j)+1:ind1(j));
            sizepiece(icount,1:ind1(j)-ind2(j))=sizesort(i,ind2(j)+1:ind1(j));
            startpiece(icount)=ind2(j)+1;
        end
    end
end

end