classdef Filter
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        % Returns a black & while image depending on the set threshold
        function binaryImage = imageToBinary(image, threshold)
            grayImage = rgb2gray(image);
            
            binarized = imbinarize(grayImage, 'adaptive', 'Sensitivity', threshold);
            
            numblackpixel = sum(binarized == 0);
            numwhitepixel = sum(binarized == 1);
            
            if numblackpixel < numwhitepixel
                binarized = imcomplement(binarized);
            end
            
            openObj = strel('diamond', 3);
            closeObj = strel('diamond', 30);
            binaryImage = imopen(binarized, openObj);
            binaryImage = imclose(binaryImage, closeObj);
        end
        
        
        % Gauss
        function retImage = gaussFilter(image, sigma, radius)
            % Generate the kernel.
            [x,y] = meshgrid(-radius:radius, -radius:radius);
            n = size(x, 1) - 1;
            m = size(y, 1) - 1;
            exp_comp = -(x .^ 2 + y .^ 2) / (2 * sigma ^ 2);
            kernel = exp(exp_comp) / (2 * pi * sigma^2);
            
            % Initialize the return image.
            retImage = zeros(size(image));
            workImage = padarray(image,[radius radius]);
            workImage = im2double(workImage);
            
            % Loop.
            
            for i = 1 : size(workImage, 1) - n
                for j = 1 : size(workImage, 2) - m
                    for k = 1 : size(workImage, 3)
                        temp = workImage(i:(i + n), j:(j + m), k) .* kernel;
                        retImage(i,j,k) = sum(temp(:));
                    end
                end
            end
            
            % Convert the return-image back to integer values.
            %retImage = uint8(retImage);
        end
    end
end

