function [output, ir] = reverberate(Fs, input, feedback, mix, reflectionPresetPath)

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
%     buffers = zeros(maxDelay, 4);
%     
    buffer1 = zeros(maxDelay, 1); 
    buffer2 = zeros(maxDelay, 1); 
    buffer3 = zeros(maxDelay, 1); 
    buffer4 = zeros(maxDelay, 1); 

    % Initialise the Early Reflection Unit Tapped Delay Line
    earlyReflectionsBuffer = zeros(maxDelay, 1);

    % Delay (ms) and Gain Parameters
    % Comb Filters
    
%     delays = [floor(0.0297 * Fs), floor(0.0371 * Fs), floor(0.0411 * Fs), ...
%         floor(0.0437 * Fs)];
    
    delay1 = floor(0.0297 * Fs); 
    delay2 = floor(0.0371 * Fs);
    delay3 = floor(0.0411 * Fs);
    delay4 = floor(0.0437 * Fs);
    
%     gain1 = feedback;
%     gain2 = feedback;
%     gain3 = feedback;
%     gain4 = feedback;

    % Allpass filters
    
%     apfBuffers = zeros(maxDelay, 2);
    
    apfBuffer1 = zeros(maxDelay, 1); 
    apfBuffer2 = zeros(maxDelay, 1);
    
%     apfDelays = [floor(0.005 * Fs), floor(0.0017 * Fs)];
    
    apfDelayTime1 = floor(0.005 * Fs); 
    apfDelayTime2 = floor(0.0017 * Fs); 
    
%     apfGains = [0.875, 0.75];
    
    apfGain1 = 0.875;
    apfGain2 = 0.75;
    
%     irCombs = zeros(4, 1);
    
%     irApfs = zeros(2, 1);
    
    disp("Going into IR loop");
    
    % Impulse Response
    for n=1:nIrSamples

        [irEarlyReflections, earlyReflectionsBuffer] = earlyreflections(irTest(n, 1), earlyReflectionsBuffer, Fs, n, earlyReflectionVals);
        
%         for m=1:4
%             [irCombs(m), buffers(:, m)] = feedbackcomb(irEarlyReflections, buffers(:, m), n, delays(m), feedback, true);
%         end
        
        % Early Reflection Tapped Delay Line
        [irComb1, buffer1] = feedbackcomb(irEarlyReflections, buffer1, n, delay1, feedback, true);
        [irComb2, buffer2] = feedbackcomb(irEarlyReflections, buffer2, n, delay2, feedback, true);
        [irComb3, buffer3] = feedbackcomb(irEarlyReflections, buffer3, n, delay3, feedback, true);
        [irComb4, buffer4] = feedbackcomb(irEarlyReflections, buffer4, n, delay4, feedback, true);
        
        combOutput = 0.25 * irComb1 + irComb2 + irComb3 + irComb4;
%         combOutput = 0.25 * sum(irCombs);
        
        [irApf1, apfBuffer1] = apf(combOutput, apfBuffer1, n, apfDelayTime1, apfGain1);
        [irApf2, apfBuffer2] = apf(irApf1, apfBuffer2, n, apfDelayTime2, apfGain2);
        
%         [irApfs(1), apfBuffers(:, 1)] = apf(combOutput, apfBuffers(:, 1), n, apfDelays(1), apfGains(1));
%         [irApfs(2), apfBuffers(:, 2)] = apf(irApfs(1), apfBuffers(:, 2), n, apfDelays(2), apfGains(2));

        irOutput(n, 1) = irApf2;
%         irOutput(n, 1) = irApfs(2);
        
    end
    
    ir = irOutput;
    
%     combs = zeros(4, 1);
%     apfs = zeros(2, 1);
    
    disp("Going into main loop");
    
%     disp(length(buffers(:, 1)));
%     disp(length(buffers(1, :)));
    
    updateCount = 0;

    % Reverberate
    tic
    for n = 1:nOutputSamples

        % Early Reflections Tapped Delay Line
        [er, earlyReflectionsBuffer] = earlyreflections(in(n,1), earlyReflectionsBuffer, Fs, n, earlyReflectionVals);
        
%         for m=1:length(combs)
%             [combs(m), buffers(:, m)] = feedbackcomb(er, buffers(:, m), n, delays(m), feedback, true);
%         end
        
%         Four Parallel FBCFs
        [comb1, buffer1] = feedbackcomb(er, buffer1, n, delay1, feedback, true);
        [comb2, buffer2] = feedbackcomb(er, buffer2, n, delay2, feedback, true);
        [comb3, buffer3] = feedbackcomb(er, buffer3, n, delay3, feedback, true);
        [comb4, buffer4] = feedbackcomb(er, buffer4, n, delay4, feedback, true);
        
%         combOutput = 0.25 * sum(combs);
        combOutput = 0.25 * (comb1 + comb2 + comb3 + comb4);

%         [apfs(1), apfBuffers(:, 1)] = apf(combOutput, apfBuffers(:, 1), n, apfDelays(1), apfGains(1));
%         [apfs(2), apfBuffers(:, 2)] = apf(apfs(1), apfBuffers(:, 2), n, apfDelays(2), apfGains(2));
        
        [apf1, apfBuffer1] = apf(combOutput, apfBuffer1, n, apfDelayTime1, apfGain1);
        [apf2, apfBuffer2] = apf(apf1, apfBuffer2, n, apfDelayTime2, apfGain2);
        
        output(n, 1) = apf2;
        
        updateCount = updateCount + 1;

    end
    
    toc
    
    disp(updateCount);
      
    output = normalize(((1 - mix) * in) + (mix * output), 'range', [-0.98, 0.98]);
    
end



