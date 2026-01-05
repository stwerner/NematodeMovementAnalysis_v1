%Sorting the elements of the skeleton, starting from tail and finding the
%nearest neighbor

function skeleton = sortingskeleton(skelpoints, boundtpos, boundhpos)

skelpos = boundtpos;          %first skeleton position is the tail
skeleton = zeros(size(skelpoints,1),2); %final skeleton in right order
skelpointstmp = skelpoints;       %remaining skelpoints that have not been used
counter=0;                        %count the number of the dublicated positions
delpos = zeros(size(skelpoints,1),1);   %save the index of the dublicated positions
for l = 1:size(skeleton,1);
    distold=inf;
    for k = 1:size(skelpointstmp,1)                     %calculating the distance
        deltatmp = skelpos - skelpointstmp(k,:);        %of all skelpointstmp to
        disttmp = sqrt(deltatmp(1)^2 + deltatmp(2)^2);  %current skelpos
        if disttmp<distold              %checking for the smallest disttmp
            distold=disttmp; minpos=k;
            if disttmp == 0             %delete duplicated skeleton positions
                counter = counter + 1;
                delpos(counter) = k;
            end
        end
    end
    skelpos = skelpointstmp(minpos,:);  %updating skelpos
    skeleton(l,:) = skelpos;            %saving the found skelpos
    skelpointstmp(minpos,:) = [];       %deleting the found skelpos in skelpoitnstmp
end
if counter>0
    skeleton(delpos(1:counter),:)=[];   %delete dublicated positions
end
%add head and tail if necessary
if skeleton(end,:) ~= boundhpos
skeletonh = [skeleton; boundhpos]; skeleton = skeletonh;
end
if skeleton(1,:) ~= boundtpos
skeletont = [boundtpos; skeleton]; skeleton = skeletont;
end

end