resPreset = jsondecode(fileread("./presets/resonator/Flute.json"));
revPreset = jsondecode(fileread("./presets/reverb/BigRoom.json"));
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

[waveform, resIr, revIr] = ...
    rrflute(440, 1, flutePreset.breath, flutePreset.pressure, ...
    flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
    resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
    resPreset.outputPoint, 8192, revPreset.feedback, ... 
    revPreset.earlyReflectionsPath, 0.5, 1, Fs);
% waveform2 = ...
%     rrflute(440, 1, flutePreset.breath, flutePreset.pressure, ...
%     flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
%     resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
%     resPreset.outputPoint, 8192, revPreset.feedback, ... 
%     revPreset.earlyReflectionsPath, 0, 0, Fs);

analysisAudio = revIr;

analysisAudio = analysisAudio / max(abs(analysisAudio)); % Normalize to Unity Gain (0 dB)
Ts = 1 / Fs;
t = [0:length(analysisAudio)-1] * Ts;
figure(2);
plot(t, 20 * log10(abs(analysisAudio))); 
line([0 4], [-60 -60], 'Color', 'red', 'LineStyle','--');
axis([0 4 -80 0]);
title("RT60 Estimate from Normalized Impulse Response");
xlabel("Time (s)");
ylabel("Amplitude (dB)");

figure(1);
plot(t, abs(analysisAudio));

figure(3);
testBit = 20 * log10(abs(analysisAudio));
testBit(testBit < -60) = 0;
plot(t, testBit);
line([0 4], [-60 -60], 'Color', 'red', 'LineStyle','--');

location = find(testBit, 1, 'last');
rt60 = location / Fs;

% plot(

% lengthSeconds = length(analysisAudio) / Fs;

% tDomain = linspace(0, length(analysisAudio) / Fs, length(analysisAudio));
% figure(1);
% plot(tDomain, abs(analysisAudio));
% xlim([0, 0.4]);
% ylim([0, 1.1]);
% xlabel("Time (s)");
% ylabel("Amplitude (abs)");
% % title("Impulse Response of Simulated 30x20m Room");
% % title("Absolute Values of Early Reflections in Simulated 30x20m Room");
% 
% sound(waveform, Fs);
% audiowrite('example.wav', analysisAudio, Fs);

% windowLength = 4096;
% window = hamming(windowLength)';
% analysisWindow = analysisAudio(1:windowLength) .* window;

% analysisWindow = analysisAudio;
% 
% nFft = 8192;
% fDomain = linspace(0, Fs / 2, nFft / 2);
% 
% freqResponse = abs(fft(analysisWindow, nFft));
% freqResponse = freqResponse(1:nFft / 2);
% 
% freqResponse2 = abs(fft(waveform2, nFft));
% freqResponse2 = freqResponse2(1:nFft / 2);
% 
% freqResponse3 = abs(fft(waveform, nFft));
% freqResponse3 = freqResponse3(1:nFft / 2);
% 
% figure(1);
% plot(fDomain, freqResponse, 'Color', 'blue');
% xlim([0, 1500]);
% xlabel("Frequency (Hz)");
% ylabel("Amplitude");
% title("Frequency Spectrum of a Plucked 66x12cm Absorbing Membrane");
% hold on;
% plot(fDomain, freqResponse2, 'Color', 'black');
% plot(fDomain, freqResponse3, 'Color', 'red');
% 
% yline(3155.75, 'k--');
% yline(3212.83, 'r--');
% 
% legend(["Membrane Frequency Response", "Non-Convolved Flute", "Convolved Flute", "Non-Convolved Peak", "Convolved Peak"]);
% % plotbrowser('on');
% hold off;
% 
% 
% tDomain = linspace(0, 1, length(analysisAudio));
% 
% figure(2);
% plot(tDomain, 0.125 * analysisAudio);
% xlabel("Time (s)");
% ylabel("Amplitude");
% title("Plucked Response of a 66x12cm Absorbing Membrane");



% analysisAudio = normalize(analysisAudio);
% analysisAudio = normalize(analysisAudio, 'range', [-1, 1]);

% sound(waveform, Fs);

% semilogx(fDomain, abs(fft(fluteAnalysis, nFft))/max(abs(fft(fluteAnalysis, nFft))));

% sound(waveform, Fs);
% audiowrite("example.wav", 0.125 * analysisAudio, Fs);
