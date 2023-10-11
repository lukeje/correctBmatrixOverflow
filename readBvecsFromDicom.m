function readBvecsFromDicom(infolder, outfolder, output_name, T)
%readBvecsFromDicom Read b-vectors and b-values from Siemens DICOM files
%
% Requires:
%   Matlab image processing toolbox
%
% Examples:
%     readBvecsFromDicom('input_dicom_folder/', 'output_folder/', 'output_name');
%   will read in all the DICOM files in the input folder `input_dicom_folder` and write
%   out the *b*-vectors and *b*-values to `output_folder/output_name.bvec` and
%   `output_folder/output_name.bval`, respectively. It will also output the nominal 
%   *b*-values to `output_folder/output_name_nominal.bval`.
%
%     readBvecsFromDicom('input_dicom_folder/', 'output_folder/', 'output_name', diag([1,-1,1]));
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

% Assume DICOM dictionary is in the same folder as this script
dictFile=fullfile(fileparts(mfilename('fullpath')),'dicom-dict-siemens.txt');

%% read in data
files=dir(infolder);
files=files(~[files.isdir]); % remove directories

nRep=length(files);
bNominal=zeros(1,nRep);
t=zeros(1,nRep);
B=zeros(6,nRep);
try
    % try reading Siemens private DICOM fields
    for n = 1:nRep
        [t(n),bNominal(n),B(:,n)] = read0019fields(fullfile(files(n).folder,files(n).name),dictFile);
    end
catch %TODO: only catch specific error associated with missing private fields
    % use SPM to read CSA header otherwise
    %TODO: check whether SPM is installed
    for n = 1:nRep
        [t(n),bNominal(n),B(:,n)] = readCSAfields(fullfile(files(n).folder,files(n).name));
    end
end

% Make sure that the output will match the acquisition order
[~,ordering] = sort(t);
B = B(:,ordering);
bNominal = bNominal(ordering);

%% compute bvals and bvecs
[bVectors,bValues] = readBvecsFromBmatrix(B,bNominal);

%% output bvals and bvecs
saveBvec(bVectors,outfolder,output_name,T);
saveBval(bValues,outfolder,output_name);

% Also output nominal b-values in case they are needed
saveBval(bNominal,outfolder,[output_name,'_nominal']);

end

%% Local functions
% Read diffusion encoding information from Siemens (0019,10xx) private DICOM fields
function [t,b,B] = read0019fields(dicomFile,dictFile)

oldDictFile=dicomdict("get");
try % run in try catch so we still reset the dicom dictionary back to "oldDictFile" even if the operations fail
    dicomdict("set",dictFile);

    % Read dicom fields using Matlab objects. Faster than using dicominfo; see here:
    % https://de.mathworks.com/matlabcentral/answers/78315-can-i-read-a-single-field-using-dicominfo#answer_452571
    di=images.internal.dicom.DICOMFile(dicomFile);
    t=di.getAttributeByName('AcquisitionNumber');

    % Use "typecast" so still works when info on DICOM header types was lost and Matlab returns uint8 vector
    b_tmp=typecast(di.getAttributeByName('B_value'),'double');
    if isempty(b_tmp)
        error('B_value missing in DICOM header.')
    else
        b=b_tmp;
    end

    B=typecast(di.getAttributeByName('B_matrix'),'double');
    if ~isempty(B) % empty for b=0 acquisitions
        v=typecast(di.getAttributeByName('DiffusionGradientDirection'),'double');
        B=convert_DICOM_B_matrix(B,v);
    else
        B=zeros(6,1);
    end

    dicomdict("set",oldDictFile); % make sure change to dictionary is not persistent

catch ME
    dicomdict("set",oldDictFile); % make sure change to dictionary is not persistent
    rethrow(ME)
end

end

function [t,b,B] = readCSAfields(dicomFile)

hdr=spm_dicom_headers(dicomFile);
CSA=hdr{1}.CSAImageHeaderInfo;

t=hdr{1}.AcquisitionNumber;

bIdx=strcmp({CSA.name},'B_value');
b=str2double(CSA(bIdx).item((1:CSA(bIdx).vm)).val);

BIdx=strcmp({CSA.name},'B_matrix');
if any(BIdx)
    B=str2double({CSA(BIdx).item((1:CSA(BIdx).vm)).val});

    vIdx=strcmp({CSA.name},'DiffusionGradientDirection');
    v=str2double({CSA(vIdx).item(1:CSA(vIdx).vm).val});
    
    B=convert_DICOM_B_matrix(B,v);
else
    B=zeros(6,1);
end

end

% Convert DICOM B-matrix format to TWIX B-matrix format
function B=convert_DICOM_B_matrix(B,v)
% Convert DICOM "xx xy xz yy yz zz" to TWIX "xx yy zz xy xz yz"
B=B([1,4,6,2,3,5]);

% Encode gradient polarity in B-matrix like in TWIX case
B(1:3)=B(1:3).*sign(v);

end