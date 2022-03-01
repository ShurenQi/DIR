%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code was developed by Shuren Qi
% https://shurenqi.github.io/
% i@srqi.email / shurenqi@nuaa.edu.cn
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;
clc;
addpath(genpath(pwd));
dbstop if error
warning('off'); 
%% parameters 
param = struct();
% parameters Feature Extraction
param.type_feat = 10; % type of feature as following:
%    '1.ZM';'2.PZM';'3.OFMM';'4.CHFM';'5.PJFM';'6.JFM';   % Classical Jacobi polynomial based moments
%    '7.RHFM';'8.EFM';'9.PCET';'10.PCT';'11.PST';         % Classical Harmonic function based moments
%    '12.BFM';                                            % Classical Eigenfunction based moments
%    '13.FJFM';                                           % Fractional-order Jacobi polynomial based moments
%    '14.GRHFM';'15.GPCET';'16.GPCT';'17.GPST'            % Fractional-order Harmonic function based moments   
param.NM = [0,0;0,1;0,2;0,3;1,0;1,1;1,2;2,0;2,1;3,0]; % all the n and m for the moments
param.ZNM = [0,0;1,1;2,0;2,2;3,1;3,3;4,0;4,2;4,4;5,1]; % all the n and m for ZM and PZM
param.SNM = [1,0;1,1;1,2;2,0;2,1;2,2;3,0;3,1;3,2;3,3]; % all the n and m for PST and GPST
param.alpha = 1; % parameter for fractional-order moments
param.p = 2; param.q = 2; % parameters for JFM and FJFM
param.scales = [8,10,12,14,16,19,22,25,29,32]; % all the scales
param.numoffeature = size(param.NM,1); % number of features
param.numofscale = size(param.scales,2); % number of scales
% parameters Matching
param.num_iter = 8; % number of iterations
param.th_dist1 = 8; % minimum length of offsets
param.num_tile = 1; % number of thread
% parameters Post Processing
param.th2_dist2 = 100*100; % minimum diatance between clones
param.th2_dlf   = 600;   % threshold on DLF error
param.rd_median = 4;     % radius of median filter
param.rd_dlf    = 6;     % radius of DLF patch
%% load image
filename_img = 'Image\Dense Matching\2.jpg';
orgimg = imread(filename_img);
orgimg = imresize(orgimg, [1000 NaN]);
atkimg = imattack(orgimg); % please select an attack for the image
img = [orgimg,atkimg];
%% DIR
[feat,timef] = DIR(img,param); poolfeat = pooling(feat,param.numoffeature,param.numofscale); clear feat;
%% matching and post processing
t = tic; cnn   = vecnnmex_mod(poolfeat, poolfeat, 1, param.num_iter, -param.th_dist1, param.num_tile); timem = toc(t);
mpf_y = double(cnn(:,:,2,1));
mpf_x = double(cnn(:,:,1,1));
[DD_med, NN_med] = genDisk(param.rd_median); NN_med = (NN_med+1)/2;
[ mpf_y,  mpf_x] = MPFregularize(mpf_y,mpf_x,DD_med,NN_med);
DLFerr  =  DLFerror(mpf_y,mpf_x,param.rd_dlf);
mask    = (DLFerr<=param.th2_dlf);
dist2 = MPFspacedist2(mpf_y,mpf_x);
mask  = mask & (dist2>=param.th2_dist2);
MP = displayMPF(img,mpf_x,mpf_y,[1,1],mask);
matchedPoints1 = [MP(1,:);MP(2,:)]';
matchedPoints2 = [MP(3,:);MP(4,:)]';
[results]=runRANSAC([matchedPoints1';matchedPoints2']);
inliers = results.CS;
sMP=MP(:,inliers);
maskimg = zeros(size(img,1),size(img,2));
for i = 1:size(sMP,2)
    if sMP(1,i)>0 && sMP(3,i)>0
        maskimg(sMP(1,i),sMP(2,i)) = 1; maskimg(sMP(3,i),sMP(4,i)) = 1;
    end
end
maskimg = maskimg(:,size(maskimg,2)/2:end);
nopix_maskimg = sum(sum(maskimg));
nopix_atkimg = sum(sum(rgb2gray(atkimg)>0));
%% show results
figure;
dist2 = MPFspacedist2(mpf_y,mpf_x);
max_dist = max(sqrt(1000^2+(2668)^2));
imshow(sqrt(dist2),[0, max_dist]); colormap(jet()); 
figure;
imshow(img,'Parent',gca()); hold on;
a=sMP(1,:);b=sMP(2,:);c=sMP(3,:);d=sMP(4,:);
T = quiver(b,a,d-b,c-a, 0,'g');
set(T, 'Linewidth', 1,'ShowArrowHead','off');
hold off; axis off;
clc;
disp(['time for feature:  ',num2str(timef)]);
disp(['time for matching:  ',num2str(timem)]);
disp(['PSNR:  ',num2str(psnr(uint8(orgimg),uint8(atkimg)))]);
disp(['# matches:  ',num2str(size(sMP,2))]);
disp(['repeatability score:  ',num2str(nopix_maskimg/nopix_atkimg)]);



