function Ia=imagefilter(I,freqresp,extension)
% Syntax: Ia=imagefilter(I,freqresp,extension);
% freqresp is a handle to a function describing the Frequency response of
% the filter. For instance, a Gaussian filtering would be called like:
% sigma=1;Ia=imagefilter(I,@(wx,wy)exp(-sigma^2*(wx.^2+wy.^2)/2));
% If unspecified, the extension is equal to 2 (whole-point mirror image
% extension). Use extension=1 for periodic boundary extension.
if nargin~=3
    extension=2;
end
switch extension
    case 1
        % Periodic image extension
    case 2
        % Whole-point mirror image extension
        K=min(20,floor(min(size(I(:,:,1)))/2));
        I=[I(:,K:-1:2) I I(:,(end-1):-1:(end-K+1))];
        I=[I(K:-1:2,:);I;I((end-1):-1:(end-K+1),:)];
end

[s1,s2]=size(I);
II=fft2(I);

k1=(1:s1)-1;
k2=(1:s2)-1;

% Wrapping frequencies from [0,N-1] to [-N/2,N/2]
N=s1;k1=k1.*(k1<N/2)+(k1-N).*(k1>=N/2);
k1=k1'*ones(1,s2);
N=s2;k2=k2.*(k2<N/2)+(k2-N).*(k2>=N/2);
k2=ones(s1,1)*k2;

% Building the frequency response of the filter
filter=freqresp(2*pi*k1/s1,2*pi*k2/s2);
filter=double(filter);

% Filtering in the frequency domain
II=filter.*II;

% Retrieval of the spatial image
Ia=ifft2(II);
if abs(imag(Ia(:)))<=1e-10
    Ia=real(Ia);
end

switch extension
    case 1
        % Periodic image extension
    case 2
        % Whole-point mirror image extension
        Ia=Ia(K:(s1-K+1),K:(s2-K+1));
end