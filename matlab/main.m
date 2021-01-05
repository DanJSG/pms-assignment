% This is the script showing how to use the system. Set the presets for
% each part of the system by changing the filepaths being loaded. Then set
% the sampling rate, fundamental, duration and dry/wet mix. The sound will
% then be played. 
% 
% Below this is some analysis of the played sound, including time domain 
% and frequency domain plots.
% 
% The available preset filepaths are:
%   Flute Presets:
%       ./presets/flute/Breathy.json
%       ./presets/flute/Hard.json
%       ./presets/flute/Soft.json
%       ./presets/flute/Tremolo.json
%   Membrane Resonator Presets:
%       ./presets/resonator/Flute.json
%       ./presets/resonator/HalfFlute.json
%       ./presets/resonator/Plate.json
%       ./presets/resonator/Guitar1.json
%       ./presets/resonator/Guitar2.json
%   Reverb Presets:
%       ./presets/reverb/BigRoom.json
%       ./presets/reverb/LabRoom.json
%       ./presets/reverb/SmallRoom.json
%       ./presets/reverb/StudioFlat.json
%       ./presets/reverb/YorkMinster.json

% Set the preset for the flute model here by modifying the filepath.
flutePreset = jsondecode(fileread("./presets/flute/Breathy.json"));

% Set the preset for the membrane resonator here by modifying the filepath.
resPreset = jsondecode(fileread("./presets/resonator/Flute.json"));

% Set the preset for the reverb here by modifying the filepath.
revPreset = jsondecode(fileread("./presets/reverb/SmallRoom.json"));

% Sample rate
Fs = 48000;

% Fundamental frequency
f0 = 440;

% Duration of note in seconds
duration = 1;

% The dry/wet mix for the membrane resonator
resonatorMix = 1;

% The dry/wet mix for the reverberation
reverbMix = 1;

% Number of samples used for the membrane model
nMembraneSamples = 4096;

% Run the full system with the given preset parameter values
[waveform, resIr, revIr] = ...
    rrflute(f0, duration, flutePreset.breath, flutePreset.pressure, ...
    flutePreset.attack, flutePreset.vibDepth, resPreset.dimensions, ... 
    resPreset.excitationPoint, resPreset.excitationSize, 0.025, ...
    resPreset.outputPoint, nMembraneSamples, revPreset.feedback, ... 
    revPreset.earlyReflectionsPath, resonatorMix, reverbMix, Fs);

% Number of samples in FFT
nFft = 8192;

% Frequency Domain
fDomain = linspace(0, Fs / 2, nFft / 2);

% Window the audio before performing the FFT
windowLength = 8192;
window = hamming(windowLength)';
% The section of audio the analysis is done on may need modifying as
% sometimes the pre-delay on the reverb can mean the audio is not captured
analysisWindow = waveform(1:windowLength) .* window';

% Take the absolute value of an FFT of the waveform
freqResponse = abs(fft(analysisWindow, nFft));
freqResponse = freqResponse(1:nFft / 2);

% Plot the frequency response of the system's output
figure(1);
plot(fDomain, freqResponse);
xlim([0, 5000]);
xlabel("Frequency (Hz)");
ylabel("Amplitude");
title(["Frequency Spectrum of Modelled Flute Playing through", ...  
       "a Membrane Resonator in a Virtual Space"]);

% Plot the waveform of the system's output
figure(2);
tDomain = linspace(0, length(analysisAudio) / Fs, length(analysisAudio));
plot(tDomain, waveform);
xlim([0, 2])
xlabel("Time (s)");
ylabel("Amplitude");
title(["Waveform of Modelled Flute Playing through",  "a Membrane Resonator in a Virtual Space"]);

% Window the membrane resonators plucked response for frequency analysis
resWindowLength = 1024;
resWindow = hamming(resWindowLength);
resAnalysisWindow = resIr(1:resWindowLength) .* resWindow';
resFreqResponse = abs(fft(resAnalysisWindow, nFft));
resFreqResponse = resFreqResponse(1:nFft / 2);

% Plot the frequency response of the plucked response of the 2D membrane
figure(3);
plot(fDomain, resFreqResponse);
xlim([0, 5000]);
xlabel("Frequency (Hz)");
ylabel("Amplitude");
title("Frequency Spectrum of the Plucked Response of a 2D Membrane");

% Plot the waveform of the plucked response of the 2D membrane
figure(4);
tDomain = linspace(0, length(resIr) / nMembraneSamples, length(resIr));
plot(tDomain, resIr);
xlabel("Time (s)");
ylabel("Amplitude");
title("Waveform of a Plucked Response of the 2D Membrane");

% Plot the impulse response of the reverb
figure(5);
tDomain = linspace(0, length(revIr) / Fs, length(revIr));
plot(tDomain, revIr);
xlabel("Time (s)");
ylabel("Amplitude");

