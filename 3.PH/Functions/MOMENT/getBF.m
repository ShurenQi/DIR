function [BF]=getBF(MODE,SZ,NM,alpha,p,q)
[rho,theta]=ro(SZ,SZ);
pz=rho>1; cnt=sum(pz(:));rho(pz)= 0.5;
L=size(NM,1);
BF=zeros(SZ,SZ,L);
%% ZM    
if MODE==1
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getZM_RBF(order,repetition,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% PZM    
elseif MODE==2
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getPZM_RBF(order,repetition,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% OFMM
elseif MODE==3
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getOFMM_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% CHFM
elseif MODE==4
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getCHFM_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% PJFM
elseif MODE==5
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getPJFM_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% JFM
elseif MODE==6
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getJFM_RBF(order,rho,p,q);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% RHFM    
elseif MODE==7
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getRHFM_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% EFM   
elseif MODE==8
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getEFM_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% PCET    
elseif MODE==9
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getPCET_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% PCT    
elseif MODE==10
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getPCT_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% PST    
elseif MODE==11
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getPST_RBF(order,rho);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% BFM    
elseif MODE==12
    v=1;
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getBFM_RBF(order,rho,v);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% FJFM
elseif MODE==13
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getFJFM_RBF(order,rho,p,q,alpha);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% GRHFM    
elseif MODE==14
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getGRHFM_RBF(order,rho,alpha);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% GPCET    
elseif MODE==15
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getGPCET_RBF(order,rho,alpha);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% GPCT    
elseif MODE==16
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getGPCT_RBF(order,rho,alpha);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
%% GPST    
elseif MODE==17
    for index =1:1:L
        order = NM(index,1); repetition = NM(index,2);
        R=getGPST_RBF(order,rho,alpha);
        pupil =R.*exp(-1j*repetition * theta);
        pupil(pz) = 0;
        BF(:,:,index)=(1/cnt).*pupil;
    end
end

