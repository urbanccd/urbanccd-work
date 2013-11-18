function [epdf,ecdf,bins]=epdfcdf(x,N);
%
% function to calculate the empirical probability density function (PDF)
% and cumulative density function
%
%



[h,bins]=hist(x,N);

dX=bins(2)-bins(1);  % find the width of the bins
epdf=h/length(x)/dX; % normalize histogram by bin width and number of samples
ecdf=cumsum(epdf).*dX; % integrate the PDF(dX to get the CDF
