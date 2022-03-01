function J=imcontrast(varargin)
if nargin==1&iscell(varargin{1})
    varargin=varargin{1};
end
for k=1:length(varargin)
    varargin{k}=squeeze(varargin{k});
end
[a,b]=size(varargin);
if b==1&a~=1,varargin=varargin';end
[M,N]=size(varargin{1});
p=0.99;

if length(varargin)==1
    I=varargin{1};
    n=find(~isnan(I));
    [I0,j0]=significant(I(n),p);
    a=min(I(n(j0)));
    b=max(I(n(j0)));
    if b==a
        b=min(I(find(I>a)));
        if isempty(b)
            b=a+1;
            warning('Image is constant!')
        end
    end
    J=255/(b-a)*(I-a);
else
    I=reshape(cell2mat(varargin),M,N*length(varargin));
    n=find(~isnan(I));
    [I0,j0]=significant(I(n),p);
    a=min(I(n(j0)));
    b=max(I(n(j0)));
    if b==a
        b=min(I(find(I>a)));
        if isempty(b)
            b=a+1;
            warning('Images are constant!')
        end
    end
    J=255/(b-a)*(I-a);
    J=mat2cell(J,M,N*ones(1,length(varargin)));
end
        