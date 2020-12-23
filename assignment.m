Fs = 44100;

% note_1 = [zeros(1, Fs * 1), flute(Fs, 261.63, 3, 0.05, 0.3, 0.00001, 0.025)];
% note_2 = [zeros(1, Fs * 2), flute(Fs, 311.13, 2, 0.1, 0.3, 0.00001, 0.04)];
% note_3 = [zeros(1, Fs * 3), flute(Fs, 392.00, 1, 0.15, 0.3, 0.00001, 0.06)];

% f0, dur, breath, pressure, attack, vibDepth, Fs
note4 = flute(233.08, 2, 0.2, 0.3, 0.00025, 0.125, Fs);

% reverbVals = readmatrix("./presets/reverb/YorkMinster.csv");

% combined = 0.2 * (note_1 + note_2 + note_3 + note_4);

% [drums, Fs] = audioread("drums.wav");

resonated = resonate(note4, 1, [66, 12], [8, 6], 3, 0.01, [66, 6], 4096);

% resonated = normalize(resonated, 'range', [-1, 1]);

% plot(resonated);

figure(2);
plot(resonated);

[reverbed, ir] = reverberate(Fs, resonated, 0.95, 0.95, "./presets/reverb/YorkMinster.csv");

% reverbed = reverbed * 0.10;

figure(2);
plot(reverbed);

sound(reverbed, Fs);
