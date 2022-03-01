function [J, ismaxima] = nonmaximumsupp(I, t)
% This function performs the non-maximum suppression of the input responsse map
%   'I', along the direction specified ty 't'
% Programmed by: Tianle Zhao, Aug. 2019.
rec = @(x,M) (mod(x,2*M-2)<M) .* mod(x,2*M-2) + ...
    (mod(x,2*M-2)>=M) .* (2*M-2-mod(x,2*M-2));  % symmetric extension

[M, N] = size(I);
x = (1:M)' * ones(1,N);
y = ones(M,1) * (1:N);
r = 1;
dx = cos(t)*r;
dy = sin(t)*r;
I1 = interp(I,y+dy,x+dx);
I2 = interp(I,y-dy,x-dx);
ismaxima = I>=I1 & I>I2;
J = I .* ismaxima;
    function Ixy = interp(I, y, x)
        xi = floor(x(:)-1); Dx = x(:)-1-xi;
        yi = floor(y(:)-1); Dy = y(:)-1-yi;
        x0 = rec(xi, M); x1 = rec(xi+1, M);
        y0 = rec(yi, N); y1 = rec(yi+1, N);
        A = I(sub2ind([M,N],x1+1,y0+1));
        B = I(sub2ind([M,N],x0+1,y0+1));
        C = I(sub2ind([M,N],x1+1,y1+1));
        D = I(sub2ind([M,N],x0+1,y1+1));
        Ixy = reshape((1-Dy).*(Dx.*A+(1-Dx).*B)+Dy.*(Dx.*C+(1-Dx).*D),[M,N]);
    end
end