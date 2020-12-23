function [output, ir] = reverberate(input, Fs, mix, feedback, reflectionPresetPath)

    earlyReflectionVals = readmatrix(reflectionPresetPath);

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

    % Delay (ms)
    % Comb Filters
    delay1 = floor(0.0297 * Fs); 
    delay2 = floor(0.0371 * Fs);
    delay3 = floor(0.0411 * Fs);
    delay4 = floor(0.0437 * Fs);

    % Allpass filters
    apfBuffer1 = zeros(maxDelay, 1); 
    apfBuffer2 = zeros(maxDelay, 1);    
    
    apfDelayTime1 = floor(0.005 * Fs); 
    apfDelayTime2 = floor(0.0017 * Fs); 
    
    apfGain1 = 0.875;
    apfGain2 = 0.75;

    % Impulse Response
    for n=1:nIrSamples

        [irEarlyReflections, earlyReflectionsBuffer] = earlyreflections(irTest(n, 1), earlyReflectionsBuffer, Fs, n, earlyReflectionVals);
        
        % Early Reflection Tapped Delay Line
        [irComb1, buffer1] = feedbackcomb(irEarlyReflections, buffer1, n, delay1, feedback, true);
        [irComb2, buffer2] = feedbackcomb(irEarlyReflections, buffer2, n, delay2, feedback, true);
        [irComb3, buffer3] = feedbackcomb(irEarlyReflections, buffer3, n, delay3, feedback, true);
        [irComb4, buffer4] = feedbackcomb(irEarlyReflections, buffer4, n, delay4, feedback, true);
        
        combOutput = 0.25 * irComb1 + irComb2 + irComb3 + irComb4;
        
        [irApf1, apfBuffer1] = apf(combOutput, apfBuffer1, n, apfDelayTime1, apfGain1);
        [irApf2, apfBuffer2] = apf(irApf1, apfBuffer2, n, apfDelayTime2, apfGain2);

        irOutput(n, 1) = irApf2;
        
    end
    
    ir = irOutput;

    % Reverberate
    for n = 1:nOutputSamples

        % Early Reflections Tapped Delay Line
        [er, earlyReflectionsBuffer] = earlyreflections(in(n,1), earlyReflectionsBuffer, Fs, n, earlyReflectionVals);
        
        % Four Parallel FBCFs
        [comb1, buffer1] = feedbackcomb(er, buffer1, n, delay1, feedback, true);
        [comb2, buffer2] = feedbackcomb(er, buffer2, n, delay2, feedback, true);
        [comb3, buffer3] = feedbackcomb(er, buffer3, n, delay3, feedback, true);
        [comb4, buffer4] = feedbackcomb(er, buffer4, n, delay4, feedback, true);
        
        combOutput = 0.25 * (comb1 + comb2 + comb3 + comb4);

        
        [apf1, apfBuffer1] = apf(combOutput, apfBuffer1, n, apfDelayTime1, apfGain1);
        [apf2, apfBuffer2] = apf(apf1, apfBuffer2, n, apfDelayTime2, apfGain2);
        
        output(n, 1) = apf2;
        
    end

      
    output = normalize(((1 - mix) * in) + (mix * output), 'range', [-0.98, 0.98]);
    
end



