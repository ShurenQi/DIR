function J = imfilters(I, h)
% Applies filters specified (in space domain) by 'h'.
% Programmed by: Tianle Zhao, Aug. 2019.

[M, N] = size(I);
[MM, NN, K] = size(h);

bw = floor(max(MM,NN)/2);
I = boundext(I, bw);

J = zeros(M, N, K);
If = fft2(I);
for k = 1:K
    tmp = ifft2(fft2(h(:,:,k),size(I,1),size(I,2)).*If);
    J(:,:,k) = tmp(2*bw+1:end,2*bw+1:end);
end

end