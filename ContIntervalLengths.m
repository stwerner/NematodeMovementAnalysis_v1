% Find length of all intervalls, where the object has been continuously
% tracked
%
% Input:
% - matrix of #worms x #time points-1, where 1 denotes a start of a tracked
% interval, -1 for the end of a tracked interval and 0 if no transition
% occurs
%
% Output:
% - interval lengths of all continuously tracked stretches
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function allstretches=ContIntervalLengths(transpoints)

Nworms=size(transpoints,1);
Ntimep=size(transpoints,2)+1;

allstretches=[];
for i=1:Nworms
    ind1=find(transpoints(i,:)==1);
    ind2=find(transpoints(i,:)==-1);
    if isempty(ind1), ind1=Ntimep; end
    if isempty(ind2), ind2=0; end
    if ind1(1)<ind2(1), ind2=[0,ind2]; end
    if ind1(end)<ind2(end), ind1=[ind1,Ntimep]; end
    allstretches=[allstretches(:)',ind1-ind2];
end

end