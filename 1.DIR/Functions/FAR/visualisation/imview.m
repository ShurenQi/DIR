function imview(varargin)
% USAGE    : imview(I1,I2,I3,...) or imview(Icell) or imview(3D array)
% FUNCTION : Shows the sequence of images (RGB or grayscale) as a movie 
% (looping if direction=0, backward and forward if direction=1).
%
% Click the figure to animate, click again to stop.
% Select a square zone to show an enlargement of the animation
% Control-click to animate faster
% Control-shift-click to animate slower
% Alt-click to switch to the next image (when stopped)
% Shift-alt-click to switch to the previous image (when stopped)
%
% data structure of the "userdata" field:
%           * userdata{1}    = current frame number
%           * userdata{2}    = 0 (forward only) or 1 (forward and backward)
%           * userdata{3}{n} = nth frame image
%           * userdata{4}{1} = 0 (stopped) or 1 (moving)
%           * userdata{4}{2} = number of frames per second (?25)
%           * userdata{5}    = optional track information (x(t), y(t))
%                                   * userdata{5}{1} = x sample of the track
%                                   * userdata{5}{2} = y sample of the track
%                                   * userdata{5}{3} = time sample
%                                   * userdata{5}{4} = arrow extremities needed to draw the tracks
%                                           * userdata{5}{4}{1} = x values of the tail of the arrow
%                                           * userdata{5}{4}{2} = y values of the tail of the arrow
%                                           * userdata{5}{4}{3} = x values of the head of the arrow
%                                           * userdata{5}{4}{4} = y values of the head of the arrow
%                                   
%
%
% DATE     : 15 December 2014
% AUTHOR   : Thierry Blu, mailto:thierry.blu@m4x.org

direction=0;        % 0 = forward
                    % 1 = back and forth
speed=5;            % initial framerate in Hertz

if isempty(varargin)
    nextview
