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

function [tampflag,geoflag,registfailflag,mask,norimg,hashdistmap] = verification_dir(imghash,atkimg,param)
if size(atkimg,3)>1
    atkimg = rgb2gray(atkimg);
end
newimghash=cell(1,5);
newimghash{4}=imghash{4};
newimghash{5}=imghash{5};
tampflag = 0;
geoflag = 0;
registfailflag = 0;
norimg = [];
hashdistmap = [];
%% keypoint feature
if strcmp(param.ketpointtype, 'SURF')
    [features,locations] = extractFeatures(atkimg,detectSURFFeatures(atkimg,'MetricThreshold',100));
    newimghash{1}=double(features');
    newimghash{3}=double(locations.Location);
end
if strcmp(param.ketpointtype, 'SIFT')
    [locations,features] = vl_sift(single(atkimg));
    newimghash{1}=double(features);
    newimghash{3}=locations(1:2,:)';
end
%% matching
if strcmp(param.ketpointtype, 'SURF')
    pz=matchFeatures(imghash{1}',newimghash{1}','Unique',true);
end
if strcmp(param.ketpointtype, 'SIFT')
    pz=vl_ubcmatch(imghash{1}, newimghash{1})';
end
if sum(pz) < param.minmatches
    registfailflag = 1;
    tampflag = 0.5;
    geoflag = 0.5;
    mask = [];
    return;
end
matches_org = imghash{3}(pz(:,1),:);
matches_new = newimghash{3}(pz(:,2),:);
%% normalizing
matchesdist=zeros(1,size(matches_org,1));
for i=1:size(matchesdist,2)
    matchesdist(i)=norm(matches_org(i,:)-matches_new(i,:));
end
if sum(matchesdist<param.geodist)/size(matchesdist,2) < param.georatio
    geoflag = 1;
    [results]=runRANSAC([flip(matches_new',1);flip(matches_org',1)]);
    H = [results.Theta(1) -results.Theta(2) 0; results.Theta(2) results.Theta(1) 0; results.Theta(4) results.Theta(3) 1];
    tform = maketform('affine',H);
    norimg = imtransform(atkimg,tform,'xdata',[1, newimghash{5}],'ydata',[1, newimghash{4}]);
    mask0 = norimg == 0; mask0 = imdilate(mask0, strel('disk',16)); mask0 = imfill(mask0,'holes');
    mask1 = zeros(size(mask0)); mask1(8:end-8,8:end-8) = 1; mask1 = ~mask1;
else
    norimg = atkimg;
    mask0 = zeros(size(norimg));
    mask1 = zeros(size(mask0)); mask1(8:end-8,8:end-8) = 1; mask1 = ~mask1;
end
if sum(mask0(:))/(imghash{4}*imghash{5}) > param.registratio
    registfailflag = 1;
    tampflag = 0.5;
    geoflag = 0.5;
    mask = [];
    return;
end
%% block feature
[feat,~] = DIR(padarray(norimg,[param.scales(end)/2 param.scales(end)/2],'symmetric' ,'both'),param); poolfeat = pooling(feat,param.numoffeature,param.numofscale); clear feat;
poolfeat = poolfeat(1:imghash{4},1:imghash{5},:);
newimghash{2} = poolfeat(1:8:end,1:8:end,:);
%% comparison
hashdist = zeros(size(newimghash{2},1),size(newimghash{2},2));
hashdistmap = zeros(imghash{4},imghash{5});
for i = 1:1:size(newimghash{2},1)
    for j = 1:1:size(newimghash{2},2)
        hashdist(i,j) = norm(reshape(imghash{2}(i,j,:),1,[])-reshape(newimghash{2}(i,j,:),1,[]));
        hashdistmap((i-1)*8+1:(i-1)*8+8,(j-1)*8+1:(j-1)*8+8) = ones(8,8).*hashdist(i,j);
    end
end
hashdistmap = hashdistmap(1:imghash{4},1:imghash{5});
if geoflag == 1
    hashdistmap(mask0)=0;
end
%% localizing
norhashdistmap = (hashdistmap-min(hashdistmap(:)))./(max(hashdistmap(:))-min(hashdistmap(:)));
norhashdistmap = imfilter(norhashdistmap,fspecial('disk',16));
hashdistth = graythresh(norhashdistmap);
if hashdistth<param.mintampdist
    hashdistth = param.mintampdist;
end
mask = norhashdistmap>hashdistth;
mask = (mask-mask0-mask1)>0;
sedisk = strel('disk',8);
mask = imdilate(mask, sedisk);
minarea = size(mask,1)*size(mask,2)*param.mintamparea;
mask = imfill(mask,'holes');
mask = logical(mask);
mask = mask(param.scales(end)/2:end,param.scales(end)/2:end);
mask = padarray(mask,[param.scales(end)/2-1 param.scales(end)/2-1],'symmetric' ,'post');
if sum(mask(:)) > minarea
    tampflag = 1;
end
hashdistmap= uint8(norhashdistmap.*255);
end