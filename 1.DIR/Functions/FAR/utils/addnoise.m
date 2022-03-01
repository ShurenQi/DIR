function I0=addnoise(I,PSNR,reference)
% I0=addnoise(I,PSNR,[reference])
% Add Gaussian white noise with chosen PSNR to the image I
%

if nargin<=2
    reference='image';
end

b=randn(size(I));                   % Create unit variance white Gaussian noise

if reference=='image'
    variance=10^(-PSNR/10)*...          % Definition of the PSNR with 
        max(abs(I(:)))^2/mean(b(:).^2); % reference to the maximum of the image
else
    variance=10^(-PSNR/10)*...          % Definition of the PSNR with 
        reference^2/mean(b(:).^2);      % reference to some other value (e.g., 255)
end 
sigma=sqrt(variance);

I0=I+sigma*b;