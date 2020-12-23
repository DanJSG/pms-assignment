% EARLYREFLECTIONS
% This function creates a tapped delay line to 
% be used for the Early Reflections of a reverb algorithm.
% The delays and gains of the taps are included below
% 
% Developed from examples in: 
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" by Eric Tarr.
%
% DTM, 6/11/2018
% 
% https://amcoustics.com/tools/amray
function [out, buffer] = earlyreflections(in, buffer, Fs, n, delays)


    % Delay times converted from milliseconds
    delayTimes = fix(Fs * delays(:, 1));

    % There must be a "gain" for each of the "delayTimes"
    gains = delays(:, 2);   

    % Determine indexes for circular buffer
    len = length(buffer);
    indexC = mod(n-1,len) + 1; % Current index 
    buffer(indexC,1) = in;
    
    % Initialize the output to be used in loop
    out = 0; 

    % Loop through all the taps
    for tap = 1:length(delayTimes)
        % Find the circular buffer index for the current tap
        indexTDL = mod(n-delayTimes(tap,1)-1,len) + 1;  

        % "Tap" the delay line and add current tap with output
        out = out + gains(tap,1) * buffer(indexTDL,1);
    end
    
end






