function [N] = mpsSampleSizeCorr(r, a, b)
% Usage: [N] = mpsSampleSizeCorr(r, a, b)
% r = corr coef, a = prob. type I error (2 tailed), b = prob. type II error
%
% Taken from http://www.sample-size.net/correlation-sample-size/ 
% The standard normal deviate for ? = Z? = 1.960
% The standard normal deviate for ? = Z? = 0.842
% C = 0.5 * ln[(1+r)/(1-r)] = 0.576
% Total sample size = N = [(Z?+Z?)/C]2 + 3 = 27
% Reference: Hulley SB, Cummings SR, Browner WS, Grady D, Newman TB. Designing clinical research : an epidemiologic approach. 4th ed. Philadelphia, PA: Lippincott Williams & Wilkins; 2013. Appendix 6C, page 79.

if ~exist('a','var')
    a = 0.05;
    warning('Assuming alpha = 0.05');
end
if ~exist('b','var')
    b = 0.2;
    warning('Assuming beta = 0.2');
end

Za = abs(icdf('norm',a/2,0,1)); % a/2 because 2 tailed
Zb = abs(icdf('norm',b,0,1));
C = 0.5 * log([(1+r)/(1-r)]);

N = [(Za+Zb)/C]^2 + 3;
end