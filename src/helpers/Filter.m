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
        
        
        
        function gaussImage = gaussFilter(image, strength)
            gaussImage = imgaussfilt(image, strength);
        end
        
        
    end
end

