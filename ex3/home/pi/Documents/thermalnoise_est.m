function var = thermalnoise_est(data,fs)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% data need to be analyzed
s = data;

%% Computing Parameters

% length of time-domain signal
L=length(s);

% number of FFT points
nfft=2^nextpow2(L);

% frequency plotting vector
f=fs/2*[-1:2/nfft:1-2/nfft];

%% Analysis

% analyze spectrum
N=nfft/2+1:nfft;
S=fftshift(fft(s,nfft));
S=abs(S).^2/(L*fs);

% time-average for spectrum
Navg=4e2;
b(1:Navg)=1/Navg;
Sa=filtfilt(b,1,S);

perc = 0.8;

l = length(N);
start_index = l - floor(l*perc)+1;

var = fs*mean(Sa(N(start_index:l)));

end

