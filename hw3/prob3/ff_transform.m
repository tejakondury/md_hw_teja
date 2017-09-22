vv=dlmread('vacf2.csv'); % Read the values

mag=abs(fft(vv));  % calculate the discrete fourier transform

f=(0:length(mag)-1)*(0.2e15)/length(mag);

plot(f(1:(length(f)/8)),mag(1:(length(mag)/8)))

title 'Vibrational density of states'
xlabel 'Hertz'
ylabel 'Magnitude'