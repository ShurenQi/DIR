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
param.type_feat = 10; % type of feature as following:
%    '1.ZM';'2.PZM';'3.OFMM';'4.CHFM';'5.PJFM';'6.JFM';   % Classical Jacobi polynomial based moments
%    '7.RHFM';'8.EFM';'9.PCET';'10.PCT';'11.PST';         % Classical Harmonic function based moments
%    '12.BFM';                                            % Classical Eigenfunction based moments
%    '13.FJFM';                                           % Fractional-order Jacobi polynomial based moments
%    '14.GRHFM';'15.GPCET';'16.GPCT';'17.GPST'            % Fractional-order Harmonic function based moments   
param.NM = [0,0;0,1;0,2;0,3;1,0;1,1;1,2;2,0;2,1;3,0]; % all the n and m for the moments
param.ZNM = [0,0;1,1;2,0;2,2;3,1;3,3;4,0;4,2;4,4;5,1]; % all the n and m for ZM and PZM
param.SNM = [1,0;1,1;1,2;2,0;2,1;2,2;3,0;3,1;3,2;3,3]; % all the n and m for PST and GPST
param.alpha = 1; % parameter for fractional-order moments
param.p = 2; param.q = 2; % parameters for JFM and FJFM
param.scales = [8,10,12,14,16,19,22,25,29,32]; % all the scales
param.numofscale = size(param.scales,2); % number of scales
%% load image
img = imread('texture.jpg');
%% DIR
[feat,time] = DIR(img,param);
%% show results
fprintf('time: %0.3f\n',time);
figure;
imshow(img,'Border','tight'); hold on; 
h=figure; set(h,'position',[0 0 500 500]);
ha = tight_subplot(3,3,[.02 .02],[.08 .08],[.08 .08]);
ss = [1,5,10]; nn = [1,2,4];
for i = 1:3
    for j = 1:3
        index = (i-1)*3+j;
        axes(ha(index));
        imshow(feat{ss(j)}(:,:,nn(i)),[]);
        colormap jet
        set(gca,'XColor','white')
        set(gca,'YColor','white')
        if index==1
            title('\itw\rm = 8');
            ylabel('\itn, m\rm = 0','Color','k');
            set(gca,'FontName','Times New Roman','FontSize',20);
        elseif index==2
            title('\itw\rm = 16');
            set(gca,'FontName','Times New Roman','FontSize',20);
        elseif index==3
            title('\itw\rm = 32');
            set(gca,'FontName','Times New Roman','FontSize',20);
        elseif index==4
            ylabel('\itn, m\rm = 1','Color','k');
            set(gca,'FontName','Times New Roman','FontSize',20);
        elseif index==7
            ylabel('\itn, m\rm = 3','Color','k');
            set(gca,'FontName','Times New Roman','FontSize',20);
        end
        set(gca,'XTick', []);
        set(gca,'YTick', []);
        axis equal
    end
end



