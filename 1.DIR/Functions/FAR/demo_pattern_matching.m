% Demo --- Pattern Matching
% This script shows how to use the Fourier-Argand filter algorithm for
%   steerable pattern matching.

% Add subdirectories to Matlab path.
paths = genpath('.');
addpath(paths);

% Load sample image.
I0 = double(rgb2gray(imread('coins.jpg')));

% High-pass filter
I = abs(imfilter(I0,[0 1 0; 1 -4 1; 0 1 0]));

% Prepare pattern (cropped from the image)
centre = [79,304]; R = 38; 
mask = abs((-R:R)'*ones(1,2*R+1)+1i*ones(2*R+1,1)*(-R:R))<=R;
h = I(centre(1)-R:centre(1)+R, centre(2)-R:centre(2)+R).*mask;

% Fourier-Argand filter
K = 20;
[J, alpha, time, hK] = FA_filter(I, 'pattern', h, K); time

% Compute cross-correlation
N = sum(mask(:));
a = sum(hK(:).*mask(:))/N;
a2 = sum(hK(:).^2.*mask(:))/N;
b = imfilter(I,double(mask),'symmetric')/N;
b2 = imfilter(I.^2,double(mask),'symmetric')/N;
C = (J/N-a.*b)./sqrt((a2-a.^2).*(b2-b.^2+eps));

% Find local maxima
Jmax = localmaxima(C);
bw=(Jmax==imdilate(Jmax,strel('disk',R,0))); Jmax(~bw) = min(Jmax(:));  % eliminate near-by large peaks
tmp = sort(Jmax(Jmax(:)>min(Jmax(:))),'descend'); T = tmp(6);
cind = find(Jmax>=T); [cx, cy] = ind2sub(size(Jmax), cind);

% Show results --- click on the image when there are multipy frames.
figure(1), imview(hK, h), title('Approx. Pattern');
figure(2), mesh(C'), view(149.3,33.2), title('Cross-Correlation');
figure(3), imview(I0), hold on,
    drawcircles([cx(:),cy(:)],R*ones(length(cx),1),alpha(cind))
title('Detected Pattern')
    
rmpath(paths)