function [freq,mag] = fftfull(acc)
    L=length(acc);
    Fs=2560;
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    mag = fft(acc,NFFT)/L;
    freq = Fs/2*linspace(0,1,NFFT/2+1);
    mag=2*abs(mag(1:NFFT/2+1));
end