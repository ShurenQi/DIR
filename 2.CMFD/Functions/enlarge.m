function  [OOI,flag,SZ1,SZ2]    =   enlarge(OI)
[SZ1,SZ2,~]=size(OI);
if max([SZ1,SZ2])<2000
    factor=2000/max([SZ1,SZ2]);
    OOI=imresize(OI,factor);
    flag=1;
else
    OOI=OI;
    flag=0;
end
[SZ1,SZ2,~]=size(OOI);
end

