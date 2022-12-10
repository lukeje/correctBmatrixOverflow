function readBvecsFromDicom(infolder, outfolder, basename)
%readBvecsFromDicom 
%
% Examples:
%   infolder = 'my_dicom_folder/';
%   outfolder = 'my_output_folder/';
%   basename = 'my_output_filename';
%   readBvecsFromDicom(infolder, outfolder, basename);
%
% ledwards@cbs.mpg.de

[~,~]=mkdir(outfolder);
if ~exist(basename,'var')
    basename = 'output';
end

%% read in data
files = dir(infolder);
files=files(~[files.isdir]); % remove directories
nRep = length(files);
bNominal=zeros(1,nRep);
B=zeros(6,nRep);
vNominal=zeros(3,nRep);
dictFile = fullfile(fileparts(mfilename('fullpath')),'dicom-dict-siemens.txt');
for n = 1:nRep
    di=dicominfo(fullfile(files(n).folder,files(n).name),"Dictionary",dictFile);
    if isfield(di,"B_matrix")
        % Convert DICOM "xx xy xz yy yz zz" to TWIX "xx yy zz xy xz yz"
        B(:,n) = di.B_matrix([1,4,6,2,3,5]);
        
        % Encode gradient polarity in B-matrix
        vNominal(:,n)=di.DiffusionGradientDirection;
        B(1:3,n)=B(1:3,n).*sign(vNominal(:,n));
    end
    bNominal(n) = di.B_value;
end

%% compute bvals and bvecs
[bVectors,bValues] = readBvecsFromBmatrix(B,bNominal);

%% output bvals and bvecs
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