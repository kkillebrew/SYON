function [power H] =  mpsPowerAnalysis(effectSize,SD,N,displayOn)
% usage: [power H] =  mpsPowerAnalysis(effectSize,SD,N)
% this code should do a crude power analysis, SD = standard dev., N =
% sample size per group - mps 12/12/11

if ~exist('displayOn','var')
    displayOn = 0;
end

T1 = sqrt(N).*effectSize./SD;
for iT = 1:length(T1)
    if T1(iT) > 1.64
        H(iT) = 1;
    else H(iT) = 0;
    end
end
power = 1-normcdf(1.64,T1,1);

if displayOn
    figure
    plot([-2:.1:2],normpdf([-2:.1:2],0,1))
    hold on
    plot([-2:.1:2]+max(T1),normpdf([-2:.1:2]+max(T1),max(T1),1),'r')
    box off
end
end