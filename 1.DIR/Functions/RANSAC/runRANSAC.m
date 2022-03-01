function  [results]=runRANSAC(X)
% SetPathLocal();
%%%%%%  Parameters
% noise
sigma = 1;
% set RANSAC options
options.epsilon = 1e-6;
options.P_inlier = 1-1e-2;
options.sigma = sigma;
options.est_fun = @estimate_affine;
options.man_fun = @error_affine;
options.mode = 'MSAC';
options.Ps = [];
options.notify_iters = [];
options.min_iters = 10;
options.max_iters = 1000000;
options.fix_seed = false;
options.reestimate = true;
options.stabilize = false;
[results, ~] = RANSAC(X, options);
end
