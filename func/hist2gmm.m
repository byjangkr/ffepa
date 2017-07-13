function [hprob, hx, gmobj, gmx] = hist2gmm(data,hbin,nmix,gmxres)

% data : column data
% hbin : # of bin of histogram
% nmix : # of Gaussian mixture
% gmxres : resolution for time scale (x axis) of gmm

[h,xout] = hist(data,hbin);
interval = xout(2) - xout(1);
hprob = (h./sum(h)/interval);  
hx = xout;

gmobj = gmdistribution.fit(data,nmix);
gmx = min(data):gmxres:max(data);


end