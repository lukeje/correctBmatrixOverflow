function [bVectors,bValues] = readBvecsFromBmatrix(B,bNominal)
%readBvecsFromBmatrix Read b-vectors and b-values from a Siemens twix-like B-matrix representation
%
% Input:
%   B: 6 x number of volumes array containing the elements of the B-matrix
%   bNominal: 1 x number of volumes array containing the nominal b-values
%
% Output:
%   bVectors: 3 x number of volumes array containing the b-vectors
%   bValues: 1 x number of volumes vector containing the b-values 
%
% Assumes B(:,n) is a vector of the six unique elements of the B-matrix in the
% order xx yy zz xy xz yz. The sign of the diagonal elements should reflect
% the sign of the elements in the gradient vector in line with the scheme
% used in Siemens diffusion sequences. bNominal from the DICOM or TWIX
% header is used to check for integer overflow in the B-matrix as it was
% stored in the TWIX header.
%
% ledwards@cbs.mpg.de

nRep = length(bNominal);

bValues = zeros(1,nRep);
bVectors = zeros(3,nRep);
for bIdx = 1:nRep   
    % Test for integer overflow which occurs when diagonal elements of the 
    % B-tensor are larger than 16384 and negated due to the polarity 
    % encoding (see below). Overflow would also happen if elements are 
    % greater than (2^16-16385), but we do not (and probably cannot) test 
    % for that as the nominal b-values may then also be affected. Note that 
    % we do not check for overflow of the diagonal elements. However the 
    % maximum magnitude of off diagonal elements should be b/2 for typical
    % diffusion encoding schemes and so they will only be affected for 
    % very high b-values.
    u = 2^16; % number of representable numbers in C++ unsigned short
    bPermutationArray=zeros(1,2^3);
    for n = 1:2^3 % test all permutations of choosing 3 elements from {0,1}
        r = dec2bin(n-1,3)-'0'; % trick for turning binary char into array

        % Try subtracting overflow and compare to nominal b value to try
        % and find correct permutation
        bPermutationArray(n) = sum(abs( B(1:3,bIdx) -u*r' ));
    end
    [~,m] = min(abs(bPermutationArray-bNominal(bIdx)));
    
    % Correct diagonal elements for overflow
    r = dec2bin(m-1,3)-'0';
    B(1:3,bIdx) = B(1:3,bIdx) -u*r(:);

    % Compute b-value and b-vector
    bMatrix = [...
        abs(B(1,bIdx)), B(4,bIdx), B(5,bIdx);
        B(4,bIdx), abs(B(2,bIdx)), B(6,bIdx);
        B(5,bIdx), B(6,bIdx), abs(B(3,bIdx));
        ];
    [v,d] = eig(bMatrix);

    % Use vector corresponding to largest magnitude eigenvalue
    [~,f] = max(abs(diag(d)));
    bValues(bIdx) = abs(d(f,f));
    vec = v(:,f)*sign(d(f,f));

    % Use polarity stored in diagonal elements of B-matrix 
    s = sign(B(1:3,bIdx));
    vec = vec*sign(vec'*(s.*abs(vec)));

    bVectors(:,bIdx) = vec;
end

end
