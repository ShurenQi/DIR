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
param.K = 5;
param.NM = getNM(param.K); % all the n and m for the moments
param.ZNM = getZNM(param.K); % all the n and m for ZM and PZM
param.SNM = getSNM(param.K); % all the n and m for PST and GPST
param.alpha = 1; % parameter for fractional-order moments
param.p = 2; param.q = 2; % parameters for JFM and FJFM
param.scales = [30,40,50,60,70,80,90,100,110,120]; % all the scales
param.numofscale = size(param.scales,2); % number of scales
% parameters Matching
param.matchratio = 4/5; % parameter for generating a matching threshold based on feature distances
% parameters Post Processing
param.sesize = 10; % parameter for imdilate
%% load image
filename_img = 'Image\Dense Detection\shurenqi.tif';
img = imread(filename_img);
orgimg = rgb2gray(img);
ref = orgimg(63:133-1,80:150-1,:);
atkimg = imattack(orgimg); % please select an attack for the image
%% DIR
[feat,time] = DIR(padarray(atkimg,[param.scales(end),param.scales(end)]/2,'both'),param);
%% matching and post processing
[ref_feat] = getreffeat(ref,param);
A = reshape(ref_feat,1,[]);
figure;subplot(121);imshow (atkimg);subplot(122);imshow (ref);
pho_cell = zeros(size(feat{1},1),size(feat{1},2),param.numofscale);
for ns = 1:1:param.numofscale
    newfeat = feat{ns};
    for i = 1:1:size(newfeat,1)
        for j = 1:1:size(newfeat,2)
            B = reshape(newfeat(i,j,:),1,[]);
            pho_cell(i,j,ns) = sqrt(sum((A-B).^2));
        end
    end
end
[pho,pzscale] = min(pho_cell,[],3);
pho = pho-min(pho(:)); pho = max(pho(:))-pho;
TH = (max(pho(:))-min(pho(:)))*param.matchratio + min(pho(:));
mask = pho>TH ;
mask = imdilate(mask, strel('disk',param.sesize));
%% show results
figure;imshow(pho,[]);
colormap(jet());
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
    s = pzscale(x,y);
    plot(y+bound(2)+floor(param.scales(s)/2)*cos(theta),x+bound(1)+floor(param.scales(s)/2)*sin(theta),'r','Linewidth',5);
end
clc;
disp(['time:  ',num2str(time)]);
disp(['PSNR:  ',num2str(psnr(uint8(orgimg),uint8(atkimg)))]);








