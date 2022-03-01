function [J, alpha, time, hK] = FA_filter(I, type, varargin)
% This function performs steerable matched-filtering using the Fourier- Argand 
%   approximation of a given filter/pattern.
% Usage:
%   [J, alpha, time] = FA_filter(I, 'ridge', [a,b], <K>, <numAngles>)
%   [J, alpha, time] = FA_filter(I, 'ridge0', [a,b], <K>, <numAngles>)
%   [J, alpha, time] = FA_filter(I, 'edge', [a,b], <K>, <numAngles>)
%   [J, alpha, time, hK] = FA_filter(I, 'pattern', h, <K>, <numAngles>)
% Inputs:
%   I,      input image to be filtered;
%   type,	'ridge'     --- using built-in ridge filter (elongated Gaussian);
%           'ridge0'    --- using built-in ridge filter (2nd x-derivative of
%                           elongated Gaussian);
%           'edge'      --- using built-in edge filter (x-derivative of
%                           elongated Gaussian);
%           'pattern'	--- using user specified digita filter;
%   [a,b],  shape parameters of ridge/edge filter (for types 'ridge', 'ridge0' 
%           and 'edge');
%   h,      input digital filter, (for type 'pattern');
%   K,      order of Fourier-Argand approximation (optional, default 20);
%   numAngles,  number of angles used by the frequency estimation and Radon 
%               transform (optional, default 360).
% Outputs:
%   J,      filter response;
%   alpha,  local orientation;
%   time,   CPU time consumption;
%   hK,     Fourier-Argand approxition of the pattern ('pattern' mode only).
% 
% Programmed by: Tianle Zhao, Aug. 2019.
% Release note: Version 2.1, added zero-mean ridge filter (2nd derivative of 
%   elongated Gaussian).

[M, N] = size(I);
switch type
    case {'ridge', 'Ridge'}
        a = varargin{1}(1);
        b = varargin{1}(2);
        if nargin > 3   % order of FA approx.
            K = varargin{2};
        else
            K = 20;
        end
        if nargin > 4   % number of angles for maximisation
            L = varargin{3};
        else
            L = 360;
        end
        % Filtering
        Ik = zeros(M*N, K+1); tic;
        H = @(wx,wy) besseli(0,(wx.^2+wy.^2)*(a^2-b^2)/8,1).*exp(-(wx.^2+wy.^2)*min(a,b)^2/4);
        Ik(:,1) = reshape(imagefilter(I,H),[M*N,1]);
        for k = 1:K
            H = @(wx,wy)(-1)^k*besseli(k,(wx.^2+wy.^2)*(a^2-b^2)/8,1).*exp(-(wx.^2+wy.^2)*min(a,b)^2/4).*exp(2i*k*angle(wx+1i*wy));
            Ik(:,k+1) = reshape(imagefilter(I,H),[M*N,1]);
        end
        time.Filtering = toc;
        % Maximisation
        tic;
        [J, k] = max(real(fft([Ik(:,1),2*Ik(:,2:end)], L, 2)),[],2);
        time.Maximasation = toc;
        % Output
        J = reshape(J, [M,N]);
        alpha = reshape(pi*k/L, [M,N]);
    case {'ridge0', 'Ridge0'}
        a = varargin{1}(1);
        b = varargin{1}(2);
        if nargin > 3   % order of FA approx.
            K = varargin{2};
        else
            K = 20;
        end
        if nargin > 4   % number of angles for maximisation
            L = varargin{3};
        else
            L = 360;
        end
        % Filtering
        Ik = zeros(M*N, K+1); tic;
        H = @(wx,wy) (wx.^2+wy.^2)/4.*(2*besseli(0,(wx.^2+wy.^2)*(a^2-b^2)/8,1) ...
            -besseli(-1,(wx.^2+wy.^2)*(a^2-b^2)/8,1)- besseli(1,(wx.^2+wy.^2)*(a^2-b^2)/8,1)) ...
            .*exp(-(wx.^2+wy.^2)*min(a,b)^2/4);
        Ik(:,1) = reshape(imagefilter(I,H),[M*N,1]);
        for k = 1:K
            H = @(wx,wy)(-1)^k*(wx.^2+wy.^2)/4 ...
                .*(2*besseli(k,(wx.^2+wy.^2)*(a^2-b^2)/8,1)-besseli(k-1,(wx.^2+wy.^2)*(a^2-b^2)/8,1)-besseli(k+1,(wx.^2+wy.^2)*(a^2-b^2)/8,1))...
                .*exp(-(wx.^2+wy.^2)*min(a,b)^2/4).*exp(2i*k*angle(wx+1i*wy));
            Ik(:,k+1) = reshape(imagefilter(I,H),[M*N,1]);
        end
        time.Filtering = toc;
        % Maximisation
        tic;
        [J, k] = max(real(fft([Ik(:,1),2*Ik(:,2:end)], L, 2)),[],2);
        time.Maximasation = toc;
        % Output
        J = reshape(J, [M,N]);
        alpha = reshape(pi*k/L, [M,N]);
    case {'edge', 'Edge'}
        a = varargin{1}(1);
        b = varargin{1}(2);
        if nargin > 3   % order of FA approx.
            K = varargin{2};
        else
            K = 20;
        end
        if nargin > 4   % number of angles for maximisation
            L = varargin{3};
        else
            L = 360;
        end
        % Filtering
        Ik = zeros(M*N, K); tic;
        for k = 0:K-1
            H = @(wx,wy)(-1)^k*1i/2*(besseli(k,(wx.^2+wy.^2)*(a^2-b^2)/8,1)-besseli(k+1,(wx.^2+wy.^2)*(a^2-b^2)/8,1))...
                    .*sqrt(wx.^2+wy.^2).*exp(-(wx.^2+wy.^2)*min(a,b)^2/4).*exp(1i*(2*k+1)*angle(wx+1i*wy));
            Ik(:,k+1) = reshape(imagefilter(I,H),[M*N,1]);
        end
        time.Filtering = toc;
        % Maximisation
        tic;
        Ik = kron(Ik, [0,1]);
        [J, k] = max(real(fft([Ik(:,1),2*Ik(:,2:end)], L, 2)),[],2);
        time.Maximasation = toc;
        % Output
        J = reshape(J, [M,N]);
        alpha = reshape(2*pi*k/L, [M,N]);
    case {'pattern', 'Pattern'}
        h = varargin{1};
        if nargin > 3
            K = varargin{2};
        else
            K = 20;
        end
        if nargin > 4
            L = varargin{3};
        else
            L = 360;
        end
        % Approximation
        tic;
        hk = compute_FA_basis_digital(h, K, L);
        time.FA_approximation = toc;
        % Filtering
        tic;
        Ik = imfilters(I, hk);
        time.Filtering = toc;
        % Maximisation
        Ik = reshape(Ik,[M*N,K+1]);
        tic;
        [J, k] = max(real(fft([Ik(:,1),2*Ik(:,2:end)], L, 2)), [], 2);
        time.Maximisation = toc;
        % Output
        J = reshape(J, [M,N]);
        alpha = reshape(mod(2*pi*k/L+pi,2*pi), [M,N]);
        hK = hk(:,:,1)+2*real(sum(hk(:,:,2:end),3));
    otherwise
        error('Filter not supported.')
end

