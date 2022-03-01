clc; clear; close all;
functionname='main.m';
functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '/SIFTflow'])
addpath([functiondir '/flowVis'])

im1color = double(imread('images/stereo3/img1.png'))/255;
im2color = double(imread('images/stereo3/img2.png'))/255;

im1color = imresize(imfilter(im1color,fspecial('gaussian',7,1.),'same','replicate'),0.75,'bicubic');
im2color = imresize(imfilter(im2color,fspecial('gaussian',7,1.),'same','replicate'),0.75,'bicubic');
im1 = double(rgb2gray(im1color));
im2 = double(rgb2gray(im2color));

[row,col] = size(im1);
figure; imshow(im1color); title('Image 1');
figure; imshow(im2color); title('Image 2');

%% DASC Feature Description
M_half = 15;
N_half = 2;
epsil = 0.09;
downSize = 1;
sigma_s = 2;
sigma_r = 0.2;
iter = 1;

load rp1_Middlebury.mat;
load rp2_Middlebury.mat;

%% DASC with Guided Filtering (GF)
% dense_dasc1 = mexDASC_GF(im1,M_half,N_half,rp1,rp2,epsil,downSize);
% dense_dasc2 = mexDASC_GF(im2,M_half,N_half,rp1,rp2,epsil,downSize);

%% DASC with Recursive Filtering (RF)
dense_dasc1 = mexDASC_RF(im1,rp1,rp2,sigma_s,sigma_r,iter);
dense_dasc2 = mexDASC_RF(im2,rp1,rp2,sigma_s,sigma_r,iter);

%% SIFT Flow Estimation and Warping
scaleF = 1.6;
SIFTflowpara.alpha=0.6*scaleF;
SIFTflowpara.d=20*SIFTflowpara.alpha*scaleF;
SIFTflowpara.gamma=0;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=5;
SIFTflowpara.topwsize=20;
SIFTflowpara.nIterations=60;

[vx,vy,energylist]=SIFTflowc2f(dense_dasc1,dense_dasc2,SIFTflowpara);

%% Flow Visualization and Warping 
warpI2=warpImage(im2color,vx,vy);
figure; imshow(uint8(warpI2*255)); title('Warped Image 2');
imwrite(uint8(warpI2*255), 'results/warp2.png');

clear flow;
flow(:,:,1)=vx;
flow(:,:,2)=vy;
figure; imshow(createOverlayImage(im1,flowToColor(flow))); title('SIFT flow field');
imwrite(createOverlayImage(im1,flowToColor(flow)), 'results/flow.png');