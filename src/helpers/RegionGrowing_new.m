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
    end
end