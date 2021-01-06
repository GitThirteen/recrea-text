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
            closeObj = strel('diamond', 5);
            binaryImage = imopen(binarized, openObj);
            binaryImage = imclose(binaryImage, closeObj);
        end
        
        % Gauss
        function output = gaussFilter(img, sigma, radius)
            % Generate the kernel.
            [x,y] = meshgrid(-radius:radius, -radius:radius);
            n = size(x, 1) - 1;
            m = size(y, 1) - 1;
            exp_comp = -(x .^ 2 + y .^ 2) / (2 * sigma ^ 2);
            kernel = exp(exp_comp) / (2 * pi * sigma^2);
            
            % If image is RGB
            if (size(img, 3) == 3)
                R = img(:,:,1);
                G = img(:,:,2);
            	B = img(:,:,3);
           
                R_Gauss = Filter.gaussian(R, kernel, radius, n, m);
                G_Gauss = Filter.gaussian(G, kernel, radius, n, m);
                B_Gauss = Filter.gaussian(B, kernel, radius, n, m);
            
                output = cat(3, R_Gauss, G_Gauss, B_Gauss);
            else
                output = Filter.gaussian(img, kernel, radius, n, m);
            end
            
        end
        
        function filteredImage = gaussian(img, kernel, radius, n, m)
            img = double(img);
            
            % Initialize the return image.
            retImage = zeros(size(img));
            workImage = padarray(img,[radius radius]);

            % Loop.
            for i = 1 : size(workImage, 1) - n
                for j = 1 : size(workImage, 2) - m
                    temp = workImage(i:i + n, j:j + m) .* kernel;
                    retImage(i, j) = sum(temp(:));
                end
            end
            
            filteredImage = uint8(retImage);
        end
        
        function regionMask = regionGrowing(image, x, y, threshold)
            regionMask = regionGrowingFromGrayscale(rgb2gray(image), x, y, threshold);
        end
        
        function regionMask = regionGrowingFromGrayscale(grayscaleImage, x, y, threshold)
            % Prime the region mask.
            [width, height] = size(grayscaleImage);
            regionMask = zeros(width, height);
            oldMask = zeros(width, height);
            diamondSE = strel('diamond', 1);
            
            % Set the seed point and dilation strel.
            regionMask(x, y) = 1;
            
            % Iterate until the region stops growing.
            while (sum(regionMask(:)) ~= sum(oldMask(:)))
                oldMask = regionMask;
                segValues = image(regionMask);
                meanSegValue = mean(segValues);
                dilMask = imdilate(regionMask, diamondSE);
                nVal = dilMask - regionMask;
                nValImage = grayscaleImage(nVal);
                regionMask(nValImage > meanSegValue - threshold & nValImage < meanSegValue + threshold) = 1;
            end
        end
        
        function [regionMap, regionsNr] = regionLabeling(image, treshold)
            binaryImage = imageToBinary(image, treshold);
            [regionMap, regionsNr] = regionLabelingFromBinary(binaryImage);
        end
        
        function [regionMap, regionsNr] = regionLabelingFromBinary(binaryImage)
            % Create a binary image the region map.
            regionMap = zeros(size(binaryImage));
            regionsNr = 0;
            
            % Iterate over binary image.
            for i = 1 : size(binaryImage, 1)
                for j = 1 : size(binaryImage, 1)
                    if binaryImage(i, j) == 1 | regionMap(i, j) == 0
                        % If a pixel is in the foreground, but not part of
                        % a region yet, then it becomes the origin of a new
                        % region.
                        tempMask = regionGrowingFromGrayscale(binaryImage, i, j, 0.5);
                        regionsNr = regionsNr + 1;
                        regionMap = regionMap + (tempMask * regionsNr);
                    end
                end
            end
        end
    end
end

