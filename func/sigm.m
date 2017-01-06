function y = sigm(x,range)

if nargin < 2
    range = [0 1.5]; % range for actvation function
end
% set

margin = 0.1; % 2%

b = mean(range);
marginX = min(range)-b;
a = -(logm(1/margin-1)/marginX);



x = exp(-a*(x-b));
y = 1./(1+x);

end