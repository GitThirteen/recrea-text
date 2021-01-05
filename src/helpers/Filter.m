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
    end
end

