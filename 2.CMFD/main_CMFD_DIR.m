%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main framework of this code is based on the paper:
% D. Cozzolino, G. Poggi and L. Verdoliva.
% "Efficient dense-field copy-move forgery detection"
% IEEE Transactions on Information Forensics and Security 10.11 (2015): 2284-2297.
% and the official implementation:
% http://www.grip.unina.it/download/prog/CMFD/CMFD_PM_code.zip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The DIR in this code was developed by Shuren Qi
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
% parameters Feature Extraction
param = struct();
param.type_feat = 3; % type of feature, one of the following:
    % 1) ZM-cart
    % 2) ZM-polar 
    % 3) PCT-cart
    % 4) PCT-polar
    % 5) FMT (log-polar)
diameter_feat = {16,16,16,16,24}; 
param.diameter  = diameter_feat{param.type_feat}; % patch diameter
param.ZM_order  = 5;
param.PCT_NM    = [0,0;0,1;0,2;0,3; 1,0;1,1;1,2;2,0;2,1;3,0];
param.FMT_N     = -2:2; param.FMT_M  =  0:4;
param.radiusNum = 26; % number of sampling points along the radius
param.anglesNum = 32; % number of sampling points along the circumferences
param.radiusMin = sqrt(2); % minimun radius for FMT
param.scales = [8,10,12,14,16,19,22,25,29,32]; % all the scales
param.numofscale = size(param.scales,2); % number of scales

% parameters Matching
param.num_iter = 8; % N_{it} = number of iterations
param.th_dist1 = 8; % T_{D1} = minimum length of offsets
param.num_tile = 1; % number of thread

% parameters Post Processing
param.th2_dist2 = 50*50; % T^2_{D2} = minimum diatance between clones
param.th2_dlf   = 300;   % T^2_{\epsion} = threshold on DLF error
param.th_sizeA  = 1200;  % T_{S} = minimum size of clones
param.th_sizeB  = 1200;  % T_{S} = minimum size of clones
param.rd_median = 4;     % \rho_M = radius of median filter
param.rd_dlf    = 6;     % \rho_N = radius of DLF patch
param.rd_dil    = param.rd_dlf+param.rd_median; % \rho_D = radius for dilatetion


%% load input
filename_img = 'fountain_copy_s800.png'; filename_gt = 'fountain_gt_s800.png';
img = imread(filename_img);

%% CMFD with DIR
[img,flag,sz1,sz2] = enlarge(img); % optional
[mask,param,data] = CMFD_DIR(img,param);

%% show results
mpf_y_pre = double(data.cnn(:,:,2));
mpf_x_pre = double(data.cnn(:,:,1));
mpf_y     = double(data.cnn_end(:,:,2));
mpf_x     = double(data.cnn_end(:,:,1));

figure();
subplot(2,2,1);
imshow(img);
title('forged image');
subplot(2,2,2);
imshow(double(repmat(mask,[1,1,3])));
if sum(mask(:))>0,
    title(sprintf('output by %s\n this image is forged', data.feat_name));
else
    title(sprintf('output by %s\n this image is pristine', data.feat_name));
end;
subplot(2,2,3);
displayMPF(img,mpf_x,mpf_y,[1,1],data.maskMPF);
title('selected offsets');
if exist('filename_gt','var'),
    maskGT = imread(filename_gt);
    if flag == 1
        maskGT = imresize(maskGT,[sz1,sz2]);
    end
%     maskGT = rgb2gray(maskGT);
    [FM,measure] = getFmeasure(mask,maskGT); disp(measure);
    [col,map] = getFalseColoredResult(mask,maskGT);
    
    subplot(2,2,4);
    imshow(col,map);
    title(sprintf('result, FM = %5.3f', FM));
end;

% Uncomment the following lines if you want to reproduce figure 4 of the
% original paper
% 
figure();
subplot(2,3,1);
imshow(img);
title('forged image');
subplot(2,3,2);
dist2 = MPFspacedist2(mpf_y_pre,mpf_x_pre);
max_dist = max(sqrt(dist2(:)));
imshow(sqrt(dist2),[0, max_dist]); colormap(jet()); %colorbar(); 
title('magnitude of offsets');
subplot(2,3,3);
dist2 = MPFspacedist2(mpf_y,mpf_x);
imshow(sqrt(dist2),[0, max_dist]); colormap(jet()); %colorbar();
title('median filtering');
subplot(2,3,4);
DLF_db = 10*log10(data.DLFerr); DLF_db(DLF_db<-50) = -50;
imshow(DLF_db,[]); colormap(jet()); %colorbar();
title('fitting error (db)');
subplot(2,3,5);
imshow(double(repmat(data.maskDLF,[1,1,3])));
title('thresholding of fitting error');
subplot(2,3,6);
imshow(double(repmat(mask,[1,1,3])));
title('final mask');
