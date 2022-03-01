% Demo --- Ridge Detection
% This script shows how to use the Fourier-Argand filter algorithm to 
%   extract smooth curves from very noisy measurements.

% Add subdirectories to Matlab path
paths = genpath('.');
addpath(paths);

% Load sample image.
I0 = double(imread('curve.jpg'));

% Add additive white Gaussian noise (PSNR = 0 dB)
I = addnoise(I0, 0);

% Fourier-Argand filter (elongated Gaussian)
shape = [1,10]; K = 10; 
[J, alpha, time] = FA_filter(I, 'ridge', shape, K); time

% Non-maximum suppression
Jmax = nonmaximumsupp(J, alpha);

% Thresholding (keep 700 pixels)
tmp = sort(Jmax(Jmax(:)>min(Jmax(:))),'descend'); T = tmp(700);
FAridge = Jmax>=T;

% Show results --- click on the image when there are multipy frames.
figure(1), imview(imcontrast(I), I0), title('Noisy Image');
figure(2), imview(imcontrast(J, Jmax)), title('Response');
figure(3), imview(255*double(FAridge)), title('Detected Ridge');

rmpath(paths)