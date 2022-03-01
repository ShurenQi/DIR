%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Kokkinos, Iasonas, and Alan Yuille.
% "Scale invariance without scale selection."
% IEEE Conference on Computer Vision and Pattern Recognition 2008.
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
% parameters Feature Extraction
param.sc_min = 3;        %% min ring radius
param.sc_max = 231;      %% max ring radius
param.nsteps = 28;       %% number of rings
param.nrays  = 32;       %% number of rays
param.sc_sig = 0.1400;   %% (Gaussian sigma / ring radius) ratio
param.nors   = 4;        %% number of derivative orientations
param.cmp    = 1;        %% compress the invariant descriptor
fc = 2;                  %% point spacing in pixels
% parameters Matching
param.matchratio = 4.5/5; % parameter for generating a matching threshold based on feature distances
% parameters Post Processing
param.sesize = 10; % parameter for imdilate
%% load image
filename_img = 'Image\Dense Detection\shurenqi.tif';
img = imread(filename_img);
orgimg = rgb2gray(img);
ref = orgimg(63:133-1,80:150-1,:);
atkimg = imattack(orgimg); % please select an attack for the image
%% SID
t = tic; [polar,desc,grd] = get_descriptors(atkimg,param,fc); time = toc(t);
%% matching and post processing
[~,descref,~] = get_descriptors(ref,param,fc);
R = 35; y1 = round(R/fc); x1 = round(R/fc);
ds_ref = descref(:,:,:,y1,x1);
szd = size(desc);
pho = squeeze(sum(sum(sum((desc  - repmat(ds_ref,[1,1,1,szd([4,5])])).^2,1),2),3));
pho = pho-min(pho(:)); pho = max(pho(:))-pho;
TH = (max(pho(:))-min(pho(:)))*param.matchratio + min(pho(:));
pho = imresize(pho,fc);
mask = pho>TH ;
mask = imdilate(mask, strel('disk',param.sesize));
%% show results
figure;subplot(121);imshow (atkimg);subplot(122);imshow (ref);
figure;imshow(pho ,[]); colormap(jet());
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
disp(['time:  ',num2str(time)]);  
disp(['PSNR:  ',num2str(psnr(uint8(orgimg),uint8(atkimg)))]);
