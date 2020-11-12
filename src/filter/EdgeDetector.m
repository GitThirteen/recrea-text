classdef EdgeDetector
    %SOBEL Edge detector
    
    methods(Static)
        function sobelImage = sobelFilter(image)
            sobelImage = edge(image, 'sobel');
        end
        
        function cannyImage = cannyFilter(image)
            cannyImage = edge(image, 'canny');
        end
    end
end

