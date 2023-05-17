function T = transformForNifti(niftiFilename)
%transformForNifti Read transform from NIfTI file header to transform b-vectors from scanner to image space
%
% It is assumed that the NIfTI file is from the same acquisition as the b-vectors and that the transform in 
% the NIfTI file is the transform from scanner space to image space (i.e. no re-alignment has been performed)
%
% This function has only been tested for tilted-axial acquisitions.
% It is strongly recommended to check that the b-vectors are reasonable after transformation using this matrix.  
%
% ledwards@cbs.mpg.de

info = niftiinfo(niftiFilename);
R = info.Transform.T(1:3,1:3);

% Remove any pixel scaling
pixdim = sqrt(diag(R'*R));
R = R*diag(1./pixdim);

% Transform between DICOM convention (LPS) and NIfTI convention (RAS)
T = R*diag([-1,-1,1]);

end