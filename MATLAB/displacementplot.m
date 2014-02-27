
close all;

M = load('TestRig.csv');
% A(x y z) G(x y z) time

timeseries = M(:,7)/1000;

dataseries = [ M(:,1) M(:,2) M(:,3)];

Nyquist = (timeseries(end) - timeseries(1))/2;

Fn = [0.2 3]; % Hz

filtered = filterdata(Fn,Nyquist,dataseries);

velocity = cumtrapz(timeseries,filtered);

displacement = cumtrapz(timeseries,velocity);

figure(1);

subplot(221);

plot(timeseries,dataseries)


xlabel('Seconds');
title('Time Domain')
grid

% FFT
subplot(222);

[ f, Mag ] = fftdata(timeseries, dataseries);

plot(f, Mag)
set(gca,'xlim',[0 Nyquist/2]);

xlabel('Frequency (Hz)');
title('Fourier Transform')
grid


subplot(223);

plot(timeseries,filtered)


xlabel('Seconds');
title('Time Domain (Filtered)')
grid


% FFT
subplot(224);

[ f, Mag ] = fftdata(timeseries, filtered);

plot(f, Mag)
set(gca,'xlim',[0 Nyquist/2]);

xlabel('Frequency (Hz)');
title('Fourier Transform (Filtered)')
grid


figure(2);

c = 1:numel(timeseries);      %# colors
h = surface([filtered(:,1), filtered(:,1)], ...
    [filtered(:,2), filtered(:,2)], ...
    [filtered(:,3), filtered(:,3)], ...
    [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none', 'LineWidth', 2);
colormap( jet(numel(timeseries)) )


figure(3);

c = 1:numel(timeseries);      %# colors
h = surface([displacement(:,1), displacement(:,1)], ...
    [displacement(:,2), displacement(:,2)], ...
    [displacement(:,3), displacement(:,3)], ...
    [c(:), c(:)], 'EdgeColor','flat', 'FaceColor','none', 'LineWidth', 2);
colormap( jet(numel(timeseries)) )

