%clear all
%clc

close all;

M = load('TestRig.csv');
% x y z x y z time

timeseries = M(:,7)/1000;

dataseriesx = M(:,2);

delta_t = mean(diff(timeseries));

delta_f = 1/(timeseries(end) - timeseries(1));              % frequency interval of fourier transform = reciprocal of length of time series
max_f   = 1/delta_t;            % maximum frequency - reciprocal of time-step (sampling frequency)
f_line = [0:delta_f:max_f]';    % frequency vector for plotting

Fn = [0.15 3]; % Hz
Wn = (Fn)/(max_f/2); %Wn is a proportion of Nyquist

[b,a] = butter(9,Wn,'bandpass');
%freqz(b, a)        % Bode plot of filter

filterx = filter(b,a,dataseriesx);


% Fourier transform of waveform (complex number)
Xft = fft(dataseriesx);% - mean(dataseriesx));
XFft = fft(filterx);% - mean(filterx));

% Magnitude of Fourier transform
% Xftmag = abs(Xft);            % Fourier-space
Xftmag = 2*abs(Xft)/numel(Xft); % Scaled to give amplitudes of frequency components
XFftmag = 2*abs(XFft)/numel(XFft);


%set(gca,'FontName','Verdana','FontSize',12);
figure(2);

% Time
sine = (sin(2*pi*0.3837*timeseries+2.5)-1)*0.25*1e4;

subplot(2, 1, 1);

hold on;
plot(timeseries,dataseriesx,'k',timeseries,filterx,'r')

%plot(timeseries,sine,'g')
hold off;

xlabel('Seconds');
title('Time Domain')
grid


% FFT
subplot(2, 1, 2);

plot(f_line,Xftmag,'k',f_line,XFftmag,'r')
set(gca,'xlim',[0 max_f/2]);

xlabel('Frequency (Hz)');
title('Fourier Transform')
grid




