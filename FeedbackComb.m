% Feedback Comb Filter Reverberator
% This function creates a feed-back comb filter by 
% processing an individual input sample and updating 
% a delay buffer used in a loop to index each sample
% in a signal. Option for Low Pass Filter in feedback loop set by a flag.
%
% Developed from examples in: 
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" by Eric Tarr.
%
% DTM, 6/11/2018
% 
% Input Variables
%   n : current sample number of the input signal
%   delay : samples of delay
%   fbGain : feed-back gain (linear scale)
%   LPF: flag to set filter on/off    
%

function [out, buffer] = feedbackcomb(in, buffer, n, delay, fbGain, LPF)

    % Determine indexes for circular buffer
    len = length(buffer);
    indexC = mod(n - 1, len) + 1; % Current index 
    indexD = mod(n - delay - 1, len) + 1; % Delay index

    out = buffer(indexD, 1);

    % Store the current output in appropriate index
    % LPF in feedback loop - Two point moving average
    if LPF == true
        buffer(indexC, 1) = (1 / 2) * (buffer(mod(n - 2, len) + 1, 1) + in + fbGain * out);
    else
        buffer(indexC, 1) = in + fbGain * out;
    end

end

 