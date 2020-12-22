Fs = 44100;

note_1 = [zeros(1, Fs * 1), flute(Fs, 261.63, 3, 0.05, 0.3, 0.00001, 0.025)];
note_2 = [zeros(1, Fs * 2), flute(Fs, 311.13, 2, 0.1, 0.3, 0.00001, 0.04)];
note_3 = [zeros(1, Fs * 3), flute(Fs, 392.00, 1, 0.15, 0.3, 0.00001, 0.06)];
note_4 = flute(Fs, 233.08, 4, 0.2, 0.3, 0.00001, 0.1);

reverbVals = readmatrix("./presets/reverb/YorkMinster.csv");

combined = 0.2 * (note_1 + note_2 + note_3 + note_4);

% [drums, Fs] = audioread("drums.wav");

resonated = resonate(combined, 0.2, [30, 9], [8, 3], 2, 0.01, [27, 3], 4096);

% resonated = normalize(resonated, 'range', [-1, 1]);

% plot(resonated);

reverbed = reverberate(Fs, resonated, 0.8, 0.1);

sound(reverbed, Fs);
