resPreset = jsondecode(fileread("./presets/resonator/Flute.json"));
revPreset = jsondecode(fileread("./presets/reverb/BigRoom.json"));
flutePreset = jsondecode(fileread("./presets/flute/Breathy.json"));

Fs = 48000;
f0 = 440;
duration = 1;

resonatorMix = 1;
reverbMix = 1;

nMembraneSamples = 4096;

[waveform, resIr, revIr] = ...
    rrflute(f0, duration, flutePreset.breath, flutePreset.pressure, ...
    flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
    resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
    resPreset.outputPoint, nMembraneSamples, revPreset.feedback, ... 
    revPreset.earlyReflectionsPath, resonatorMix, reverbMix, Fs);

analysisAudio = waveform;
nFft = 8192;
fDomain = linspace(0, Fs / 2, nFft / 2);

% analysisAudio = analysisAudio / max(abs(analysisAudio));

windowLength = 8192;
window = hamming(windowLength)';
analysisWindow = analysisAudio(nFft * 2:nFft * 2 + windowLength - 1) .* window';

freqResponse = abs(fft(analysisWindow, nFft));
freqResponse = freqResponse(1:nFft / 2);

figure(1);
plot(fDomain, freqResponse);
xlim([0, 5000]);
xlabel("Frequency (Hz)");
ylabel("Amplitude");
% title(["Frequency Spectrum of Modelled Flute Playing A4 through",  "a 66x12cm Resonator in a Virtual Space of Dimensions 30x12m"]);

tDomain = linspace(0, length(analysisAudio) / Fs, length(analysisAudio));
figure(2);
plot(tDomain, analysisAudio);
xlim([0, 2])
xlabel("Time (s)");
ylabel("Amplitude");
% title(["Waveform of Modelled Flute Playing A4 through",  "a 66x12cm Resonator in a Virtual Space of Dimensions 30x20m"]);

disp(windowLength - 1);
disp(length(window));
resWindowLength = 1024;
resWindow = hamming(resWindowLength);
resAnalysisWindow = resIr(1:resWindowLength) .* resWindow';
resFreqResponse = abs(fft(resAnalysisWindow, nFft));
resFreqResponse = resFreqResponse(1:nFft / 2);

figure(3);
plot(fDomain, resFreqResponse);
xlim([0, 5000]);
xlabel("Frequency (Hz)");
ylabel("Amplitude");

sound(waveform, Fs);
audiowrite("audio.wav", waveform, Fs);

