function d = mpsCohensD(x,sd,n)
% usage: d = mpsCohensD(x,sd,n),
% where x is 2 means, sd is 2 standard deviations
% and n is two sample sizes

if ~length(x) == 2
    if ~size(x,1) == 2
        error('x should be 2 means!');
    end
end
if ~length(sd) == 2
    if ~size(sd,1) == 2
        error('sd should be 2 standard deviations!');
    end
end
if ~length(n) == 2
    if ~size(n,1) == 2
        error('n should be 2 sample sizes!');
    end
end

s_all = sqrt( ( ( (n(1) -1) * sd(1).^2 ) + ( (n(2) -1) * sd(2).^2 ) ) / (n(1) + n(2) - 2) );

d = abs(( x(1) - x(2) ) / s_all);

end