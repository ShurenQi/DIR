function [x,j]=significant(x,p)
jnan=find(~isnan(x));
if ~isreal(x)
    x0=abs(x-(median(real(x(jnan)))+i*median(imag(x(jnan)))));
else
    x0=x;
end
N=length(x0(:));
K=round(p*N);

x1=sort(x0(:));
a=1:(N-K+1);
[~,j]=min(x1(a+K-1)-x1(a));

a0=a(j(1));
a1=a0+K-1;
j=find(x0>=x1(a0)&x0<=x1(a1));
x(setdiff(1:length(x(:)),j))=NaN;


