function [ output ] = filterdata( f, Nyquist, data )
%FILTER DATA
%   Butterworth bandpass filter the data

Wn = (f)/(Nyquist); %Wn is a proportion of Nyquist

[b,a] = butter(9,Wn,'bandpass');
%freqz(b, a)        % Bode plot of filter

output = filter(b,a,data);

end

