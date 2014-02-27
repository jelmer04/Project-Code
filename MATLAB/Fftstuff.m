%clear all
%clc



M = load('TestRig.csv');
% x y z x y z time

timeseries = M(:,7)/1000;

dataseriesx = M(:,4);
dataseriesy = M(:,5);
dataseriesz = M(:,6);



delta_t = mean(diff(timeseries));

delta_f = 1/(timeseries(end) - timeseries(1));              % frequency interval of fourier transform = reciprocal of length of time series
max_f   = 1/delta_t;            % maximum frequency - reciprocal of time-step (sampling frequency)
f_line = [0:delta_f:max_f]';    % frequency vector for plotting


% Fourier transform of waveform (complex number)
Xft = fft(dataseriesx - mean(dataseriesx));
Yft = fft(dataseriesy - mean(dataseriesy));
Zft = fft(dataseriesz - mean(dataseriesz));

% Magnitude of Fourier transform
% Xftmag = abs(Xft);            % Fourier-space
Xftmag = 2*abs(Xft)/numel(Xft); % Scaled to give amplitudes of frequency components
Yftmag = 2*abs(Yft)/numel(Yft);
Zftmag = 2*abs(Zft)/numel(Zft);


%clf %figure
plot(f_line,Xftmag,'r',f_line,Yftmag,'g',f_line,Zftmag,'b')
set(gca,'xlim',[0 max_f/2]);
%set(gca,'ylim',[0 12]);
set(gca,'FontName','Verdana','FontSize',12);
xlabel('Frequency (Hz)');
title('Fourier Transform')
grid




