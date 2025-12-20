function sphericalHarmonics = fitSphericalHarmonics_mle(dirs, y, sigma, order, reglambda)
% Estimation of spherical harmonic coefficients of a given order from
% single-shell Rician distributed data using maximum likelihood estimator
%
% The Gaussian noise level must estimated a priori. 
%
% input arguments:
% dirs:      Gradient directions for a single b-shell [Nq x 3]
% y:         Vectorized diffusion-weighted signals    [Nq x Nvoxels]
% sigma:     Vectorized Gaussian noise level          [1  x Nvoxels] 
% order:     Maximal spherical harmonics order
% reglambda: Regularisation parameter for Laplace-Beltrami regularisation
%
% Author: Jelle Veraart (jelle.veraart@nyulangone.org)
%
% copyright NYU School of Medicine, 2023
%
% Luke Edwards:
% - output all spherical harmonic coefficients
% - add try/catch to avoid crash when fitting fails for a voxel
% - added Laplace--Beltrami regularisation following
%     Descoteaux, et al. (2007), "Regularized, fast, and robust analytical Q-ball
%     imaging". Magn. Reson. Med., 58:497-510. https://doi.org/10.1002/mrm.21277

if ~exist('reglambda','var'), reglambda = 0; end

[X, reg] = getSH(order, dirs);
reg = reglambda*reg;
start = (X'*X + reg)\(X'*y);
sphericalHarmonics = start;
y(y<eps) = eps;

options = optimset('fminunc'); options = optimset(options,'GradObj','off','Hessian','off','Display','off', 'MaxFunEvals', 20000, 'MaxIter', 2000);
for i = 1:size(y, 2)
    try
        sphericalHarmonics(:,i) = fminunc(@(x)LogLikelihood(x,double(X),double(y(:, i)),double(sigma(:,i)),reg),double(start(:,i)),options);
    catch
        sphericalHarmonics(:,i) = nan;
    end
end

end

function f = LogLikelihood(coef, X, s, sigma, reg)

    s_hat = X*coef(:);

    f = logRicianpdf(s, s_hat, sigma);
    f = -sum(f,1)' + sum(diag(reg).*coef(:).^2); % 1 x 1; includes regularisation
   
end
        
function P = logRicianpdf(x, A, sigma)

    L = 1;
    Arg = (A .* x) ./ (sigma.^2);
    besL1 = besseli(L-1, Arg, 1);
    P = log(x.^L) - log(sigma.^2) + log(A.^(L-1)) - (A.^2 + x.^2)./(2*sigma.^2) + log(besL1) + abs(real(Arg));
   
end
