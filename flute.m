%FLUTE Digital Waveguide Slide Flute Implementation
% This function implements a slide flute using the 1D digital waveguide
% implementation, with variable breath and pressure levels, attack time and
% tremolo depth.
%
% Input Variables:
%   f0 : fundamental frequency of the note
%   duration : the duration of the note in seconds
%   breath : the strength of the breath (noise) input to the model
%   pressure : the strength of the input 
%   vibDepth : the depth of the tremolo
%   Fs : the sampling frequency
function[output, flow] = flute(f0, duration, breath, pressure, attack, vibDepth, Fs)

    % Number of samples
    N = floor(Fs * duration);

    % Attack, sustain and release as percentage of duration        
    release = 0.001;            

    % Attack end sample
    attackEnd = round(N * attack); 
    % Release start sample
    release_start = round(N * (1 - release));

    % Bore to jet delay feedback gain
    boreFeedback = 0.7;
    % Bore delay reflection coefficient (bore delay feedback gain)
    boreReflection = 0.8;

    boreDelay = 0.25 * floor(Fs / f0);
    jetDelay = floor(boreDelay / 2);

    % Flow Setup: ADSR envelope
    % Attack section
    flow(1:attackEnd) = linspace(0, pressure, attackEnd);

    % Sustain section
    flow(attackEnd + 1:release_start) = pressure;
    % Release section
    flow(release_start + 1:N) = linspace(pressure, 0, N - release_start);

    % Output amplitude Envelope
    % Attack section
    outputEnv(1:1000) = linspace(0, 1.0, 1000);
    % Sustain section
    outputEnv(1000 + 1:N - 1000) = 1.0;
    % Release section
    outputEnv(N - 1000 + 1:N) = linspace(1.0, 0, 1000);

    % Vibrato envelope
    % Attack
    vibratoEnv(1:floor(N / 4)) = linspace(0.25, 1, N / 4);
    % Sustain
    vibratoEnv(floor(N / 4):N) = 1.0;

    % Vibrato
    vibratoSamples = 1:1:N;
    vibrato = sin(2 * pi * 5.5 * (vibratoSamples / Fs));

    % Noise source
    noise = 0.95 * rand(1, N) - 1;

    % Input excitation
    excitation = (breath * (noise .* flow)) + flow + vibrato * vibDepth .* vibratoEnv;

    % Audio delay lines (buffers)
    % Right-going delay line, length defined by bore_delay
    rightBore = zeros(1, round(boreDelay));
    % Left-going delay line, length defined by bore_delay
    leftBore = zeros(1, round(boreDelay));
    % Jet delay
    jet = zeros(1, jetDelay);
    % Initialize output
    output = zeros(1, N);

    % Number of poles for the filter
    numPoles = 2;

    % Initialise matrix for storing previous samples
    prevSamples = zeros(numPoles, 1);

    % Main digital waveguide loop
    for n = 1:N

        % Update previous samples
        for k=1:numPoles - 1
           prevSamples(k + 1) = prevSamples(k); 
        end
        prevSamples(1) = leftBore(round(boreDelay));

        % Set value of first sample in the jet delay line
        jet(1) = excitation(n) + boreFeedback * leftBore(1);

        % Nonlinear interaction between excitation and flute bore
        r = jet(jetDelay) - (jet(jetDelay) * jet(jetDelay) * jet(jetDelay));

        % Limit between 0 and 1
        if (r < -1) 
            r = -1;
        elseif (r > 1) 
            r = 1; 
        end

        % Set value of first sample in the jet delay line
        rightBore(1) = r + boreReflection * leftBore(1);

        % Moving average filter
        filter = (1 / (numPoles + 1)) * leftBore(round(boreDelay));
        for k=1:numPoles
            filter = filter + (1 / (numPoles + 1)) * prevSamples(k);
        end

        % Set value at the end of the left bore delay line
        leftBore(round(boreDelay)) =  -0.98 * filter;

        % Set the output at the current time point
        output(n) = rightBore(round(boreDelay));

        % Update Delay Lines
        jet = [0, jet(1:jetDelay - 1)];
        right_end = rightBore(round(boreDelay));
        rightBore = [leftBore(1), rightBore(1:round(boreDelay) - 1)];
        leftBore = [leftBore(2:round(boreDelay)), right_end];

    end

    % Apply output envelope to smooth input and output
    output = output .* outputEnv;
    
end

