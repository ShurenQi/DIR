function h = drawcircles(centres, radii, directions)
% Draws circles specified by their centres and radii
% Programmed by: Tianle Zhao, Aug. 2019.

N = length(radii);
if ~exist('directions','var') || isempty(directions)
    directions = zeros(N,1);
end
if numel(directions)==1
    directions = directions*ones(N,1);
end
if size(centres,2) ~= 2
    centres = centres';
end
hh = cell(N, 1);
t = linspace(0, 2*pi, 50);
for n = 1:N
    x = [centres(n,1)+radii(n)*cos(t+directions(n)),centres(n,1)];
    y = [centres(n,2)+radii(n)*sin(t+directions(n)),centres(n,2)];
    hh{n} = plot(y, x, '-r', 'linewidth', 2); hold on;
end
hold off;
if nargout > 0
    h = hh;
end