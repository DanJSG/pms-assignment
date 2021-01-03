function[frequency] = calculatemode(mode, dimensions)
    frequency = (343 / 2) * sqrt((mode(1)^2 / dimensions(1)^2) + (mode(2)^2 / dimensions(2)^2));
end