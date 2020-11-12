classdef main

    methods(Static)
        function image = mainFunc(image)
            addpath('./filter');
            addpath('../assets');
            image = BinaryImage.imageToBinary(image);
            
            %morphObj = strel('line', 10, 90);
            %image = imclose(image, morphObj);
            imshow(image);
        end
    end
end
