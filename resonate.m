%RESONATE 2D Absorbing Membrane Resonator
% This function uses a 2D finite difference equations to resonate an input
% signal with an absorbing membrane with the dimensions specified. Uses an
% excitation point specified with a given size (rectangular), a single
% output point and a set number of samples.
% Input Variables:
%   input : the input signal
%   mix : the dry/wet mix between the input signal and resonated signal
%   dimensions : a 2 point vector of the length and height of the membrane
%   excitationPoint : the centre point of the excitation of the membrane
%   excitationSize : the size of the excitation area of the membrane
%   boundaryGain : the gain at the boundaries of the membrane
%   outputPoint : the point on the membrane the output is taken from
%   nMembraneSamples : the number of samples on the membrane
function[output] = resonate(input, mix, dimensions, excitationPoint, ...
    excitationSize, boundaryGain, outputPoint, nMembraneSamples)

    % Number of points in X and Y directions
    nPointsX = dimensions(1);
    nPointsY = dimensions(2);

    % Initialise variables for the current and next displacement values of the
    % membrane
    currentDisplacement = zeros(nPointsX, nPointsY);
    nextDisplacement = zeros(nPointsX, nPointsY);

    % Initialise variable for the membrane's response
    membraneResponse = zeros(1, nMembraneSamples);

    % Variables for the range of points that will be excited by the input
    excitationRangeX = excitationPoint(1) - excitationSize:excitationPoint(1) + excitationSize;
    excitationRangeY = excitationPoint(2) - excitationSize:excitationPoint(2) + excitationSize;

    % Define a hanning window based on the excitation size with an amplitude of
    % 5
    excitationImpulse =  5 * hanning(excitationSize * 2 + 1);
    excitationShape = excitationImpulse * excitationImpulse';

    % Load the shape into the centre of the mesh at current timestep (t) 
    currentDisplacement(excitationRangeX, excitationRangeY) = excitationShape;
    % Let the mesh at the previous timestep, t-1 have the same shape.
    prevDisplacement = currentDisplacement;

    % Square root of 2
    root2 = sqrt(2.0);

    % The boundary coefficients
    boundaryCoeff1 = root2 / (root2 + boundaryGain);
    boundaryCoeff2 = 1/(2.0 + (root2 * boundaryGain)); 
    boundaryCoeff3 = (boundaryGain - root2) / (boundaryGain + root2);

    % Main loop for calculating and updating membrane displacements. Loops for
    % the number of membrane samples defined in the function argument.
    for n=1:nMembraneSamples

        % Loop through the membrane in the X-direction
        for l = 1:nPointsX
            % Loop through the membrane in the Y-direction
            for h = 1:nPointsY   
                % Bottom Left Corner
                if (l == 1) && (h == 1)          
                    nextDisplacement(l, h) = 0;
                % Bottom Right Corner
                elseif (l == nPointsX) && (h == 1)     
                    nextDisplacement(l,h) = 0;
                % Top Left Corner
                elseif (l == 1) && (h == nPointsY)     
                    nextDisplacement(l,h) = 0;
                % Top Right Corner
                elseif (l == nPointsX) && (h == nPointsY)     
                    nextDisplacement(l,h) = 0;
                % Left Boundary
                elseif (l == 1) && (h ~= nPointsY) && (h ~= 1)
                    nextDisplacement(l, h) = boundaryCoeff1 * currentDisplacement(l + 1, h) + boundaryCoeff2 * (currentDisplacement(l, h + 1) + currentDisplacement(l, h - 1))+ boundaryCoeff3 * prevDisplacement(l, h);
                % Right Boundary
                elseif (l == nPointsX) && (h ~= nPointsY) && (h ~= 1)            
                    nextDisplacement(l, h) = boundaryCoeff1 * currentDisplacement(l - 1, h) + boundaryCoeff2 * (currentDisplacement(l, h+1) + currentDisplacement(l, h-1))+ boundaryCoeff3 * prevDisplacement(l, h);
                % Bottom Boundary
                elseif (h == 1) && (l ~= nPointsX) && (l ~= 1)             
                    nextDisplacement(l, h) = boundaryCoeff1*currentDisplacement(l, h + 1) + boundaryCoeff2*(currentDisplacement(l + 1, h) + currentDisplacement(l - 1, h))+ boundaryCoeff3*prevDisplacement(l, h);
                % Top Boundary
                elseif (h == nPointsY) && (l ~= nPointsX) && (l ~= 1)            
                    nextDisplacement(l, h) = boundaryCoeff1 * currentDisplacement(l, h-1) + boundaryCoeff2 * (currentDisplacement(l+1, h) + currentDisplacement(l-1, h))+ boundaryCoeff3 * prevDisplacement(l, h);
                % Anywhere else on the membrane (not a boundary or corner)
                elseif (h ~= 1) && (h ~= nPointsY) && (l ~= 1) && (l ~= nPointsX) 
                    % Finite difference equation
                    nextDisplacement(l, h) = ((1 / 2) * (currentDisplacement(l + 1, h) + currentDisplacement(l - 1, h) + currentDisplacement(l, h + 1) + currentDisplacement(l, h - 1))) - prevDisplacement(l, h);
                end
            end
        end

        % Update the membrane response
        membraneResponse(n) = nextDisplacement(outputPoint(1), outputPoint(2));

        % Update membrane's mesh history
        prevDisplacement = currentDisplacement;
        currentDisplacement = nextDisplacement;

    end

    % Create a low pass filter and low pass filter the response of the membrane
    lpf = fir1(20, 0.25);
    filteredMembraneResponse = filter(lpf, 1, membraneResponse);

    % Convolve the input signal 
    output = conv(input, filteredMembraneResponse);

    % Zero pad the input to match the length of the output to allow for the dry
    % signal to be mixed with the wet signal
    sampleDiff = length(output) - length(input);
    input(end:end + sampleDiff) = 0;

    % Mix the dry input with the resonated output signal
    output = ((1 - mix) * input) + (mix * output);

end





