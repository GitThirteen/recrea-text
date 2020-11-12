classdef main

    methods(Static)
        function image = mainFunc()
            addpath('./filter');
            addpath('../assets');
            image = imread('../assets/privjet.png');
            image = BinaryImage.imageToBinary(image);
            image = EdgeDetector.cannyFilter(image);
            imshow(image);
        end
    end
end
