% Demo --- Ridge Detection
% This script shows how to use the Fourier-Argand filter algorithm to 
%   extract blood vessels from a sample retinal image.

% Add subdirectories to Matlab path.
paths = genpath('.');
addpath(paths);

% Load sample retinal image.
I0 = double(imread('S01_2.jpg'));

% Resize the image to accelerate computation.
%   - We only use the green channel for it has the best contrast between blood
%   vessels and the backgroud.
I = imresize(I0(:,:,2), [512,512]);

% Fourier-Argand filter (2nd derivative of elongated Gaussian)
shape = [1.5,7.5]; K = 20; 
[J, alpha, time] = FA_filter(-I, 'ridge0', shape, K); time

% Non-maximum suppression
Jmax = nonmaximumsupp(J, alpha);

% Thresholding
T = (max(Jmax(:))-median(Jmax(:)))*0.03 + median(Jmax(:));
FAridge = Jmax>=T;
% Eliminate braches with less than 20 pixels
FAridge = bwareafilt(FAridge, [20,inf]);

% Show results --- click on the image when there are multipy frames.
figure(1), imview(I), title('Green Channel of the Retina Image');
figure(2), imview(imcontrast(J, Jmax)), title('Filter Response');
figure(3), imview(255*double(FAridge), I), title('Detected Ridge');

rmpath(paths);