% Demo --- Edge Detection
% This script shows how to use the Fourier-Argand filter algorithm to 
%   extract strong edges from an image.

% Add subdirectories to Matlab path.
paths = genpath('.');
addpath(paths);

% Load sample image.
I0 = double(imread('lena.jpg'));

% Add additive white Gaussian noise (PSNR = 20 dB)
I = addnoise(I0, 20);

% Fourier-Argand filter (elongated Gaussian)
shape = [3,7]; K = 10; 
[J, alpha, time] = FA_filter(I, 'edge', shape, K); time

% Non-maximum suppression
Jmax = nonmaximumsupp(J, alpha);

% Thresholding (keep 5% pixels)
numPxls = round(0.05*numel(I));
tmp = sort(Jmax(Jmax(:)>min(Jmax(:))),'descend'); T = tmp(numPxls);
FAedge = Jmax>=T;

% Show results --- click on the image when there are multipy frames.
figure(1), imview(imcontrast(I), I0), title('Noisy Image');
figure(2), imview(imcontrast(Jmax, J)), title('Response');
figure(3), imview(255*double(FAedge)), title('Detected Edge');

rmpath(paths)