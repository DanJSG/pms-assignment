resPreset = jsondecode(fileread("./presets/resonator/HalfFlute.json"));
revPreset = jsondecode(fileread("./presets/reverb/StudioFlat.json"));
flutePreset = jsondecode(fileread("./presets/flute/Breathy.json"));

Fs = 48000;

% fluteAnalysis = flute(440, 2, flutePreset.breath, flutePreset.pressure, flutePreset.attack, flutePreset.vibDepth, Fs);
% 
% fluteAnalysis = normalize(fluteAnalysis, 'range', [-1, 1]);

% figure(1);
% spectrogram(fluteAnalysis, hamming(4096), 2048, 8192, Fs, 'yaxis');

% windowLength = 4096;
% window = hamming(windowLength)';
% analysisWindow = fluteAnalysis(1:windowLength) .* window;
% 
% figure(1);
% plot(analysisWindow);
% 
% nFft = 8192;
% freqResponse = abs(fft(analysisWindow, nFft));
% fDomain = (0:nFft-1)*(Fs/nFft);
% freqResponse = freqResponse(1:nFft / 2);
% fDomain = linspace(0, Fs / 2, nFft / 2);
% figure(2);
% semilogx(fDomain, freqResponse);
% semilogx(fDomain, abs(fft(fluteAnalysis, nFft))/max(abs(fft(fluteAnalysis, nFft))));

% sound(fluteAnalysis, Fs);

waveform = ...
    rrflute(440, 1, flutePreset.breath, flutePreset.pressure, ...
    flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
    resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
    resPreset.outputPoint, 8192, revPreset.feedback, ... 
    revPreset.earlyReflectionsPath, 0, 0, Fs);

windowLength = 4096;
window = hamming(windowLength)';
analysisWindow = waveform(1:windowLength) .* window;

nFft = 8192;
freqResponse = abs(fft(analysisWindow, nFft));
freqResponse = freqResponse(1:nFft / 2);
fDomain = linspace(0, Fs / 2, nFft / 2);

figure(1);
plot(fDomain, freqResponse);
xlim([80, 4000]);
xlabel("Frequency (Hz)");
ylabel("Amplitude");
title("Frequency Spectrum of A4 on Modelled Flute");

tDomain = linspace(0, 1, length(waveform));

figure(2);
plot(tDomain, waveform);
xlabel("Time (s)");
ylabel("Amplitude");
title("Waveform of A4 on Modelled Flute");


% semilogx(fDomain, abs(fft(fluteAnalysis, nFft))/max(abs(fft(fluteAnalysis, nFft))));

sound(waveform, Fs);
% audiowrite("example.wav", waveform, Fs);
