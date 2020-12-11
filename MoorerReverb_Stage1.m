% The Moorer Reverb Design starting with the Feedback Comb Filter,
% developing into a Schroeder Reverb script to finally add
% Early Reflections and a low-pass filter in the feedback 
% path of the comb filters.
%
% Developed from examples in: 
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" by Eric Tarr.
%
% DTM, 6/11/2018
% 

clear;
clc;

% Load in an example test file
[audio_signal, Fs] = audioread('drums.wav');

% Zero pad the file so the output will include the reverb tail
in = zeros(length(audio_signal) + (Fs * 3), 1);
in(1:length(audio_signal)) = audio_signal;

% Define impulse excitation for obtaining impulse response
IR_test = zeros(Fs * 3, 1);
IR_test(1) = 1;

% Initialize Main Output Signal
N_out = length(in);
out = zeros(N_out, 1);

% Initialize Impulse Response Output Signal
N_IR = length(IR_test);
IR_out = zeros(N_IR, 1);

% Set Maximum delay time for the unit reverberators of 70 ms
maxDelay = ceil(0.07 * Fs);

% Initialize all buffers - one buffer per unit reverberator
buffer1 = zeros(maxDelay, 1); 
buffer2 = zeros(maxDelay, 1); 
buffer3 = zeros(maxDelay, 1); 
buffer4 = zeros(maxDelay, 1); 

% Initialise the Early Reflection Unit Tapped Delay Line
er_buffer = zeros(maxDelay, 1);

% Delay (ms) and Gain Parameters
% Comb Filters
d1 = floor(0.0297 * Fs); 
d2 = floor(0.0371 * Fs);
d3 = floor(0.0411 * Fs);
d4 = floor(0.0437 * Fs);
g1 = 0.6;
g2 = 0.7;
g3 = 0.75;
g4 = 0.8;

% Allpass filters
apf_buffer1 = zeros(maxDelay, 1); 
apf_buffer2 = zeros(maxDelay, 1); 

apf_d1 = floor(0.005 * Fs); 
apf_d2 = floor(0.0017 * Fs); 

apf_g1 = 0.875;
apf_g2 = 0.75;

% Variables used as delay for a simple LPF in each Comb Filter function
fbLPF1 = 0;
fbLPF2 = 0;
fbLPF3 = 0;
fbLPF4 = 0;

% Impulse Response
for n = 1:N_IR
    
    [IR_er, er_buffer] = EarlyReflections(IR_test(n, 1), er_buffer, Fs, n);
    
    % Early Reflection Tapped Delay Line
    [IR_combA, buffer1, fbLPF1] = FeedbackComb(IR_er, buffer1, n, d1, g1, fbLPF1, true);
    [IR_combB, buffer2, fbLPF2] = FeedbackComb(IR_er, buffer2, n, d2, g2, fbLPF2, true);
    [IR_combC, buffer3, fbLPF3] = FeedbackComb(IR_er, buffer3, n, d3, g3, fbLPF3, true);
    [IR_combD, buffer4, fbLPF4] = FeedbackComb(IR_er, buffer4, n, d4, g4, fbLPF4, true);
    
    comb_out = 0.25 * IR_combA + IR_combB + IR_combC + IR_combD;
    
    [IR_apf1, apf_buffer1] = apf(comb_out, apf_buffer1, n, apf_d1, apf_g1);
    [IR_apf2, apf_buffer2] = apf(IR_apf1, apf_buffer2, n, apf_d2, apf_g2);
    
    IR_out(n, 1) = IR_apf2;
    
    % Parallel FBCFs
%     [IR_out(n,1), buffer1, fbLPF1] = FeedbackComb(IR_test(n,1), buffer1, n, d1, g1, fbLPF1, false);
    
    % Two Series All-pass Filters
      
end

% Plot Impulse Response
figure(1);
plot(IR_out);

% Approximate Reverb Time:
% Only becomes useful with later examples.
IR_out = IR_out / max(abs(IR_out)); % Normalize to Unity Gain (0 dB)
Ts = 1 / Fs;
t = [0:N_IR-1] * Ts;
figure(2);
plot(t, 20 * log10(abs(IR_out))); 
line([0 4], [-60 -60], 'Color', 'red', 'LineStyle','--');
axis([0 4 -80 0]);

% Reverberate
for n = 1:N_out
    
    % Early Reflections Tapped Delay Line
    [er, er_buffer] = EarlyReflections(in(n,1), er_buffer, Fs, n);
    
    % Four Parallel FBCFs
    [combA, buffer1, fbLPF1] = FeedbackComb(er, buffer1, n, d1, g1, fbLPF1, true);
    [combB, buffer2, fbLPF2] = FeedbackComb(er, buffer2, n, d2, g2, fbLPF2, true);
    [combC, buffer3, fbLPF3] = FeedbackComb(er, buffer3, n, d3, g3, fbLPF3, true);
    [combD, buffer4, fbLPF4] = FeedbackComb(er, buffer4, n, d4, g4, fbLPF4, true);
    
    comb_out = 0.25 * (combA + combB + combC + combD);
    
    [apf1, apf_buffer1] = apf(comb_out, apf_buffer1, n, apf_d1, apf_g1);
    [apf2, apf_buffer2] = apf(apf1, apf_buffer2, n, apf_d2, apf_g2);
    
    out(n, 1) = apf2;
    
    % Two Series All-pass Filters
    
end

audiowrite('forivy.wav', out, Fs); 
sound(out,Fs);
