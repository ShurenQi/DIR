%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The main framework of this code is based on the paper and implementation:
% D. Cozzolino, G. Poggi and L. Verdoliva.
% "Efficient dense-field copy-move forgery detection"
% IEEE Transactions on Information Forensics and Security 10.11 (2015): 2284-2297.
% http://www.grip.unina.it/download/prog/CMFD/CMFD_PM_code.zip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The DIR in this code was developed by Shuren Qi
% https://shurenqi.github.io/
% i@srqi.email / shurenqi@nuaa.edu.cn
% All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mask,param,outData] = CMFD_DIR(img,param)
%% parameters 
% parameters Feature Extraction
if nargin<2 || isempty(param), param = struct(); end;
param = setParameters(param,'type_feat',3); % type of feature, one of the following:
    % 1) ZM-cart
    % 2) ZM-polar 
    % 3) PCT-cart
    % 4) PCT-polar
    % 5) FMT (log-polar)

diameter_feat = {16,16,16,16,24}; 
param = setParameters(param,'diameter',diameter_feat{param.type_feat}); % patch diameter
param = setParameters(param,'ZM_order',5);
param = setParameters(param,'PCT_NM', [0,0;0,1;0,2;0,3; 1,0;1,1;1,2;2,0;2,1;3,0]);
param = setParameters(param,'FMT_N', -2:2); 
param = setParameters(param,'FMT_M',  0:4);
param = setParameters(param,'radiusNum', 26); % number of sampling points along the radius
param = setParameters(param,'anglesNum', 32); % number of sampling points along the circumferences
param = setParameters(param,'radiusMin',sqrt(2)); % minimun radius for FMT
param = setParameters(param,'scales',[8,10,12,14,16,19,22,25,29,32]); % all the scales
param = setParameters(param,'numofscale',size(param.scales,2)); % number of scales

% parameters Matching
param = setParameters(param,'num_iter', 8); % N_{it} = number of iterations
param = setParameters(param,'th_dist1', 8); % T_{D1} = minimum length of offsets
param = setParameters(param,'num_tile', 1); % number of thread

% parameters Post Processing
param = setParameters(param,'th2_dist2', 50*50); % T^2_{D2} = minimum diatance between clones
param = setParameters(param,'th2_dlf'  ,  300);  % T^2_{\epsion} = threshold on DLF error
param = setParameters(param,'th_sizeA' , 1200);  % T_{S} = minimum size of clones
param = setParameters(param,'th_sizeB' , param.th_sizeA);  % T_{S} = minimum size of clones
param = setParameters(param,'rd_median', 4);     % \rho_M = radius of median filter
param = setParameters(param,'rd_dlf'   , 6);     % \rho_N = radius of DLF patch
param = setParameters(param,'rd_dil'   , param.rd_dlf+param.rd_median); % \rho_D = radius for dilatetion


%% Techique
if not(exist('vecnnmex_mod')),
    addpath(fullfile(fileparts(mfilename('fullpath')),'Functions'));
end;
if ischar(img), img = imread(img); end;

outData = struct();
img = color2gray(img); 
%% ========================================DIR=========================================================
timestamp = tic();
bfdatacell = cell(1,param.numofscale);
for ns = 1:1:param.numofscale
    % generation of filters
    sizeofbf = param.scales(ns);
    if mod(sizeofbf,2) == 1
        sizeofbf = sizeofbf - 1;
    end
    if param.type_feat==1,
        outData.feat_name = 'ZM-cart';
        bfdatacell{ns} = ZM_bf(sizeofbf, param.ZM_order);
    elseif param.type_feat==2,
        outData.feat_name = 'ZM-polar';
        bfdatacell{ns} = ZMp_bf(sizeofbf, param.ZM_order, param.radiusNum, param.anglesNum);
    elseif param.type_feat==3,
        outData.feat_name = 'PCT-cart';
        bfdatacell{ns} = PCT_bf(sizeofbf, param.PCT_NM);
    elseif param.type_feat==4,
        outData.feat_name = 'PCT-polar';
        bfdatacell{ns} = PCTp_bf(sizeofbf, param.PCT_NM, param.radiusNum, param.anglesNum);
    elseif param.type_feat==5,
        outData.feat_name = 'FMT';
        bfdatacell{ns} = FMTpl_bf(sizeofbf, param.FMT_M, param.radiusNum, param.anglesNum, param.FMT_N, param.radiusMin);
    else
        error('type of feature not found');
    end;
