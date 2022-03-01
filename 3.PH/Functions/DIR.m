%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code was developed by Shuren Qi
% https://shurenqi.github.io/
% i@srqi.email / shurenqi@nuaa.edu.cn
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [featcell,time] = DIR(img,param)
%% input
if size(img,3) ~= 1
    img = rgb2gray(img);
end
img = double(img);
fprintf('START DIR\n'); drawnow();
timestamp = tic;
%% basis functions
bfdatacell = cell(1,param.numofscale);
for ns = 1:1:param.numofscale
    sizeofbf = param.scales(ns);
    if mod(sizeofbf,2) == 1
        sizeofbf = sizeofbf - 1;
    end
    if param.type_feat == 1 || param.type_feat == 2
        bfdatacell{ns} = getBF(param.type_feat,sizeofbf,param.ZNM,param.alpha, param.p, param.q);
    elseif param.type_feat == 11 || param.type_feat == 17
        bfdatacell{ns} = getBF(param.type_feat,sizeofbf,param.SNM,param.alpha, param.p, param.q);
    else
        bfdatacell{ns} = getBF(param.type_feat,sizeofbf,param.NM,param.alpha, param.p, param.q);
    end
end
%% naive computation
% raggioU =  ceil((sizeofbf-1)/2);
% raggioL = floor((sizeofbf-1)/2);
% featcell = cell(1,param.numofscale);
% for  ns = 1:1:param.numofscale
%     featcell{ns} = abs(bf_filter(img, bfdatacell{ns}));
%     featcell{ns} = featcell{ns}((1+raggioU):(end-raggioL),(1+raggioU):(end-raggioL),:);
% end
%% fast computation by FFT with Convolution Theorem
featcell = cell(1,param.numofscale);
fft_img = fft2(img);
nof = size(bfdatacell{1},3);
fft_img_cell = single(zeros([size(img), nof]));
for i = 1:1:nof
    fft_img_cell(:,:,i) = fft_img;
end
featcell{param.numofscale} = abs(bf_filter_fft(img, fft_img_cell, bfdatacell{param.numofscale}));
unisize = size (featcell{param.numofscale});
for  ns = 1:1:param.numofscale-1
    temp = abs(bf_filter_fft(img, fft_img_cell, bfdatacell{ns}));
    rr = (size(temp)-unisize)/2;
    featcell{ns} = temp ((1+rr(1)):(end-rr(1)),(1+rr(2)):(end-rr(2)),:);
end
%% output
clc;
time = toc(timestamp);
end