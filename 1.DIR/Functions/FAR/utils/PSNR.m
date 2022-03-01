function Y=PSNR(I,I0,reference)
if nargin<=2
    reference='image';
end
I=I(:);
I0=I0(:);
% if strcmp(reference,'image')|strcmp(reference,'signal')
%     Y=-20*log10(norm(I0-I)/max(abs(I0))/sqrt(length(I0)));
% else
%     if strcmp(reference,'energy')
%         Y=-20*log10(norm(I0-I)/norm(I0));
%     else
%         Y=-20*log10(norm(I0-I)/reference/sqrt(length(I0)));
%     end
% end

switch reference
    case 'image'
        Y=-20*log10(norm(I-I0)/max(abs(I0))/sqrt(length(I0)));
    case 'signal'
        Y=-20*log10(norm(I-I0)/max(abs(I0))/sqrt(length(I0)));
    case 'energy'
        Y=-20*log10(norm(I-I0)/norm(I0));
    case 'contrast'
        A=[I0(:)'*I0(:) sum(I0(:));sum(I0(:)) length(I0(:))];
        B=[I0(:)'*I(:);sum(I(:))];
        a=A\B;
        Y=-20*log10(norm(I-(a(1)*I0+a(2)))/norm(a(1)*I0+a(2)));
    otherwise
        Y=-20*log10(norm(I0-I)/reference/sqrt(length(I0)));
end