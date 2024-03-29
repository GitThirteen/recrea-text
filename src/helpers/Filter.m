classdef Filter
    % FILTER
    % A class containing various filter implementations
    %
    % Functions:
    % > imageToBinary(image, threshold)
    % > Author: Silke Buchberger, Michael Eickmeyer
    % Converts an rgb image to binary image with a set threshold. Also
    % makes sure that there are more black pixels in the background than
    % white pixels, since white (logical 1) is used in further functions as
    % skeleton.
    %
    % > gaussFilter(img, sigma, radius)
    % > Author: Constantin Hammer, Michael Eickmeyer
    % Jumper function that calls gaussian() depending on whether its an RGB
    % or a greyscaled image. Generates the gaussian kernel as well.
    %
    % > gaussian(img, kernel, radius, n, m)
    % > Author: Constantin Hammer, Michael Eickmeyer
    % Loops through an image dimension (in case it's an RGB image 3
    % dimensions) and applies the gaussian kernel calculated in
    % gaussFilter().
    %
    % > regionGrowing(image, x, y, threshold)
    % > Author: Constantin Hammer
    % Selects a region in an RGB image originating from a set seed point.
    %
    % > regionGrowingFromGrayscale(grayscaleImage, x, y, threshold)
    % > Author: Constantin Hammer
    % Selects a region in a greyscale image originating from a set seed
    % point.
    %
    % > regionLabeling(image, treshold)
    % > Author: Constantin Hammer
    % Selects multiple regions from an RGB image using iterative Region
    % Growing.
    %
    % > regionLabelingFromBinary(binaryImage)
    % > Author: Constantin Hammer
    % Selects multiple regions from a greyscale image using iterative
    % Region Growing.
    %
    % > dilate(binaryImage, structuringElement)
    % > Author: Martina Karajica
    % Dilates a binary image with a given structuring element (kernel), 
    %returns the dilated image
    %
    
    methods(Static)
        %% BINERIZATION
        
        % > Parameters:
        % image - the image to be binarized
        % threshold - the threshold for imbinarize
        %
        % > Returns:
        % a black & white image (binarized image containing only 0's or 1's) depending on the set threshold
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
        
        %% GAUSS
        
        % > Parameters:
        % img - the image on which the gaussian is going to be performed on, can be either rgb or greyscaled
        % sigma - the standard deviation of the gaussian kernel
        % radius - the radius (!) of the gaussian kernel
        %
        % > Returns:
        % A matrix containing the values of the blurred image
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
        
        % > Parameters:
        % img - the image to be blurred
        % kernel - the gaussian kernel
        % radius - the radius of the kernel
        %
        % > Returns:
        % A matrix containing the values of the blurred image
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
        
        %% REGION GROWING + LABELING
        
        % > Parameters:
        % image - the RGB image to find regions in
        % x - the x position of the seed
        % y - the y position of the seed
        % threshold - the treshold defining the boundaries of the region
        % 
        % > Returns:
        % a binary mask with the found region
        function regionMask = regionGrowing(image, x, y, threshold)
            grayscaleImage = rgb2gray(image);
            regionMask = Filter.regionGrowingFromGrayscale(grayscaleImage, x, y, threshold);
        end
        
        % > Parameters:
        % grayscaleImage - the greyscale image to find regions in
        % x - the x position of the seed
        % y - the y position of the seed
        % threshold - the treshold defining the boundaries of the region
        % 
        % > Returns:
        % a binary mask with the found region
        function regionMask = regionGrowingFromGrayscale(grayscaleImage, x, y, threshold)
            % Prime the region mask.
            regionMask = false(size(grayscaleImage, 1), size(grayscaleImage, 2));
            oldMask = false(size(grayscaleImage, 1), size(grayscaleImage, 2));
            diamondSE = strel('diamond', 1);
            
            % Set the seed point and dilation strel.
            regionMask(x, y) = 1;
            
            % Iterate until the region stops growing.
            while sum(sum(regionMask)) ~= sum(sum(oldMask))
                oldMask = regionMask;
                segValues = grayscaleImage(regionMask);
                meanSegValue = mean(segValues);
                dilation = imdilate(regionMask, diamondSE) - regionMask;
                nVal = find(dilation);
                nValImage = grayscaleImage(nVal);
                regionMask(nValImage > meanSegValue - threshold & nValImage < meanSegValue + threshold) = 1;
            end
        end
        
        % > Parameters:
        % image - the RGB image to find regions in
        % threshold - the threshold for imbinarize
        % 
        % > Returns:
        % a mask with all the regions with unique integer values | the
        % number of total regions found
        function [regionMap, regionsNr] = regionLabeling(image, threshold)
            binaryImage = Filter.imageToBinary(image, threshold);
            [regionMap, regionsNr] = Filter.regionLabelingFromBinary(binaryImage);
        end
        
        % > Parameters:
        % binaryImage - the binary image to find regions in
        % 
        % > Returns:
        % a mask with all the regions with unique integer values | the
        % number of total regions found
        function [regionMap, regionsNr] = regionLabelingFromBinary(binaryImage)
            % Create a binary image the region map.
            regionMap = zeros(size(binaryImage));
            regionsNr = 0;
            
            % Iterate over binary image.
            for i = 1 : size(regionMap, 1)
                for j = 1 : size(regionMap, 2)
                    if (binaryImage(i, j) == 1 && regionMap(i, j) == 0)
                        % If a pixel is in the foreground, but not part of
                        % a region yet, then it becomes the origin of a new
                        % region.
                        regionsNr = regionsNr + 1
                        tempMask = Filter.regionGrowingFromGrayscale(double(binaryImage), i, j, 0.5);
                        tempMask = tempMask * regionsNr;
                        regionMap = regionMap + tempMask;
                        
                        x=[regionMap(i, j-1),regionMap(i, j),regionMap(i, j+1)]
                    end
                end
            end
        end
        
        %% MORPHOLOGICAL OPERATIONS
        
        % > Parameters:
        % binaryImage - the binary image on which dilation wants to be
        % performed
        % structuringElement - the shape used to enlarge the appearance 
        %of white pixels 
        % > Returns: 
        % the dilated binaryImage 
        function dilatedImage = dilate(binaryImage, structuringElement)  
            
            [row1, col1] = size(structuringElement);
            [row2, col2] = size(binaryImage);
            dil = zeros(row2,col2); 
            data = imread(binaryImage);
            
            %iterates through binary image matrix and compares to
            %structuring element, fills new values in new matrix 'dil'
            
            for i = 1:row2
                for j = 1:col2
                    if data(i,j) == 1
                        for k = 1:row1
                            for l = 1:col1
                                if structuringElement(k,l) == 1
                                    x = i+k;
                                    y = j+l;
                                    dil(x,y) = 1;
                                end
                            end
                        end
                    end
                end
            end
            dilatedImage = dil;
        end    
    end
end

