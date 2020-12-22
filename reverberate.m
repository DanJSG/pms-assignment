function [output, ir] = reverberate(Fs, input, feedback, mix)

    % Zero pad the file so the output will include the reverb tail
    in = zeros(length(input) + (Fs * 3), 1);
    in(1:length(input)) = input;

    % Define impulse excitation for obtaining impulse response
    irTest = zeros(Fs * 3, 1);
    irTest(1) = 1;

    % Initialize Main Output Signal
    nOutputSamples = length(in);
    output = zeros(nOutputSamples, 1);

    % Initialize Impulse Response Output Signal
    nIrSamples = length(irTest);
    irOutput = zeros(nIrSamples, 1);

    % Set Maximum delay time for the unit reverberators of 70 ms
    maxDelay = ceil(0.07 * Fs);

    % Initialize all buffers - one buffer per unit reverberator
    buffer1 = zeros(maxDelay, 1); 
    buffer2 = zeros(maxDelay, 1); 
    buffer3 = zeros(maxDelay, 1); 
    buffer4 = zeros(maxDelay, 1); 

    % Initialise the Early Reflection Unit Tapped Delay Line
    earlyReflectionsBuffer = zeros(maxDelay, 1);

    % Delay (ms) and Gain Parameters
    % Comb Filters
    delay1 = floor(0.0297 * Fs); 
    delay2 = floor(0.0371 * Fs);
    delay3 = floor(0.0411 * Fs);
    delay4 = floor(0.0437 * Fs);
    gain1 = feedback;
    gain2 = feedback;
    gain3 = feedback;
    gain4 = feedback;

    % Allpass filters
    apfBuffer1 = zeros(maxDelay, 1); 
    apfBuffer2 = zeros(maxDelay, 1); 

    apfBuffer3 = floor(0.005 * Fs); 
    apfBuffer4 = floor(0.0017 * Fs); 

    apfGain1 = 0.875;
    apfGain2 = 0.75;

    % Impulse Response
    for n = 1:nIrSamples

        [irEarlyReflections, earlyReflectionsBuffer] = EarlyReflections(irTest(n, 1), earlyReflectionsBuffer, Fs, n);

        % Early Reflection Tapped Delay Line
        [irComb1, buffer1] = FeedbackComb(irEarlyReflections, buffer1, n, delay1, gain1, true);
        [irComb2, buffer2] = FeedbackComb(irEarlyReflections, buffer2, n, delay2, gain2, true);
        [irComb3, buffer3] = FeedbackComb(irEarlyReflections, buffer3, n, delay3, gain3, true);
        [irComb4, buffer4] = FeedbackComb(irEarlyReflections, buffer4, n, delay4, gain4, true);

        combOutput = 0.25 * irComb1 + irComb2 + irComb3 + irComb4;

        [irApf1, apfBuffer1] = apf(combOutput, apfBuffer1, n, apfBuffer3, apfGain1);
        [irApf2, apfBuffer2] = apf(irApf1, apfBuffer2, n, apfBuffer4, apfGain2);

        irOutput(n, 1) = irApf2;

    end
    
    ir = irOutput;

    % Reverberate
    for n = 1:nOutputSamples

        % Early Reflections Tapped Delay Line
        [er, earlyReflectionsBuffer] = EarlyReflections(in(n,1), earlyReflectionsBuffer, Fs, n);

        % Four Parallel FBCFs
        [comb1, buffer1] = FeedbackComb(er, buffer1, n, delay1, gain1, true);
        [comb2, buffer2] = FeedbackComb(er, buffer2, n, delay2, gain2, true);
        [comb3, buffer3] = FeedbackComb(er, buffer3, n, delay3, gain3, true);
        [comb4, buffer4] = FeedbackComb(er, buffer4, n, delay4, gain4, true);

        combOutput = 0.25 * (comb1 + comb2 + comb3 + comb4);

        [apf1, apfBuffer1] = apf(combOutput, apfBuffer1, n, apfBuffer3, apfGain1);
        [apf2, apfBuffer2] = apf(apf1, apfBuffer2, n, apfBuffer4, apfGain2);

        output(n, 1) = apf2;

    end
    
    output = ((1 - mix) * in) + (mix * output);
    
end

