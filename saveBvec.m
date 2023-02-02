function saveBvec(bVectors, outfolder, basename, T)
%saveBvec Output b-vectors to bvec text file
%
% Optionally rotates/flips the b-vectors using a 3x3 transform "T" before
% saving the b-vectors. This is useful to e.g. apply the transformation from 
% DICOM to NIfTI space.
%
% ledwards@cbs.mpg.de

% If T is not supplied, then use identity transform (i.e. do nothing)
if ~exist('T','var')
    T=eye(3);
end
assert(isequal(size(T),[3,3]), 'The transformation "T" must be a 3x3 matrix')

% Apply transformation from user before saving b-vectors
bVectors = T*bVectors;

fid = fopen(fullfile(outfolder, [basename '.bvec']),'w');
fprintf(fid, '%.16g ',bVectors(1,:));
fprintf(fid, '\n');
fprintf(fid, '%.16g ',bVectors(2,:));
fprintf(fid, '\n');
fprintf(fid, '%.16g ',bVectors(3,:));
fclose(fid);

end