% Extract path from file ID
%
% Input:
% - path2file: path to the file location
% - dataid: part or the file name to identify it uniquely
% - file extension
%
% Output:
% - path to file
%
% SW, 01/09/25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function filepath=pathfromfileid(path2file,dataid,fileextension)

filelist=dir([path2file,dataid,'*.',fileextension]);
if size(filelist,1)>1, error('Data ID is not unique!'), end
if size(filelist,1)==0, error('Data ID is not found!'), end
filepath = [path2file,filelist(1).name];

end