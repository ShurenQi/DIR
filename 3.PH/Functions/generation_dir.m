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

function [imghash,time] = generation_dir(orgimg,param)
if size(orgimg,3)>1
    orgimg = rgb2gray(orgimg);
end
imghash=cell(1,5);
[imghash{4}, imghash{5}]=size(orgimg);
%% keypoint feature
if strcmp(param.ketpointtype, 'SURF')
    [features,locations] = extractFeatures(orgimg,detectSURFFeatures(orgimg,'MetricThreshold',100));
    imghash{1}=double(features');
    imghash{3}=double(locations.Location);
end
if strcmp(param.ketpointtype, 'SIFT')
    [locations,features] = vl_sift(single(orgimg));
    imghash{1}=double(features); 
    imghash{3}=locations(1:2,:)';
end
%% block feature
t = tic;
[feat,~] = DIR(padarray(orgimg,[param.scales(end)/2 param.scales(end)/2],'symmetric' ,'both'),param); poolfeat = pooling(feat,param.numoffeature,param.numofscale); clear feat;
poolfeat = poolfeat(1:imghash{4},1:imghash{5},:);
imghash{2} = poolfeat(1:8:end,1:8:end,:);
time = toc(t);
end