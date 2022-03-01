function J = localmaxima(I)
% This function computes the local maxima of the 2D input image I.
% Programmed by: Tianle Zhao, Aug. 2019.

c = I(2:end-1,2:end-1);
l = I(2:end-1,1:end-2);
r = I(2:end-1,3:end);
t = I(1:end-2,2:end-1);
b = I(3:end,2:end-1);
J = zeros(size(I));
J(2:end-1,2:end-1) = c>=l & c>r & c>=t & c>b;
J(J>0) = I(J>0);
