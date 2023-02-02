function readBvecsFromTwix(infolder, infile, outfolder, T)
%readBvecsFromTwix Read b-vectors and b-values from a Siemens twix raw data file
%
% Requires:
%   mapVBVD from https://github.com/pehses/mapVBVD
%
% Examples:
%     readBvecsFromTwix('input_twix_folder/', 'input_twix_file.dat', 'output_folder/');
%   will read in the twix file `input_twix_folder/input_twix_file.dat` and write out
%   the *b*-vectors and *b*-values of the last acquired line in each repetition to
%   `output_folder/input_twix_file.bvec` and `output_folder/input_twix_file.bval`,
%   respectively. It will also output the nominal *b*-values to 
%   `output_folder/input_twix_file_nominal.bval`.
%
%     readBvecsFromTwix('input_twix_folder/', 'input_twix_file.dat', 'output_folder/', diag([1,-1,1]));
%   will do the same as the previous example, but apply the transformation matrix
%   diag([1,-1,1]) to the b-vectors before saving them. This is useful to 
%   e.g. apply the transformation from DICOM to NIfTI space.
%
% ledwards@cbs.mpg.de

[~,~]=mkdir(outfolder);

% If user transform T is not supplied, then use identity transform (i.e. do nothing)
if ~exist('T','var')
    T=eye(3);
end

%% read in data
dat=mapVBVD(fullfile(infolder,infile));

nRep=dat.image.NRep;

% Choose one line from each repetition
lastIndices=zeros(nRep,1);
for n = 1:nRep
    lastIndices(n)=find(dat.image.Rep == n,1,'last');
end

% The elements of iceParam in positions 1-6 are the B-matrix 
% elements stored as an unsigned short: 
%   uint16(B??+16384.5) 
% where ?? is, in order: 
%   xx yy zz xy xz yz.
% Note that the diagonal elements (Bxx, Byy and Bzz) are signed in
% order to encode the polarity of the gradient vector which would
% otherwise be lost. This can give rise to problems if the nominal
% b-value is greater than 16384. readBvecsFromBmatrix attempts to
% account for this.
k=16384; % inverse of scaling applied by sequence
iceParams=dat.image.iceParam(:,lastIndices);
B=iceParams(1:6,:) -k;

% Position 7 is the nominal b value scaled in the same way as the 
% B-matrix.
bNominal=iceParams(7,:) -k;

%% compute bvals and bvecs
[bVectors,bValues]=readBvecsFromBmatrix(B,bNominal);

%% output bvals and bvecs
[~,basename,~]=fileparts(infile);

saveBvec(bVectors,outfolder,basename,T);
saveBval(bValues,outfolder,basename);

% Also output nominal b-values in case they are needed
saveBval(bNominal,outfolder,[basename,'_nominal']);

end
