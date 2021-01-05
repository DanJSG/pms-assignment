%APF All Pass Filter Unit Reverberator
% This function creates an all-pass filter by 
% processing an individual input sample and updating 
% a delay buffer used in a loop to index each sample
% in a signal.
%
% Developed from examples in: 
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" by Eric Tarr.
%
% DTM, 6/11/2018
% Last Modified: Y3846756, 22/12/2020
% 
% Input Variables
%   in : input signal
%   buffer : the buffer containing the previous and future signal values
%   n : current sample number of the input signal
%   delay : samples of delay
%   gain : feed-back gain (linear scale)
function [out, buffer] = apf(in, buffer, n, delay, gain)

    % Determine indexes for circular buffer
    len = length(buffer);
    indexC = mod(n-1, len) + 1; % Current index 
    indexD = mod(n-delay-1, len) + 1; % Delay index

    % Temp variable for output of delay buffer
    w = buffer(indexD, 1);

    % Temp variable used for the node after the input sum
    v = in + gain * w;

    % Summation at output
    out = (-gain * v) + w;

    % Store the current input to delay buffer
    buffer(indexC, 1) = v;
    
end

