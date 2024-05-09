clear all; close all

triangle = [.1 0.1+0.5/3 0.1+(2*0.5/3) .6 .6 .1+(2*0.5/3) .1+0.5/3];
n_blank = 20;
frame_rate = 120;
stim_duration = 120*frame_rate;

for iBlank = 1:n_blank+1
    use_blank = iBlank-1;
    time_series{iBlank} = [triangle repmat(0.1,[1 use_blank])];
    n_peaks(iBlank) = 1;
    while length(time_series{iBlank}) < stim_duration
            time_series{iBlank} = [time_series{iBlank} triangle repmat(0.1,[1 use_blank])];
            n_peaks(iBlank) = n_peaks(iBlank) + 1;
    end
    time_series{iBlank} = time_series{iBlank}(1:stim_duration);
    
    c2r{iBlank} = complex2real(fft(time_series{iBlank}));
    figure()
    plot(c2r{iBlank}.freq*frame_rate,c2r{iBlank}.amp)
    
    time_series_peaks{iBlank} = findpeaks(c2r{iBlank}.amp);
    time_series_peaks_max(iBlank) = max(time_series_peaks{iBlank});
    time_series_peaks_max_idx(iBlank) = c2r{iBlank}.freq(c2r{iBlank}.amp == time_series_peaks_max(iBlank))*frame_rate;
end
