function T = transformForNifti(niftiFile)

info = niftiinfo(niftiFile);
R = info.Transform.T(1:3,1:3);

% Remove any pixel scaling
pixdim = sqrt(diag(R'*R));
R = R*diag(1./pixdim);

% Transform between Siemens DICOM and NIfTi
T = R*diag([-1,-1,1]);

end