else
    N=length(varargin);
    if N==1
        if iscell(varargin{1})          
            varargin=varargin{1};       % imview(Icell)
            N=length(varargin);
        else
            I=varargin{1};              % imview(3D array)
            N=size(I,3);
            clear varargin
            for k=1:N
                varargin{k}=I(:,:,k);
            end
        end
    end
    clf
    [s1,s2,s3]=size(varargin{1});
    if s3==3
        varargin=cellfun(@uint8,varargin,'UniformOutput',false);
    end
    h=image(squeeze(varargin{1}));
    colormap(gray(256))
    axis image,axis off
    if N>1
        him=['run(''' which('imview') ''')'];
        set(h,'userdata',{1 direction varargin {0 speed}},'ButtonDownFcn',him)
    end
end

function nextview
zoombox=findobj(gca,'tag','zoombox');
h=findobj(gca,'type','image');
a=get(h,'userdata');
N=length(a{3});
if length(a{3}{N})==1
    K=round(a{3}{N});
    N=N-1;
end

sel=get(gcf,'selectiontype');
modif=get(gcf,'currentmodifier');

switch sel
    case 'alt'
        % increase speed
        a{4}{2}=min(a{4}{2}*2^(1/3),25);
        set(h,'userdata',a)
        if a{4}{1}
            return
        end
    case 'normal'
        if length(modif)>=1
            switch modif{1}
                case 'shift'
                    % decrease speed
                    a{4}{2}=a{4}{2}*2^(-1/3);
                    set(h,'userdata',a)
                    if a{4}{1}
                        return
                    end
                case 'alt'
                    % show next image (only when animation is stopped)
                    if ~a{4}{1}
                        a{1}=1+mod(a{1},N);
                        set(h,'cdata',a{3}{a{1}},'userdata',a)
                        return
                    end
            end
        end
    case 'extend'
        % show previous image (only when animation is stopped)
        if ~a{4}{1}
            a{1}=1+mod(a{1}-2,N);
            set(h,'cdata',a{3}{a{1}},'userdata',a)
            return
        end
end

        
if isempty(findobj(gca,'type','hggroup'))
    htraj=findobj(gca,'type','line');
    if ~isempty(zoombox)
        if length(htraj)>length(zoombox)
            htraj=findobj(gca,'type','line');
        else
            htraj=[];
        end
    end

    htraj=sort(htraj);
    Ntraj=length(htraj);
else
    Ntraj=0;
end

point1=round(get(gca,'CurrentPoint'));
point1=[point1(1,2) point1(1,1)];
point1=max(point1,1);
tic,rbbox;dt=toc;
point2=round(get(gca,'CurrentPoint'));
point2=[point2(1,2) point2(1,1)];
[s1,s2,s3]=size(a{3}{1});
point2=min(point2,[s1,s2]);

[point1,point2]=deal(min([point1;point2]),max([point1;point2]));

if dt<0.2
    a=get(h,'userdata');
    if a{4}{1}
        a{4}{1}=0;
        set(h,'userdata',a)
        encore=a{4}{1};
    else
        a{4}{1}=1;
        set(h,'userdata',a)
        encore=a{4}{1};
    end
    while encore
        try
            a=get(h,'userdata');
            speed=a{4}{2};
            if a{2}~=0
                a{2}=(1-2*(a{1}+a{2}==0|a{1}+a{2}==N+1))*a{2};
                a{1}=a{1}+a{2};
            else
                a{1}=1+mod(a{1},N);
            end
            set(h,'cdata',a{3}{a{1}},'userdata',a)
            % Trajectories
            if Ntraj~=0
                n0=1:floor(a{5}{3}(a{1}));
            end
            for k=1:Ntraj
                xtraj=a{5}{1}(:,k)';
                ytraj=a{5}{2}(:,k)';
                set(htraj(k),'xdata',[a{5}{4}{a{1}}{1}(:,k)',xtraj(n0),a{5}{4}{a{1}}{3}(:,k)'],'ydata',[a{5}{4}{a{1}}{2}(:,k)',ytraj(n0),a{5}{4}{a{1}}{4}(:,k)'])
            end
            
            encore=a{4}{1};
            pause(1/speed)
        catch
            encore=0;
        end
    end
else
        
    set(h,'userdata',a)
    if point1==point2
        if ~exist('K','var')
            K=2;
        end
        point1=max(point1-K,1);
        [s1,s2,s3]=size(a{3}{1});
        point2=min(point2+K,[s1,s2]);
    end
    
    zoomcolor=0.999*[1 1 1];
    hold on
    zoombox=plot([point1(2) point1(2) point2(2) point2(2) point1(2)],[point1(1) point2(1) point2(1) point1(1) point1(1)],'color',zoomcolor);
    set(zoombox,'tag','zoombox')
    hold off

    for k=1:N
        a{3}{k}=a{3}{k}(point1(1):point2(1),point1(2):point2(2),:);
    end
    figure
    set(gcf,'UserData',[zoombox],'DeleteFcn','try,delete(get(gcf,''Userdata'')),end')
    h=image(point1(2):point2(2),point1(1):point2(1),a{3}{1});
    colormap(gray(256))
    axis image,axis off

    h0=zeros(Ntraj,1);
    for k=1:Ntraj
        h0(k)=copyobj(htraj(k),gca);
    end
    
    if N>=2
        set(h,'userdata',a,'ButtonDownFcn','imview')
    end

    if a{4}{1}
        a{4}{1}=0;
        set(h,'userdata',a)
        encore=a{4}{1};
    else
        a{4}{1}=1;
        set(h,'userdata',a)
        encore=a{4}{1};
    end
    while encore
        try
            a=get(h,'userdata');
            speed=a{4}{2};
            if a{2}~=0
                a{2}=(1-2*(a{1}+a{2}==0|a{1}+a{2}==N+1))*a{2};
                a{1}=a{1}+a{2};
            else
                a{1}=1+mod(a{1},N);
            end
            set(h,'cdata',a{3}{a{1}},'userdata',a)
            
            % Trajectories
            if Ntraj~=0
                n0=1:floor(a{5}{3}(a{1}));
            end
            for k=1:Ntraj
                xtraj=a{5}{1}(:,k)';
                ytraj=a{5}{2}(:,k)';
                set(h0(k),'xdata',[a{5}{4}{a{1}}{1}(:,k)',xtraj(n0),a{5}{4}{a{1}}{3}(:,k)'],'ydata',[a{5}{4}{a{1}}{2}(:,k)',ytraj(n0),a{5}{4}{a{1}}{4}(:,k)'])
            end
            
            encore=a{4}{1};
            pause(1/speed)
        catch
            encore=0;
        end
    end
end

function showpar
h=findobj(gca,'type','image');
userdata=get(h,'userdata');

pareval=eval(s);
title(['Parameter ' regexprep(regexprep(s,'{','\\{'),'}','\\}') ' = ' num2str(pareval)])