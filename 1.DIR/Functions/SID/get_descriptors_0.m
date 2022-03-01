function [polar,invar,grd] = get_descriptors(inim,settings,X,Y);
% [polar,invar,grd] = get_descriptors(inim,settings,X,Y);
%
% Inputs
% inim          : input image
% settings      : settings struct for descriptor construction - see demo scripts
% X,Y (optional): locations where descriptors are extracted
%
% Outputs
% polar         : normalized orientation- and scale- covariant descriptor
% invar         : invariant descriptor
% grd           : grid used for descriptor construction

if size(inim,3)>1,
    inim = rgb2gray(inim);
end
inim = single(inim);

%% convolution results used for daisy -like descriptors
[dzy,grd,settings]  = init_dzy(inim,settings);

if nargin==4,
    [szv,szh] = size(inim);
    X         = single(clip(round(X),1,szh)-1);
    Y         = single(clip(round(Y),1,szv)-1);
    desc      = mex_compute_all_descriptors(dzy.H, dzy.params, dzy.ogrid(:,:,1), dzy.ostable, single(0),single(X'),single(Y'))';
else
    desc      = mex_compute_all_descriptors(dzy.H, dzy.params, dzy.ogrid(:,:,1), dzy.ostable, single(0) )';
end

nf       = dzy.HQ;          % number of orientations x polarities
nr       = settings.nrays;  % number of rays
ns       = length(dzy.cind);% number of scales (radii)

