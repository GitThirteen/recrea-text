classdef EdgeDetector
    %SOBEL Edge detector
    
    methods(Static)
        function sobelImage = sobelFilter(image)
            image = image(:,:,1);
            sobelImage = edge(image, 'sobel');
        end
        
        function cannyImage = cannyFilter(image)
            image = image(:,:,1);
            cannyImage = edge(image, 'canny');
        end
    end
end

