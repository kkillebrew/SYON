data_ave = [5 4; 6 6; 8 5.5];
data_ste = [1 1.5; .5 .5; 1 .8];

figure()
myBar = bar(data_ave);
hold on
% find the width for each bar group
nGroups = size(data_ste,1);
nBars = size(data_ste,2);
groupWidth = min(.8,nBars/(nBars+1.5));
for i = 1:nBars
    x = (1:nGroups) - groupWidth/2 + (2*i-1) * (groupWidth) / (2*nBars);
    errorbar(x, data_ave(:,i), data_ste(:,i),'.k')
end
hold off
