classdef BinaryImage
    % Returns a black & while image depending on the set threshold
    
    methods(Static)
        function imageToBinary = Binary(image)
            grayImage = rgb2gray(image);
            imageToBinary = imbinarize(grayImage, 'adaptive');
        end
    end
end

