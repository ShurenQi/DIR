function [feat] =getreffeat(img,param)
%% input
if size(img,3) ~= 1
    img = rgb2gray(img);
end
img = double(img);
fprintf('START REF\n'); drawnow();
%% get basis function data
ns = ceil(param.numofscale/2);
sizeofbf = param.scales(ns);
if mod(sizeofbf,2) == 1
    sizeofbf = sizeofbf - 1;
end
if param.type_feat == 1 || param.type_feat == 2
    bfdata = getBF(param.type_feat,sizeofbf,param.ZNM,param.alpha, param.p, param.q);
    L=size(param.ZNM,1);
elseif param.type_feat == 11 || param.type_feat == 17
    bfdata = getBF(param.type_feat,sizeofbf,param.SNM,param.alpha, param.p, param.q);
    L=size(param.SNM,1);
else
    bfdata = getBF(param.type_feat,sizeofbf,param.NM,param.alpha, param.p, param.q);
    L=size(param.NM,1);
end
%% feature generation
feat = zeros(1,L);
for i = 1:1:L
    feat(i) = sum(sum(bfdata(:,:,i).*img));
end
feat = abs(feat);
clc;
end