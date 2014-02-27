function [ frequency, amplitude ] = fftdata( timeseries, dataseries )

delta_t = mean(diff(timeseries));

delta_f = 1/(timeseries(end) - timeseries(1));              % frequency interval of fourier transform = reciprocal of length of time series
max_f   = 1/delta_t;            % maximum frequency - reciprocal of time-step (sampling frequency)
frequency = [0:delta_f:max_f]';    % frequency vector for plotting

datafft = fft(dataseries);

% Magnitude of Fourier transform
amplitude = 2*abs(datafft)/numel(datafft); 
% Scaled to give amplitudes of frequency components


end

