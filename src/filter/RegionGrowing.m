classdef RegionGrowing
    %REGIONGROWING Summary of this class goes here
    
    methods(Static)
        function matrix = grow(image)
            mask = zeros(size(image));
            mask(25:end-25,25:end-25) = 1;
            matrix = activecontour(image, mask, 300);
        end
    end
end

