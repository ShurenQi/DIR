%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main framework of this code is based on the implementation:
% Elena Canali. 
% Implementation of "A visual model-based perceptual image hash for content authentication"
% https://github.com/elenacanali/Perceptual-Image-Hash
% and following papers:
% Wang, Xiaofeng, et al.
% "A visual model-based perceptual image hash for content authentication."
% IEEE Transactions on Information Forensics and Security 10.7 (2015): 1336-1349.
% Zheng, Yue, Yuan Cao, and Chip-Hong Chang.
% "A PUF-based data-device hash for tampered image detection and source camera identification."
% IEEE Transactions on Information Forensics and Security 15 (2019): 620-634.
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
% keypoint feature
param.ketpointtype = 'SURF';
param.geodist = 5;
param.georatio = 0.5;
param.registratio = 0.5;
param.minmatches = 4;
param.mintamparea = 0.0001;
param.mintampdist = 0.2;
% block feature
param.type_feat = 10; % type of feature as following:
%    '1.ZM';'2.PZM';'3.OFMM';'4.CHFM';'5.PJFM';'6.JFM';   % Classical Jacobi polynomial based moments
%    '7.RHFM';'8.EFM';'9.PCET';'10.PCT';'11.PST';         % Classical Harmonic function based moments
%    '12.BFM';                                            % Classical Eigenfunction based moments
%    '13.FJFM';                                           % Fractional-order Jacobi polynomial based moments
%    '14.GRHFM';'15.GPCET';'16.GPCT';'17.GPST'            % Fractional-order Harmonic function based moments
param.K = 3;
param.NM = getNM(param.K); % all the n and m for the moments
param.ZNM = getZNM(param.K); % all the n and m for ZM and PZM
param.SNM = getSNM(param.K); % all the n and m for PST and GPST
param.alpha = 1; % parameter for fractional-order moments
param.p = 2; param.q = 2; % parameters for JFM and FJFM
param.scales = [8,10,12]; % all the scales
param.numoffeature = size(param.NM,1); % number of features
param.numofscale = size(param.scales,2); % number of scales
%% load image
index = 5;
orgimg = imread(['Au (',num2str(index),').TIF']); orgimg = imresize(orgimg,0.6);
verimg = imread(['Ta (',num2str(index),').TIF']); verimg  = imresize(verimg ,0.6);
gtimg = imread(['GT (',num2str(index),').PNG']); gtimg = imresize(gtimg,0.6);
atkimg = imattack(verimg); % please select an attack for the image
%% PH with DIR or DCT
[imghash,time] = generation_dir(orgimg,param); [tampflag,geoflag,registfailflag,mask,norimg,hashdistmap]  = verification_dir(imghash,atkimg,param);
% [imghash,time] = generation_dct(orgimg,param); [tampflag,geoflag,registfailflag,mask,norimg,hashdistmap]  = verification_dct(imghash,atkimg,param);
%% show results
clc;
figure;
subplot(221); imshow(orgimg); title('original image');
subplot(222); imshow(atkimg); title('test image');
subplot(223); imshow(norimg); title('normalized image');
ax = subplot(224); imshow(hashdistmap,[]); colormap(ax,jet); title('hash distance map');
if registfailflag == 1
    disp('Image registration failed: irrelevant images or big tampering.');
    return;
end
if tampflag == 0
    disp('No tampering detected.');
    return;
else
    disp('Tampering detected.');
    [FM,measure] = getFmeasure(mask,gtimg);
    disp(['FM = ',num2str(FM)]);
    gtimg=gtimg>150;
    [M,N]=size(mask);
    colormask=128*ones(M,N,3);
    MASK1=colormask(:,:,1);MASK2=colormask(:,:,2);MASK3=colormask(:,:,3);
    MASK1(gtimg)=255;MASK2(gtimg)=255;MASK3(gtimg)=255;
    T=gtimg&mask;
    MASK1(T)=0;MASK2(T)=200;MASK3(T)=50;
    F=xor(gtimg,mask);
    FP=F&mask;
    MASK1(FP)=255;MASK2(FP)=0;MASK3(FP)=0;
    colormask(:,:,1)=MASK1;colormask(:,:,2)=MASK2;colormask(:,:,3)=MASK3;
    figure;imshow(uint8(colormask));
    if geoflag == 1
        title(['Tampering detected, under geometric attacks. ','FM = ',num2str(FM)]);
    else
        title(['Tampering detected, no geometric attacks. ','FM = ',num2str(FM)]);
    end
end
disp(['time: ',num2str(time)]);






