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
if ~exist('basename','var')
    basename='output';
end

% Assume DICOM dictionary is in the same folder as this script
dictFile=fullfile(fileparts(mfilename('fullpath')),'dicom-dict-siemens.txt');

%% read in data
files=dir(infolder);
files=files(~[files.isdir]); % remove directories

oldDictFile=dicomdict("get");
try % run in try catch so we still reset the dicom dictionary back to "oldDictFile" even if the operations fail
    dicomdict("set",dictFile);

    nRep=length(files);
    bNominal=zeros(1,nRep);
    B=zeros(6,nRep);
    vNominal=zeros(3,nRep);
    for n = 1:nRep
        % Read dicom fields using Matlab objects. Faster than using
        % dicominfo; see here: 
        % https://de.mathworks.com/matlabcentral/answers/78315-can-i-read-a-single-field-using-dicominfo#answer_452571
        di=images.internal.dicom.DICOMFile(fullfile(files(n).folder,files(n).name));
        B_tmp=di.getAttributeByName('B_matrix');
        if ~isempty(B_tmp)
            % Convert DICOM "xx xy xz yy yz zz" to TWIX "xx yy zz xy xz yz"
            B(:,n)=B_tmp([1,4,6,2,3,5]);

            % Encode gradient polarity in B-matrix like in TWIX case
            vNominal(:,n)=di.getAttributeByName('DiffusionGradientDirection');
            B(1:3,n)=B(1:3,n).*sign(vNominal(:,n));
        end
        bNominal(n)=di.getAttributeByName('B_value');
    end
    dicomdict("set",oldDictFile); % make sure change to dictionary is not persistent

catch ME
    dicomdict("set",oldDictFile); % make sure change to dictionary is not persistent
    rethrow(ME)
end

%% compute bvals and bvecs
[bVectors,bValues]=readBvecsFromBmatrix(B,bNominal);

%% output bvals and bvecs
saveBvecBval(bVectors,bValues,outfolder,basename);

end