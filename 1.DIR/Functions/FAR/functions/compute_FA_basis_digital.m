function J = compute_FA_basis_digital(h, K, numAngles)
% This function computes the Fourier-Argand representation of a digital pattern
%   using the discrete Radon transform.
% Usage: 
%   J = compute_FA_basis_digital(h, K, <numAngles>)
% Inputs:
%   h,          the 2D filter/pattern;
%   K,          order of the FA approximation;
%   numAngles,	number of angles for the Radon transform (optional, default
%               360).
% Output:
%   J,          3D array containing the K+1 FA basis functions.
% Example:
%{
    M = 65; x = ((1:M)-(M+1)/2)'*ones(1,M); y = x';
    shape = [3,10]; h = 255*exp(-x.^2/shape(1)^2-y.^2/shape(2)^2);
    K = 20; tic; J = compute_FA_basis_digital(h, K); toc
    hK = J(:,:,1)+2*real(sum(J(:,:,2:end),3));
    figure, imview(hK, h);
    title(sprintf('L2-error = %e',norm(h-hK,'fro')/norm(h,'fro')));
    figure,
    J = reshape(J, [numel(h),K+1]);
    for alpha=0:2:180
        hK = reshape(J(:,1)+2*real(J(:,2:end)*exp(-1i*(1:K)'*alpha/180*pi)),size(h));
        imview(hK), title(['alpha = ',num2str(alpha),]), pause(0.01)
    end
%}
% 
% Programmed by: Tianle Zhao, Aug. 2019.

if ~exist('numAngles','var') || isempty(numAngles)
    N = 360;
else
    N = numAngles;
end
N = max(N, 2*K+1);

phi = 2*pi*(0:N-1)/N;
% phi = linspace(0, 2*pi, L+1); phi = phi(1:end-1); 
R = radon(h, phi*180/pi);
C = fft(R, N, 2);

J = zeros(size(h,1), size(h,2), K+1);
for k = 0:K
    Rk = C(:,k+1)*exp(2i*pi*k/N*(0:N-1))/N;
    J(:,:,k+1) = iradon(real(Rk), phi*180/pi, 'linear', 'Ram-Lak', 1, size(h,1)) ...
        + 1i*iradon(imag(Rk), phi*180/pi, 'linear', 'Ram-Lak', 1, size(h,1));
end