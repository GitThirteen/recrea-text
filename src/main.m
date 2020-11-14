classdef main

    methods(Static)
        function image = mainFunc(image)
            addpath('./filter');
            addpath('../assets');
            
            binaryImage = BinaryImage.imageToBinary(image);
            
            h_im = imshow(image);
            
            mask = BinaryImage.imageToBinary(image);
            
            %newImage = createMask(mask, h_im);
            %newImage(:,:,2) = newImage;
            %newImage(:,:,3) = newImage(:,:,1);
            
            %ROI = image;
            %ROI(newImage == 0) = 0;
            
            subplot(1,3,1);
            imshow(mask);
            
            %labeledImage = Blobs.label(binaryImage);
            subplot(1,3,2);
            %imshow(labeledImage)
            
            [boundaries, numberOfBoundaries]=Blobs.findBoundaries(binaryImage);
            
            subplot(1, 3, 3);
            imshow(image);
            axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
            hold on;
            for k = 1 : numberOfBoundaries
                thisBoundary = boundaries{k};
                plot(thisBoundary(:,2), thisBoundary(:,1), 'y', 'LineWidth', 1);
            end
            hold off;
            
            % alternative way to find and display the n-th blob:
            
%             cc = Blobs.findCC(binaryImage);
%             
%             numberOfBlobs = cc.NumObjects;
%             numberOfBlobs
%            
%             % display blob n
%             n = 1;
%             obj = zeros(size(binaryImage));
%             obj(cc.PixelIdxList{n}) = 1; 
%             subplot(3,1,3);
%             imshow(obj)
        end
    end
end
