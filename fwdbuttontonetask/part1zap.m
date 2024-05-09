%at the start of the scenario do this:
% wave1 = 0;
% wave1_fs = 44100;
% wave1_bps = 16;
% r = audiorecorder(wave1_fs, wave1_bps, 2);
% % wave1_fs = 48100;
% lastMean = 1000;
% ah = 0;
% jcount = 0;
nextTime = 0;
lastTime = 0;
%while the scenario is running
% record(r);