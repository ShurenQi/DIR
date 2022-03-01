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

function [imghash,time] = generation_dct(orgimg,param)
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
nob=floor(imghash{4}/8)*floor(imghash{5}/8);
blocks=mat2cell(orgimg, 8*ones(1,floor(imghash{4}/8)), 8*ones(1,floor(imghash{5}/8)));
blocks=reshape(blocks,1,nob);
CB=zeros(nob, 8, 8);
for i=1:nob
    CB(i, :, :)=dct2(blocks{i});
end
% imghash{2}=zeros(64, nob);
imghash{2}=zeros(32, nob);
for i=1:nob
    tmp=reshape(CB(i,:,:), 8, 8);
    imghash{2}(:, i)=zigzag(tmp)';
end
time = toc(t);
end