% matlab-lisp: make polar and normalize descriptor
polar =  normalize_polard(make_polard(reshape(desc',[nf,nr,ns,size(desc,1)])));
%polar(:,:,1:(settings.st-1),:) = [];

if nargout==1,
    %% dense descriptors: reshape to be in original image size
    if nargin==2,
        polar = reshape(polar,[nf,nr,ns,sz(1),sz(2)]);
    end
    return;
end
invar           = get_desc(polar,settings.cmp);

%% dense descriptors: reshape to be in original image size
if nargin==2
    szd             = size(invar);
    szp             = size(polar);
    sz              = size(inim);
    invar           = reshape(invar,[szd(1:end-1),sz(1),sz(2)]);
    polar           = reshape(polar,[szp(1:end-1),sz(1),sz(2)]);
end

function descriptors =  make_polard(descriptor)
%% `rotate' directional derivatives so that orientations become relative
%% to ray's angle (Fig. 3 in paper)
descriptors = descriptor;

[nf,nrays,nsc,np]   = size(descriptor);
fracshifts          = nf*[0:nrays-1]/nrays;
angs                = [0:nf-1];
for r = 1:nrays,
    dsc_ray          = squeeze(descriptor(:,r,:,:));
    dsc_ray          = reshape(dsc_ray,[nf,np*nsc]);
    transform_matrix = rotate_weights(nf,fracshifts(r));
    rotated_desc     = transform_matrix*dsc_ray;
    rotated_desc     = reshape(rotated_desc,[nf,nsc,np]);
    descriptors(:,r,:,:) = rotated_desc;
end

function [matr] = rotate_weights(n,a)
%% Rotate gradients by non-integer amount, using
%% the non-integer delay system in Oppenheim & Schafer's book

ns = [-300:300];
nsi = mod(ns,n)+1;
numerators   = sin(pi*(ns-a));
denominators = pi*(ns-a);
isnz = abs(denominators)>1e-5;
weights = ones(1,length(ns));
weights(isnz) = numerators(isnz)./denominators(isnz);
for k =1:(n),
    weight(k) = sum(weights.*(nsi==k));
end
idxs = [1:n];
for k=1:n,
    matr(k,:) = weight(mod(idxs - k, n)+1);
end
matr = single(matr);


function t = get_desc(feats,cmp)
%% FT of descriptors 

%% normalization, so that points around the boundaries get a bit boosted
%% (otherwise their FT will be lower, due to the smaller number of non-zero
%% observations)

mxabs   = (squeeze(any(abs(feats),1)));
sup     = single(mxabs~=0);
nr      = max(sum(double(mxabs~=0),2),1);
nt      = size(mxabs,2);
%% boosting part 
nr      = nr + .5*(nt -nr);
nr      = repmat(1./nr,[1,size(mxabs,2),1]);

for it =size(feats,1):-1:1
    dc0 = squeeze(feats(it,:,:,:));
    dc = abs(fft(fft(dc0,[],2).*nr,[],1));
    dc = dc(2:[end/2],:,:);
    if cmp>0
        dc(end-6:end,:,:) = [];
        dc(:,ceil(end/2)+[-6:7],:) = [];
    end
    t(it,:,:,:) = dc;
end


function [feats_match] = normalize_polard(feats_match);
%% normalize polar descriptors separately per ray
[nf,nrays,ns,np] = size(feats_match);
rps  = zeros(size(feats_match));

for sc = 1:ns,
    absf   = abs(feats_match(:,:,sc,:));
    nrm_sc = sqrt(sum(pow_2(sum(absf,1)),2));
    cnt_sc = max(sum(any(absf,1),2)/nrays,1/nrays);
    nrm_sc = max(nrm_sc./cnt_sc,.2);
    feats_match(:,:,sc,:) = feats_match(:,:,sc,:)./repmat(nrm_sc,[nf,nrays,1,1]);
end

function r = un(i)
r = i - 10*floor(i/10);

function r  = pow_2(x)
r = x.*x;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Daisy code, original by Tola, adaptation by Iasonas 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [dzy,grd,settings] = init_dzy(imin, settings)
%%
SI = 1;
LI = 1;
NT = 1;

sc_min = settings.sc_min;
sc_max = settings.sc_max;
sc_sig = settings.sc_sig;
nsteps = settings.nsteps;
nrays  = settings.nrays;

[grid,sgs]  = log_polar_grid(sc_min,sc_max,nsteps,nrays);
ogrid       = compute_oriented_grid(grid,360);
csigma      = sgs*sc_sig;
cind        = 1:length(sgs);
cn          = length(cind);

im  = single(imin);
h   = size(im,1);
w   = size(im,2);

nors    = settings.nors;     %% how many orientations are estimated
nors_ft = 2*nors;            %% >> are stored (x2 for polarity)
ors = pi*[0:nors-1]/nors;
ors = [ors,ors+pi];

dim = double(im);

settings.nors_ft    = nors_ft;
dzy.H               = zeros(h*w,nors_ft,cn,'single');

for r=1:cn
    cu                = max(csigma(r),.5);
    %[t,dx,dy]         = iir_gauss_single(im,cu);
    for k = 1:nors,
        resp              = sqrt(cu)*anigauss(dim,cu,cu, ((k-1)/nors_ft)*360-90 , 0, 1);
        
        cosk              = cos(2*pi*(k-1)/nors_ft);
        sink              = sin(2*pi*(k-1)/nors_ft);
        %respm             = sqrt(cu)*(dx*cosk + dy*sink);
        
        sm                = max(resp,0);
        dzy.H(:,k,r)      = reshape(sm',h*w,1);
        sm                = max(-resp,0);
        dzy.H(:,k+nors,r) = reshape(sm',h*w,1);
    end
end

%% compute histograms
HQ = size(dzy.H,2);
TQ = nrays;

dzy.h       = h; 
dzy.w       = w; 
dzy.TQ      = TQ;
dzy.HQ      = HQ;
dzy.HN      = size(grid,1);
dzy.DS      = dzy.HN*HQ;
dzy.grid    = grid;
dzy.ogrid   = ogrid;
dzy.cind    = cind;
dzy.csigma  = csigma;
dzy.ostable = compute_orientation_shift(HQ,1);
%fprintf(1,'-------------------------------------------------------\n');
dzy.SI = SI;
dzy.LI = LI;
dzy.NT = NT;
dzy.params = single([dzy.DS dzy.HN dzy.h dzy.w 0 0 TQ HQ SI LI NT length(dzy.ostable)]);
dzy.params(11) = 0;
grd = get_grid(dzy);

%% skip the first element 
dzy.ogrid           = dzy.ogrid(2:end,:,:);
dzy.grid            = dzy.grid(2:end,:,:);
dzy.HN              = dzy.HN - 1;
dzy.params(2)       = dzy.params(2) - 1;
dzy.params(1)       = dzy.params(1) - 1*dzy.params(end-4);



%% Auxiliary functions 
% rotate the grid

function ogrid = compute_oriented_grid(grid,GOR)

GN = size(grid,1);
ogrid( GN, 3, GOR )=single(0);
for i=0
%for i = 0,
    th = -i*2.0*pi/GOR;
    kos = cos( th );
    zin = sin( th );
    for k=1:GN
        y = grid(k,2);
        x = grid(k,3);
        ogrid(k,1,i+1) = grid(k,1);
        ogrid(k,2,i+1) = -x*zin+y*kos;
        ogrid(k,3,i+1) = x*kos+y*zin;
    end
end

% computes the required shift for each orientation
function ostable=compute_orientation_shift(hq,res)
if nargin==1
    res=1;
end
ostable = single(0:res:359)*hq/360;


function [grid,Rs]= log_polar_grid(Rmn,Rmx,nr,TQ)

Rs = logspace(log(Rmn)/log(10),log(Rmx)/log(10),nr);
ts = 2*pi/TQ;
RQ = length(Rs);
gs = RQ*TQ+1;

grid(gs,3)   = single(0);
grid(1,1:3)  = [1 0 0];
cnt=1;
for r=0:RQ-1
    for t=0:TQ-1
        cnt=cnt+1;
        rv = Rs(r+1);
        tv = t*ts;
        grid(cnt,1)=r+1;
        grid(cnt,2)=rv*sin(tv); % y
        grid(cnt,3)=rv*cos(tv); % x
    end
end

function grd = get_grid(dzy)
grd0        = squeeze(dzy.ogrid(:,:,1));
grd0 = grd0(2:end,:);
for d = [1:3],
    grd(:,:,d) = permute(reshape(grd0(:,d),[dzy.TQ,length(dzy.cind)]),[2,1]);
end
