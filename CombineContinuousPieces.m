% Extracts worm skeletons and perimeters
%
% Input:
% - folder with the files
% - structure with data set IDs [multiple data sets can be processed]
% - number of time points
%
% Output:
% - none but generates mat-files combining all tracking for each data set
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function CombineContinuousPieces(inputpath,dataids,fileN)

dataidslen=size(dataids,1);

for dataidi = 1:dataidslen
    dataid=dataids{dataidi};
    load([inputpath,dataid,'Para.mat'])
    disp(['Running: ',dataid])

    skeletonxC=nan(fileN,100,max(linkvec(:,1)));
    skeletonyC=nan(fileN,100,max(linkvec(:,1)));
    ratiotestC=nan(fileN,max(linkvec(:,1)));
    thcurvC=nan(fileN,2,max(linkvec(:,1)));
    for i=1:size(linkvec,1)
        if linkvec(i,1)>0
            load([inputpath,dataid,'W',num2str(i),'Skel.mat']);
            endind=find(~isnan(skeletonx(:,1)),1,'last');
            skeletonxC(startpiece(i):(startpiece(i)+endind-1), ...
                :,linkvec(i,1))=skeletonx(1:endind,:);
            skeletonyC(startpiece(i):(startpiece(i)+endind-1), ...
                :,linkvec(i,1))=skeletony(1:endind,:);
            ratiotestC(startpiece(i):(startpiece(i)+endind-1), ...
                linkvec(i,1))=ratiotest(1:endind);
            thcurvC(startpiece(i):(startpiece(i)+endind-1), ...
                :,linkvec(i,1))=thcurv(1:endind,:);
        end
    end
    save([inputpath,dataid,'SkelC.mat'],...
        "ratiotestC","thcurvC","skeletonxC","skeletonyC","linkvec")

end

end