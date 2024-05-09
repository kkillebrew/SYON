function [stats, data] = mpsContingencyTable(n_cat, samples, yates)
% usage: [stats, data] = mpsContingencyTable(n_cat, samples, yates)
%
% runs a chi-square test for differences in categorical data between groups
% n_cat = # of categories (e.g., male & female = 2 categories; patients, relatives, controls = 3 categories)
% samples = data in each group, [n groups (rows), m categories (columns)]
% yates = perform Yates' correction for small samples (0 = no, 1 = yes)
%
% author: mps c. 2015

if ~exist('n_cat','var')
    n_cat = input('# categories?: ');
end
if ~exist('yates','var')
    yates = questdlg('Use Yates'' correction if 2x2? (more conservative): ',...
        'Yates''?','Yes','No','Yes');
end

if ~exist('samples','var')
    get_samples = 1;
% elseif size(samples,2) ~= n_cat %|| size(samples,1) ~= 2
%     get_samples = 1;
else
    get_samples = 0;
end

if get_samples
    for i1 = 1:n_cat
        samples(1,i1) = input(['# samples in group 1, cat. ' num2str(i1) '?: ']);
        samples(2,i1) = input(['# samples in group 2, cat. ' num2str(i1) '?: ']);
    end
end

sum_g = sum(samples,2);

sum_c = sum(samples,1);
    
N = sum(samples(:));

for iG = 1:size(samples,1)
    for iC = 1:n_cat
        pred(iG,iC) = (sum_g(iG)/N * sum_c(iC)/N) * N;
    end
end

df = (size(samples,1) - 1)*(n_cat - 1);

if yates
    if n_cat == 2 % use yates' correction for small df (=1)
        sub_y = 0.5;
    else sub_y = 0;
        warning(['Ignoring instruction to use Yates'' correction, because df (' ...
            num2str(df) ') > 1']);
    end
else sub_y = 0;
    if n_cat == 2
        warning(['You should consider Yates'' correction, because df (' ...
            num2str(df) ') = 1; Current p-value may be inflated!']);
    end
end

Chi_sq = sum( sum( ( abs(samples - pred) - sub_y ).^2 ./ pred ,2) ,1);

p_val = 1-cdf('chi2',Chi_sq,df);

stats.p_value = p_val; stats.Chi_squared = Chi_sq; stats.df = df;
stats.Yates_correction = yates;

data.samples = samples; data.n_cat = n_cat;
data.sum_g = sum_g; data.sum_c = sum_c; data.pred = pred;

end