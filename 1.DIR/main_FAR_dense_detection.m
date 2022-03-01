%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Zhao, Tianle, and Thierry Blu.
% "The Fourier-Argand representation: An optimal basis of steerable patterns."
% IEEE Transactions on Image Processing 29 (2020): 6357-6371.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is slightly modified for experiment by Shuren Qi 
% i@srqi.email
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;
clc;
addpath(genpath(pwd));
dbstop if error
warning('off');
%% parameter
param = struct();
% parameters Feature Extraction
param.K = 20;
% parameters Matching
param.matchratio = 4/5; % parameter for generating a matching threshold based on feature distances
% parameters Post Processing
param.sesize = 10; % parameter for imdilate
%% load input
orgimg = double(rgb2gray(imread('Image\Dense Detection\shurenqi.tif')));
centre = [98,115]; R = 35; 
mask = abs((-R:R)'*ones(1,2*R+1)+1i*ones(2*R+1,1)*(-R:R))<=R;
ref = orgimg (centre(1)-R:centre(1)+R, centre(2)-R:centre(2)+R).*mask;
atkimg = imattack(orgimg); % please select an attack for the image
%% FAR
[pho, alpha, time, refK] = FA_filter(atkimg, 'pattern', ref, param.K);
%% matching and post processing
TH = (max(pho(:))-min(pho(:)))*param.matchratio + min(pho(:));
mask = pho>TH ;
mask = imdilate(mask, strel('disk',param.sesize));
%% show results
figure;subplot(121);imshow (atkimg);subplot(122);imshow (ref);
figure;imshow(pho,[]); colormap(jet());
figure;imshow(mask,[]);
figure; imshow (atkimg);hold on;
bound = ceil((size(atkimg)-size(pho))/2);
[l,n]=bwlabel(mask,4);
theta=0:2*pi/36:2*pi;
for i = 1:n
    [r,c] = find(l == i);
    xy = zeros(size(mask));
    xy(sub2ind(size(xy), r, c))=1;
    temp = pho.*xy;
    temp(~xy) = min(temp(:));
    [x,y] = find(temp == max(temp(:)));
    s = R*2;
    plot(y+floor(s/2)*cos(theta),x+floor(s/2)*sin(theta),'r','Linewidth',5);
end
clc;
disp(['time:  ',num2str(time.FA_approximation+time.Filtering+time.Maximisation)]);  
disp(['PSNR:  ',num2str(psnr(uint8(orgimg),uint8(atkimg)))]);