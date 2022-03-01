function I1 = imattack(I0)

I0=uint8(I0);

I1=imrotate(I0,20,'bicubic','crop');

% I1=flip(I0,1);

% I1=imresize(I0,0.8,'bicubic');
% temp=zeros(size(I0));
% if size(I1,1) <= size(I0,1)
%     temp(1:size(I1,1),1:size(I1,2),:)=I1;
% else
%     temp=I1(1:size(I0,1),1:size(I0,2),:);
% end
% I1=temp;


% H=fspecial('average',[3 3]);
% I1=imfilter(I0,H);

% SZ=7;
% I1R=medfilt2(I0(:,:,1),[SZ SZ]);
% I1G=medfilt2(I0(:,:,2),[SZ SZ]);
% I1B=medfilt2(I0(:,:,3),[SZ SZ]);
% I1=I0;
% I1(:,:,1)=I1R;
% I1(:,:,2)=I1G;
% I1(:,:,3)=I1B;
% I1=medfilt2(I0,[SZ SZ]);

% H=fspecial('gaussian',[7,7],3);
% I1=imfilter(I0,H);

% I1 = imnoise(uint8(I0),'salt & pepper',0.2);
 
% I1 = imnoise(uint8(I0),'gaussian',0,0.05);

% imwrite(uint8(I0),'JPEG.jpg','jpg','Quality',5);
% I1 = imread('JPEG.jpg','jpg');

% H=[0,-1,0;-1,5,-1;0,-1,0];
% I1= imfilter(I0,H,'replicate');


% I1=I0;


end

