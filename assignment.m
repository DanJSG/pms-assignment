Fs = 44100;

resPreset = jsondecode(fileread("./presets/resonator/Flute.json"));
revPreset = jsondecode(fileread("./presets/reverb/SmallRoom.json"));
flutePreset = jsondecode(fileread("./presets/flute/Breathy.json"));
flute2Preset = jsondecode(fileread("./presets/flute/Soft.json"));

crotchetDuration = 0.725;
clipLength = floor(crotchetDuration * 6);

% f0, dur, breath, pressure, attack, vibDepth, Fs
note1 = flute(440, crotchetDuration, flutePreset.breath, flutePreset.pressure, flutePreset.attack, flutePreset.vibDepth, Fs);
note2 = flute(523, crotchetDuration, flutePreset.breath, flutePreset.pressure, flutePreset.attack, flutePreset.vibDepth, Fs);
note3 = flute(659, crotchetDuration, flutePreset.breath, flutePreset.pressure, flutePreset.attack, flutePreset.vibDepth, Fs);
note4 = flute(349, crotchetDuration * 2, flute2Preset.breath, flute2Preset.pressure, flute2Preset.attack, flute2Preset.vibDepth, Fs);
note5 = flute(329, crotchetDuration * 2, flute2Preset.breath, flute2Preset.pressure, flute2Preset.attack, flute2Preset.vibDepth, Fs);
note6 = flute(311, crotchetDuration * 2, flute2Preset.breath, flute2Preset.pressure, flute2Preset.attack, flute2Preset.vibDepth, Fs);
chord = zeros(clipLength, 1);
for n=1:6
    startSample = floor((n - 1) * length(note1) + 1);
    endSample = startSample + length(note1) - 1;
    disp(startSample);
    chord(startSample:endSample) = 0.33 * (note1 + note2 + note3);
end
chord(1:length(note4)) = chord(1:length(note4)) + 2 * note4';
chord(length(note4):2 * length(note4) - 1) = chord(1:length(note4)) + 2 * note5';
chord(2 * length(note4): 3 * length(note4) - 1) = chord(1:length(note4)) + 2* note6';

resonated = resonate(chord, 0.8, resPreset.dimensions, ...
    resPreset.excitationPoint, resPreset.excitationSize, 0.01, ...
    resPreset.outputPoint, 4096);

[reverbed, ir] = reverberate(resonated, Fs, 0.3, revPreset.feedback, ...
    revPreset.earlyReflectionsPath);

plot(reverbed);

sound(reverbed, Fs);
