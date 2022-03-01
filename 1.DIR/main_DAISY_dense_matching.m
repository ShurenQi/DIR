%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tola, Engin, Vincent Lepetit, and Pascal Fua. 
% "A fast local descriptor for dense matching." 
% IEEE conference on computer vision and pattern recognition. 2008.
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
%% parameters 
param = struct();
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
%% DAISY
t = tic; dzy = compute_daisy(img); timef = toc(t);
poolfeat = zeros(size(img,1),size(img,2),200);
for i = 1:1:size(img,1)
    for j = 1:1:size(img,2)
        poolfeat(i,j,:) = dzy.descs((j-1)*size(img,1)+i,:);
    end
end
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



