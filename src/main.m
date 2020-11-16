classdef main

    methods(Static)
        function image = mainFunc(image)
            addpath('./filter');
            addpath('../assets');
%% SEGMENTIER-BILD
            
%             binaryImage = BinaryImage.imageToBinary(image);
%             h_im = imshow(image);
            
            mask = BinaryImage.imageToBinary(image);
            
            %newImage = createMask(mask, h_im);
            %newImage(:,:,2) = newImage;
            %newImage(:,:,3) = newImage(:,:,1);
            
            %ROI = image;
            %ROI(newImage == 0) = 0;
            
            subplot(2,2,1);
            imshow(mask);
            
            [labeledImage, numOfLabels] = bwlabel(mask);
            subplot(2,2,2);
            imshow(label2rgb(labeledImage));
            
            [boundaries, numberOfBoundaries]=Blobs.findBoundaries(mask);
            
            subplot(2, 2, 3);
            imshow(image);
            axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
            hold on;
            for k = 1 : numberOfBoundaries
                thisBoundary = boundaries{k};
                plot(thisBoundary(:,2), thisBoundary(:,1), 'y', 'LineWidth', 1);
            end
            hold off;
            
            blobMeasurements = regionprops(labeledImage, 'all');
            numberOfBlobs = size(blobMeasurements, 1);
            
            allBlobOrientations = [blobMeasurements.Orientation];
            allowableOrientIndexes = (allBlobOrientations > 65) ;
            keeperIndexes = find(allowableOrientIndexes);
            keeperBlobsImage = ismember(labeledImage, keeperIndexes);

%             boundingBox = regionprops(keeperBlobsImage, 'BoundingBox'); % [left_x, top_y, width, height]
%             coords = boundingBox.BoundingBox;
            
            keeperBlobsImage = repmat(keeperBlobsImage,1,1,3);
            
            keeperMask = image; % Simply a copy at first.
            keeperMask(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
            
%             keeperMask = imcrop(keeperMask, [coords(1), coords(2), coords(1)+coords(3), coords(2)+coords(4)]);
            
            subplot(2,2,4);
            imshow(keeperMask);


%% TEXTBILD - uncomment to compute skeleton for text image
%             binaryText = BinaryImage.imageToBinary(image);
%             subplot(2,2,1);
%             imshow(binaryText);
%             
%             skeletonText = bwskel(binaryText);
%             subplot(2,2,2);
%             imshow(skeletonText);
%             
%             subplot(2,2,3);
%             imshow(labeloverlay(image,skeletonText,'Transparency',0, 'Colormap', 'hot'));
            
        end
    end
end
