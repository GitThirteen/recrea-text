classdef GaussFilter
    %GAUSSFILTER Summary of this class goes here
    
    methods(Static)
        function gaussImage = gauss(image, strength)
            gaussImage = imgaussfilt(image, strength);
        end
    end
end

