function readBvecsFromMrd(infile, outfolder, T)
%readBvecsFromMrd Read b-vectors and b-values from an MRD raw data file
%
% Requires:
%   ISMRMRD matlab tools from https://github.com/ismrmrd/ismrmrd
%
% Examples:
%     readBvecsFromMrd('input_mrd_folder/input_mrd_file.h5', 'output_folder/');
%   will read in the mrd file `input_mrd_folder/input_mrd_file.dat` and write out
%   the *b*-vectors and *b*-values of the last acquired line in each repetition to
%   `output_folder/input_mrd_file.bvec` and `output_folder/input_mrd_file.bval`,
%   respectively. It will also output the nominal *b*-values to 
%   `output_folder/input_mrd_file_nominal.bval`.
%
%   You can alternatively provide an already generated mrd object, for example:
%     mrd = ismrmrd.Dataset('input_mrd_folder/input_mrd_file.h5', 'dataset');
%     readBvecsFromMrd(mrd, 'output_folder/');
%   which will do the same as the first example. This can be useful to avoid
%   having to repeat reading in the mrd object if it is already being used
%   elsewhere in a script.
%
%     readBvecsFromMrd('input_mrd_folder/input_mrd_file.h5', 'output_folder/', diag([1,-1,1]));
%   will do the same as the first example, but apply the transformation matrix
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
% Option to provide filename or previously generated mrd object
if (isstring(infile) || ischar(infile)) && isfile(infile)
    mrd=ismrmrd.Dataset(infile, 'dataset');
elseif isa(infile,'ismrmrd.Dataset') || (iscell(infile) && isstruct(infile{end}))
    mrd=infile;
else
    error('input "infile" does not seem to be either a filename or an MRD dataset')
end

%TODO: Can MRD files contain multiple measurements?

% Basename for output files
[~,basename,~]=fileparts(mrd.filename);

% Need to know encoding limits for logic below
hdr = ismrmrd.xml.deserialize(mrd.readxml);
try % Field may be missing if there is only one repetition
    %TODO: sometimes this seems be one-indexed rather than zero indexed
    nRep = hdr.encoding.encodingLimits.repetition.maximum + 1;
catch
    nRep = 1;
end

% Choose one line from each repetition
% Assumes that repetition indexes directions, and that they are sequential.
% Use last acquisition of each repetition to avoid problems with pre-scans.
% Looping through acquisitions could probably be made more efficient if we 
% went backwards or knew a priori how many acquisitions are in a repetition
iceParams=zeros(8,nRep);
N=1;
Dold = mrd.readAcquisition(1);
for n = 2:mrd.getNumberOfAcquisitions
    Dnew = mrd.readAcquisition(n);
    if Dnew.head.idx.repetition > Dold.head.idx.repetition
        iceParams(:,N) = Dold.head.user_int;
        N=N+1;
    end
    Dold = Dnew;
end
iceParams(:,N) = Dold.head.user_int;

if N<nRep
    warning('Number of repetitions in mrd dataset (%d) was less than expected number (%d). Dataset may have been truncated.',N,nRep);
    iceParams=iceParams(:,1:N);
elseif N>nRep
    error('Number of repetitions in mrd dataset (%d) was greater than expected number (%d). Something has gone wrong.')
end

%% compute bvals and bvecs
[bVectors,bValues,bNominal]=readBvecsFromICEparams(iceParams);

%% output bvals and bvecs
saveBvec(bVectors,outfolder,basename,T);
saveBval(bValues,outfolder,basename);

% Also output nominal b-values in case they are needed
saveBval(bNominal,outfolder,[basename,'_nominal']);

end
