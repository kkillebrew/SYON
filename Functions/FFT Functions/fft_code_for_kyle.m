time_duration = 2600; % ms
sampling_rate = 256 / 1000;
n_timepoints = round(time_duration * sampling_rate); % ms

n_cycles_per_timeseries = 7.2 * time_duration / 1000; % 7.2 Hz

signal = sin([1:n_timepoints]./n_timepoints*2*pi*n_cycles_per_timeseries);

noise = 2.*rand(1, n_timepoints);

timeseries = noise + signal;

fft_data = complex2real( fft( timeseries), 1:n_timepoints);

% plotFFT(1:n_timepoints, timeseries)

fft_data.freq = fft_data.freq .* n_timepoints / time_duration * 1000; % convert to Hz

figure;
subplot(2,1,1); hold on
plot(1:n_timepoints, timeseries)
set(gca,'XTick',[0:500:time_duration].*sampling_rate,'XTickLabel',...
    0:500:time_duration)
xlabel('time (ms)')
ylabel('signal')

subplot(2,1,2); hold on
plot(fft_data.freq, fft_data.amp)
set(gca,'XScale','log','XTick',unique(round(logspace(0,log10(128),16))))
ax = axis;
axis([1 128 ax(3) ax(4)])
xlabel('frequency (Hz)')
ylabel('amplitude')

set(gcf,'color','w')