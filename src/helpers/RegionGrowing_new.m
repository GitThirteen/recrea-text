classdef RegionGrowing_new
    methods(Static)
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
        
        function [regionMask, regions] = regionGrowingArr(image, x, y, threshold)
            [regionMask, regions] = regionGrowingArrFromGrayscale(rgb2gray(image), x, y, threshold);
        end
        
        function [regionMask, regions] = regionGrowingArrFromGrayscale(grayscaleImage, x, y, threshold)
            regionMask = 0;
            length = min(size(x), size(y));
            
            for i = 0:length
                if regionMask(x(i), y(i)) ~= 0
                    continue;
                end
                
                regions = regions + 1;
                nextMask = regionGrowing(grayscaleImage, x(i), y(i), threshold);
                regionMask = regionMask + (nextMask .* regions);
            end
        end
    end
end