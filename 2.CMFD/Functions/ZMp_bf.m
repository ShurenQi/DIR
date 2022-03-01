function  bfdata = ZMp_bf(SZ, ORDER, radiusNum, anglesNum)
%Compute the Zernike momente functions with polar resample
%  bfdata = ZMp_bf(SZ, NM, radiusNum, anglesNum);
%
%        SZ is the size of patch
%        NM is a matrix with 2 columns, where the first column indicates n and the second column m.
% radiusNum is the number of sampling points along the radius
% anglesNum is the number of sampling points along the circumferences
%
% bfdata is a structure with the following elements:
%  .number     number of basis functions, 
%  .orders     a matrix with 2 columns, where the first column indicates n and the second column m, 
%  .bf         a 3d matrix with the basis functions, 
%  .factor     factor for ortonormal basis functions. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Copyright (c) 2015 Image Processing Research Group of University Federico II of Naples ('GRIP-UNINA').
% All rights reserved.
% this software should be used, reproduced and modified only for informational and nonprofit purposes.
% 
% By downloading and/or using any of these files, you implicitly agree to all the
% terms of the license, as specified in the document LICENSE.txt
% (included in this package) and online at
% http://www.grip.unina.it/download/LICENSE_OPEN.txt
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin<1 || isempty(SZ)       , SZ        = 16; end;
    if nargin<2 || isempty(ORDER)    , ORDER     = 5;  end;
    if nargin<3 || isempty(radiusNum), radiusNum = 26; end;
    if nargin<4 || isempty(anglesNum), anglesNum = 32; end;
        
    
    if isscalar(ORDER),
        NM  = ZM_orderlist(ORDER);
    else
        NM  = ORDER;
    end;
    len   = size(NM,1);
    ORDER = max(NM(:,1));
    F = factorial(0:ORDER);
    
    coef = zeros(len,ORDER);
    WF   = zeros(len,1);
    for index = 1:len
        n = NM(index,1);
        m = NM(index,2);
        tu = floor((n+abs(m))/2);
        td = floor((n-abs(m))/2);
        for s = 0:td, 
           coef(index,s+1) = ( ((-1).^s) .* F(1+n-s) )./ (F(1+s).*F(1+tu-s).*F(1+td-s)); 
        end; 
        WF(index) = sqrt((n+1));
    end;
    
    gf = @(x,y) max(0,1-abs(x)).*max(0,1-abs(y)); % bi-linear
    
    [X,Y] = meshgrid(1:SZ,1:SZ);
    Y = (2.*Y-SZ-1)./2;
    X = (2.*X-SZ-1)./2;
    
    radiusMax = (SZ-1)/2;
    radiusMin = 0;
    radiusPoints = linspace(radiusMin,radiusMax,radiusNum);
    
    BF = zeros(SZ,SZ,len);
    
    for indexA = 1:anglesNum;
        A  = (indexA-1)*360./anglesNum;

        for indexR = 1:radiusNum;
            R = radiusPoints(indexR);
            pX = X - R*cosd(A);
            pY = Y - R*sind(A);
            J = gf(pX,pY);
            R = 2*R/SZ;
            for index = 1:len
                n = NM(index,1);
                m = NM(index,2);
                Rad = 0;
                td = floor((n-abs(m))/2);
                for s = 0:td, 
                    Rad = Rad + coef(index,s+1).*(R.^(n-2*s));
                end;
                Rad = Rad.*(cosd(m*A) + 1i*sind(m*A));
                BF(:,:,index) = BF(:,:,index)+(J*Rad)*R;
            end;
        end;
    end;
    
    WF = WF./sqrt(sum(sum(abs(BF(:,:,1)).^2)));
    
    bfdata = struct;
    bfdata.number   = size(NM,1);
    bfdata.orders   = NM;
    bfdata.bf       = BF;
    bfdata.factor   = WF;
