%RRFLUTE Digital Waveguide Flute Resonated Through a Membrane, with Digital
%        Reverb
% This function creates a flute sound using a physical model based on the
% 1D digital waveguide implementation. This flute sound is then convolved
% with a physical model of a resonant membrane, the response of which is 
% calculated using a 2D finite difference equation. This is all then
% processed through a digital reverb, based on the Moorer reverb algorithm.
% Input Variables:
%   frequency : the frequency of the flute
%   duration : the duration of the flute note
%   breathLevel : the strength of the breath in the flute model
%   pressure : the strength of the input to the flute model
%   attackTime : the attack time of the flute
%   vibDepth : the depth of the tremolo of the flute
%   resDimensions : the dimensions of the membrane resonator
%   resExcitationPoint : the centre of the excitation point of the membrane
%   resExcitationSize : the rectangular size of the exication point
%   resBoundaryGain : the gain at the boundaries of the membrane
%   resOutputPoint : the output point of the membrane
%   nMembraneSamples : the number of samples used for the membrane
%   revFeedback : the feedback level of the reverb comb filters (affects
%                 decay time)
%   revEarlyReflectionsPath : the filepath of an early reflections preset
%   resMix : the dry/wet mix of the resonated sound and the flute input
%   revMix : the dry/wet mix of the reverberant sound and the direct sound
%   
function[output] = rrflute(frequency, duration, breathLevel, pressure, ...
    attackTime, vibDepth, resDimensions, resExcitationPoint, ...
    resExcitationSize, resBoundaryGain, resOutputPoint, nMembraneSamples, ...
    revFeedback, revEarlyReflectionsPath, resMix, revMix, Fs)
    
    % Get the output of the flute model with the given parameters
    note = flute(frequency, duration, breathLevel, pressure, attackTime, ...
        vibDepth, Fs);
    
    % Convolve the flute sound through an absorbing membrane model with the
    % given parameters
    resonated = resonate(note, resMix, resDimensions, resExcitationPoint, ...
        resExcitationSize, resBoundaryGain, resOutputPoint, nMembraneSamples);
    
    % Add reverb to the resonant sound and use this as the output
    output = reverberate(resonated, Fs, revMix, revFeedback, revEarlyReflectionsPath);

end
