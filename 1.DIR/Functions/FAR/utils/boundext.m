function J = boundext(I, W, method)
% Extends 2D matrix 'I' by 'W' at each of the four sides. If 'W' is smaller than
%     0, then the matrix is cropped.
% Usage:
%     J = boundext(I, W, <method>)
% Inputs:
%     I, the 2D matrix to be extended.
%     W, integer, the size of extension (positive) or reduction (negative).
%     method, the type of extension,
%         zpd, zero padding (default);
%         sym, symh, sym_half, half point symmetric extension;
%         symw, sym_whole, whole point symmetric extension;
%         periodic, per, periodic extension.
% Output:
%     J, the extended (W positive) or reduced (W negtive) matrix.
% Programmed by: Tianle Zhao, Jan. 2017.

[M, N] = size(I);
assert((W >= -floor(min(M,N)/2)) && (round(W)-W == 0));

if W <= 0
    J = I(1-W:end+W, 1-W:end+W);
    return;
end

if ~exist('method', 'var')
    method = 'sym';
end

MM = M + 2*W;
NN = N + 2*W;
J = zeros(MM, NN);

if strcmpi(method, 'zpd')
    J(W+1:end-W,W+1:end-W) = I;
    return;
end

x = (-W:M+W-1)' * ones(1,NN);
y = ones(MM,1) * (-W:N+W-1);

switch method
    case {'sym_half', 'symh', 'sym'}
        x = mod(x(:), 2*M); x(x>=M) = 2*M - 1 - x(x>=M);
        y = mod(y(:), 2*N); y(y>=N) = 2*N - 1 - y(y>=N);
        J(:) = I(sub2ind([M,N], x+1, y+1));
    case {'sym_whole', 'symw'}
        x = mod(x(:), 2*M-2); x(x>=M) = 2*M - 2 - x(x>=M);
        y = mod(y(:), 2*N-2); y(y>=N) = 2*N - 2 - y(y>=N);
        J(:) = I(sub2ind([M,N], x+1, y+1));
    case {'periodic', 'per'}
        x = mod(x(:), M);
        y = mod(y(:), N);
        J(:) = I(sub2ind([M,N], x+1, y+1));
    otherwise
        error('Method not supported.');
end