end

raggioU =  ceil((sizeofbf-1)/2);
raggioL = floor((sizeofbf-1)/2);

% naive computation
%     featcell = cell(1,param.numofscale);
%     for  ns = 1:1:param.numofscale
%         featcell{ns} = abs(bf_filter(img, bfdatacell{ns}));
%         featcell{ns} = featcell{ns}((1+raggioU):(end-raggioL),(1+raggioU):(end-raggioL),:);
%     end

% fast feature generation by FFT (Convolution Theorem)
featcell = cell(1,param.numofscale);
fft_img = fft2(img);
nof = bfdatacell{1}.number;
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

% avg. pooling
feat =  single(zeros(size(featcell{1})));
for nf = 1:1:bfdatacell{1}.number
    temp =  single(zeros(size(featcell{1},1),size(featcell{1},2)));
    for ns = 1:1:param.numofscale
        temp = temp + featcell{ns}(:,:,nf);
    end
    feat(:,:,nf) = temp/param.numofscale;
end

% max pooling
%     feat =  single(zeros(size(featcell{1})));
%     for nf = 1:1:bfdatacell{1}.number
%         temp =  single(zeros(size(featcell{1},1),size(featcell{1},2),param.numofscale));
%         for ns = 1:1:param.numofscale
%             temp(:,:,ns) = featcell{ns}(:,:,nf);
%         end
%         feat(:,:,nf) = max(temp,[],3);
%     end

%% =====================================================================================================
outData.timeFE = toc(timestamp);
fprintf('time FE: %0.3f\n',outData.timeFE); drawnow();
clear fft_img bfdatacell fft_img_cell

%% Matching
timestamp = tic();
    feat  = (feat-min(feat(:)))./(max(feat(:))-min(feat(:))); %mPM requires the features to be in [0,1]
    cnn   = vecnnmex_mod(feat, feat, 1, param.num_iter, -param.th_dist1, param.num_tile);
    mpf_y = double(cnn(:,:,2,1));
    mpf_x = double(cnn(:,:,1,1));
outData.timeMP = toc(timestamp);
fprintf('time PM: %0.3f\n',outData.timeMP); drawnow();
outData.cnn = cnn;

%% Post Processing
timestamp = tic();
    % regularize offsets field by median filtering
    [DD_med, NN_med] = genDisk(param.rd_median); NN_med = (NN_med+1)/2;
    [ mpf_y,  mpf_x] = MPFregularize(mpf_y,mpf_x,DD_med,NN_med);

    % Compute the squared error of dense linear fitting
    DLFerr  =  DLFerror(mpf_y,mpf_x,param.rd_dlf);
    mask    = (DLFerr<=param.th2_dlf);
    outData.maskDLF =  mask;
    
    % removal of close couples
    dist2 = MPFspacedist2(mpf_y,mpf_x);
    mask  = mask & (dist2>=param.th2_dist2);

    % morphological operations
    mask  = bwareaopen(mask,param.th_sizeA,8); 
    outData.maskMPF = mask;
    mask  = MPFdual(mpf_y,mpf_x,mask); % mirroring of detected regions
    mask  = bwareaopen(mask,param.th_sizeB,8);
    mask  = imdilate(mask,strel('disk',param.rd_dil));
    
    % put the borders
    mask = padarray_both(mask,[raggioU,raggioU,raggioL,raggioL],false()); 
    DLFerr = padarray_both(DLFerr,[raggioU,raggioU,raggioL,raggioL],0); 

outData.timePP = toc(timestamp);
fprintf('time PP: %0.3f\n',outData.timePP); drawnow();
outData.cnn_end = cat(3,mpf_x,mpf_y);
outData.DLFerr  = DLFerr;

%% end
fprintf('END : %0.3f\n',outData.timeFE+outData.timeMP+outData.timePP); drawnow();

function param = setParameters(param,name,value)
if not(isfield(param,name)) || isempty(getfield(param,name))
    param = setfield(param,name,value);
end;