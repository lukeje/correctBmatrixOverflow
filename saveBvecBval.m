function saveBvecBval(bVectors,bValues,outfolder,basename)
%saveBvecBval Output b-vectors and b-values to bvec and bval text files.
%
% ledwards@cbs.mpg.de

fid = fopen(fullfile(outfolder, [basename '.bvec']),'w');
fprintf(fid, '%d ',bVectors(1,:));
fprintf(fid, '\n');
fprintf(fid, '%d ',bVectors(2,:));
fprintf(fid, '\n');
fprintf(fid, '%d ',bVectors(3,:));
fclose(fid);

fid = fopen(fullfile(outfolder, [basename '.bval']),'w');
fprintf(fid, '%d ',bValues(1,:));
fclose(fid);

end