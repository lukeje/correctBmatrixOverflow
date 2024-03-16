function [bVectors,bValues,bNominal] = readBvecsFromICEparams(iceParams)
%readBvecsFromICEparams Extract b-vectors and b-values from ICE acquisition parameters
%
% ledwards@cbs.mpg.de

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
B=iceParams(1:6,:) -k;

% Position 7 is the nominal b value scaled in the same way as the 
% B-matrix.
bNominal=iceParams(7,:) -k;

%% compute bvals and bvecs
[bVectors,bValues]=readBvecsFromBmatrix(B,bNominal);

end
