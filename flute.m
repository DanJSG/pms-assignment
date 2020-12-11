function[output, flow] = flute(Fs, f0, duration, breath, pressure, attack, vib_depth)
    
    % Number of samples
    N = Fs * duration;
    
    % Attack, sustain and release as percentage of duration        
    sustain = 0.2;              
    release = 0.001;            
    
    % Attack end sample
    attack_end = round(N * attack);
    % Sustain start sample
    sustain_start = round(N * sustain);      
    % Decay length in samples
    decay_length = sustain_start - attack_end;
    % Release start sample
    release_start = round(N * (1 - release));
    
    % Bore to jet delay feedback gain
    bore_feedback = 0.7;
    % Bore delay reflection coefficient (bore delay feedback gain)
    bore_reflection = 0.8;
    
    bore_delay = 0.25 * floor(Fs / f0);
    jet_delay = floor(bore_delay / 2);
    
%     disp(bore_delay);
    
    % Flow Setup: ADSR envelope
    % Attack section
    flow(1:attack_end) = linspace(0, pressure, attack_end);
    
    % Decay section
%     flow(attack_end + 1:attack_end + decay_length) = linspace(pressure, pressure, decay_length); 

    % Sustain section
    flow(attack_end + 1:release_start) = pressure;
    % Release section
    flow(release_start + 1:N) = linspace(pressure, 0, N - release_start);
    
    % Output amplitude Envelope
    % Attack section
    out_env(1:1000) = linspace(0, 1.0, 1000);
    % Sustain section
    out_env(1000 + 1:N - 1000) = 1.0;
    % Release section
    out_env(N - 1000 + 1:N) = linspace(1.0, 0, 1000);
    
    % Vibrato envelope
    % Attack
    vib_env(1:N / 4) = linspace(0.25, 1, N / 4);
    % Sustain
    vib_env(N / 4:N) = 1.0;
    
    % Vibrato
    vib_samples = 1:1:N;
    vibrato = sin(2 * pi * 5.5 * (vib_samples / Fs));
    
    % Noise source
    noise = 0.95 * rand(1, N) - 1;
    
    % Input excitation
    excitation = (breath * (noise .* flow)) + flow + vibrato * vib_depth .* vib_env;
    
    % Audio delay lines (buffers)
    % Right-going delay line, length defined by bore_delay
    right_bore = zeros(1, round(bore_delay));
    % Left-going delay line, length defined by bore_delay
    left_bore = zeros(1, round(bore_delay));
    % Jet delay
    jet = zeros(1, jet_delay);
    % Initialize output
    output = zeros(1, N);
    
    num_poles = 2;
    prev_samples = zeros(num_poles, 1);
    
    % Main digital waveguide loop
    for n = 1:N
        
        % Update previous samples
        for k=1:num_poles - 1
           prev_samples(k + 1) = prev_samples(k); 
        end
        prev_samples(1) = left_bore(round(bore_delay));
        
        jet(1) = excitation(n) + bore_feedback * left_bore(1);

        % Nonlinear interaction between excitation and flute bore
        r = jet(jet_delay) - (jet(jet_delay) * jet(jet_delay) * jet(jet_delay));
        
        % Limit between 0 & 1
        if (r < -1) 
            r=-1; 
        end
        if (r > 1) 
            r=1; 
        end

        right_bore(1) = r + bore_reflection * left_bore(1);
        
        % Moving average filter
        filter = (1 / (num_poles + 1)) * left_bore(round(bore_delay));
        for k=1:num_poles
            filter = filter + (1 / (num_poles + 1)) * prev_samples(k);
        end

        left_bore(round(bore_delay)) =  -0.98 * filter;

        output(n) = right_bore(round(bore_delay));

        % Update Delay Lines
        jet = [0, jet(1:jet_delay - 1)];
        right_end = right_bore(round(bore_delay));
        right_bore = [left_bore(1), right_bore(1:round(bore_delay) - 1)];
        left_bore = [left_bore(2:round(bore_delay)), right_end];

    end
    
    % Apply output envelope to smooth input and output
    output = output .* out_env;
    output = 0.97 * normalize(output, 'range', [-1, 1]);
    
end

