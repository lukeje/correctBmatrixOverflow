% test requires functions on above and below path
addpath(genpath(fileparts(fileparts(mfilename("fullpath")))))

% useful functions for testing
tu = testutils;

% choose vector set
bvecs = tu.getAxondiameterVecs;

% simulate b-vector storage and recovery in "low" b-value data
bvecs_corrupted_low = tu.converttwixBstobvecs(tu.convertbvecs2twixBs(6000,bvecs));

% simulate b-vector storage and recovery in "high" b-value data
bvals = 30490*ones(1,size(bvecs,2));
B_high = tu.convertbvecs2twixBs(bvals,bvecs);
bvecs_corrupted_high = tu.converttwixBstobvecs(B_high);
B_high_reshape(1,:) = B_high(1,1,:);
B_high_reshape(2,:) = B_high(2,2,:);
B_high_reshape(3,:) = B_high(3,3,:);
B_high_reshape(4,:) = B_high(1,2,:);
B_high_reshape(5,:) = B_high(1,3,:);
B_high_reshape(6,:) = B_high(2,3,:);
bvecs_fixed_high = readBvecsFromBmatrix(double(B_high_reshape) - 16385, bvals);

% simulate spherical harmonic coefficients as decreasing exponentially with
% increasing order. This means that we ignore axon radius for now, but this
% could be included if desired. The scanner gradient frame is assumed to be
% aligned with the spherical tensor axes so that off-diagonal coefficients
% are zero, though this frame can be rotated below.
order = 6; % maximum spherical harmonic order used to generate data
r = 1; % exponential scaling factor for spherical harmonic coefficients
N = 1+2*(0:2:order);
l = zeros(sum(N),1); m = zeros(sum(N),1);
idx = 1;
for n=1:length(N)
    ord = 2*(n-1);
    l(idx:(idx+N(n)-1)) = ord;
    m(idx:(idx+N(n)-1)) = -ord:ord;
    idx = idx+N(n);
end
c = exp(-r*(0:2:order));
C = zeros(length(m),1);
C(m==0) = c;

% can specify rotation matrix to simulate axes of spherical tensors not
% being aligned with scanner gradient axes. This is easier than computing
% Wigner rotation matrices for the spherical harmonic coefficients. This
% rotation should not matter for calculation of the power in the spherical
% harmonic coefficients. Here we choose this rotation randomly
alpha = 360*rand(1);
beta  = 180*rand(1);
gamma = 360*rand(1);
R = tu.rotzyzd(alpha,beta,gamma);
Rbvecs = R*bvecs;

% orientation dependence is product of spherical harmonics and coefficients
YC = getSH(order,Rbvecs')*C;

% add noise to data so that maximum likelihood estimation well-defined
s = 1;
sigma = 1e-3*eps(min(s*YC)); % make noise much smaller than signal
S = abs(s*YC + sigma*randn(size(bvecs,2),1));

% fit data using maximum likelihood estimation
fitorder = 6; % maximum spherical harmonic order to fit can differ from maximum order used to generate data
lambda = 0; % add regularisation to fit if desired
YM = fitSphericalHarmonics_mle(bvecs', S, sigma, fitorder, lambda)/s;
YM_corrupted_low  = fitSphericalHarmonics_mle(bvecs_corrupted_low',  S, sigma, fitorder, lambda)/s;
YM_corrupted_high = fitSphericalHarmonics_mle(bvecs_corrupted_high', S, sigma, fitorder, lambda)/s;
YM_fixed_high     = fitSphericalHarmonics_mle(bvecs_fixed_high',     S, sigma, fitorder, lambda)/s;

% display table showing errors in coefficient estimates with different
% vector sets
idx = 1;
minorder = min([order,fitorder]/2+1);
T = zeros(4,minorder);
for n=1:minorder
    ord = 2*(n-1);
    T(:,n) = 100*(c(n)-[...
        norm(YM(l==ord));
        norm(YM_corrupted_low(l==ord));
        norm(YM_corrupted_high(l==ord));
        norm(YM_fixed_high(l==ord))...
        ])/c(n);
    idx = idx+N(n);
end
disp(array2table(T,...
    'RowNames',["original","low-b corrupted","high-b corrupted","high-b corrected"],...
    'VariableNames',"c"+2*(0:minorder-1)+" error (%)"))
