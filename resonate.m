function[output] = resonate(input, mix, dimensions, excitationPoint, ...
    excitationSize, boundaryGain, outputPoint, nMembraneSamples)
    
    nPointsX = dimensions(1);
    nPointsY = dimensions(2);
    
    currentDisplacement = zeros(nPointsX, nPointsY);
    nextDisplacement = zeros(nPointsX, nPointsY);
    
    membraneResponse = zeros(1, nMembraneSamples);
    
    excitationRangeX = excitationPoint(1) - excitationSize:excitationPoint(1) + excitationSize;
    excitationRangeY = excitationPoint(2) - excitationSize:excitationPoint(2) + excitationSize;
    
    % Define a hanning window function, with an amplitude of 5.0 and a window
    % size of 9 sample points - this is essenitally a smoothed impulse.
    excitationImpulse =  5 * hanning(excitationSize * 2 + 1);
    excitationShape = excitationImpulse * excitationImpulse';
    
    % Load the shape into the centre of the mesh at current timestep (t) 
    currentDisplacement(excitationRangeX, excitationRangeY) = excitationShape;
    % Let the mesh at the previous timestep, t-1 have the same shape.
    prevDisplacement = currentDisplacement;
    
    root2 = sqrt(2.0);
       
    boundaryCoeff1 = root2 / (root2 + boundaryGain);
    boundaryCoeff2 = 1/(2.0 + (root2 * boundaryGain)); 
    boundaryCoeff3 = (boundaryGain - root2) / (boundaryGain + root2);

    % MAIN LOOP
    for n=1:nMembraneSamples
        % finite difference equation
        
        for l = 1:nPointsX                              
            for h = 1:nPointsY   
                if (l == 1) && (h == 1)          % Bottom Left Corner  
                    nextDisplacement(l, h) = 0;
                elseif (l == nPointsX) && (h == 1)     % Bottom Right Corner
                    nextDisplacement(l,h) = 0;
                elseif (l == 1) && (h == nPointsY)     % Bottom Right Corner
                    nextDisplacement(l,h) = 0;
                elseif (l == nPointsX) && (h == nPointsY)     % Bottom Right Corner
                    nextDisplacement(l,h) = 0;
                elseif (l == 1) && (h ~= nPointsY) && (h ~= 1)             % Left Boundary
                    nextDisplacement(l, h) = boundaryCoeff1 * currentDisplacement(l + 1, h) + boundaryCoeff2 * (currentDisplacement(l, h + 1) + currentDisplacement(l, h - 1))+ boundaryCoeff3 * prevDisplacement(l, h);
                elseif (l == nPointsX) && (h ~= nPointsY) && (h ~= 1)            % Right Boundary
                    nextDisplacement(l, h) = boundaryCoeff1 * currentDisplacement(l - 1, h) + boundaryCoeff2 * (currentDisplacement(l, h+1) + currentDisplacement(l, h-1))+ boundaryCoeff3 * prevDisplacement(l, h);
                elseif (h == 1) && (l ~= nPointsX) && (l ~= 1)             % Bottom Boundary
                    nextDisplacement(l, h) = boundaryCoeff1*currentDisplacement(l, h + 1) + boundaryCoeff2*(currentDisplacement(l + 1, h) + currentDisplacement(l - 1, h))+ boundaryCoeff3*prevDisplacement(l, h);
                elseif (h == nPointsY) && (l ~= nPointsX) && (l ~= 1)            % Top Boundary
                    nextDisplacement(l, h) = boundaryCoeff1 * currentDisplacement(l, h-1) + boundaryCoeff2 * (currentDisplacement(l+1, h) + currentDisplacement(l-1, h))+ boundaryCoeff3 * prevDisplacement(l, h);
                elseif (h ~= 1) && (h ~= nPointsY) && (l ~= 1) && (l ~= nPointsX) 
                     nextDisplacement(l, h) = ((1 / 2) * (currentDisplacement(l + 1, h) + currentDisplacement(l - 1, h) + currentDisplacement(l, h + 1) + currentDisplacement(l, h - 1))) - prevDisplacement(l, h);
                end
            end
        end
        
        membraneResponse(n) = nextDisplacement(outputPoint(1), outputPoint(2));
        
        % update mesh history
        prevDisplacement = currentDisplacement;
        currentDisplacement = nextDisplacement;

    end
    
    lpf = fir1(20, 0.25);
    filteredMembraneResponse = filter(lpf, 1, membraneResponse);
    output = conv(input, filteredMembraneResponse);
    
    sampleDiff = length(output) - length(input);
    
    input(end:end + sampleDiff) = 0;
    
    output = ((1 - mix) * input) + (mix * output);

end





