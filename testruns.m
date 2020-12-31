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

% waveform1 = ...
%     rrflute(220, 1, flutePreset.breath, flutePreset.pressure, ...
%     flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
%     resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
%     resPreset.outputPoint, 4096, revPreset.feedback, ... 
%     revPreset.earlyReflectionsPath, 1, 1, Fs);
waveform2 = ...
    rrflute(440, 1, flutePreset.breath, flutePreset.pressure, ...
    flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
    resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
    resPreset.outputPoint, 8192, revPreset.feedback, ... 
    revPreset.earlyReflectionsPath, 1, 0.7, Fs);
% waveform3 = ...
%     rrflute(880, 1, flutePreset.breath, flutePreset.pressure, ...
%     flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
%     resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
%     resPreset.outputPoint, 4096, revPreset.feedback, ... 
%     revPreset.earlyReflectionsPath, 1, 1, Fs);

sound( waveform2, Fs);

audiowrite("example.wav", waveform2, Fs);
