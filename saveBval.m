function saveBval(bValues, outfolder, basename)
%saveBval Output b-values to bval text file
%
% ledwards@cbs.mpg.de

fid = fopen(fullfile(outfolder, [basename '.bval']),'w');
fprintf(fid, '%.16g ',bValues(1,:));
fclose(fid);

end