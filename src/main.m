classdef main

    methods(Static)
        function image = mainFunc(image)
            addpath('./filter');
            addpath('../assets');
%% SEGMENTIER-BILD
            
            % CREATE BINARY IMAGE
            mask = BinaryImage.imageToBinary(image);
            
            subplot(2,2,1);
            imshow(mask);
            
            
            % CREATE LABELED IMAGE
            [labeledImage, numOfLabels] = bwlabel(mask);
            
            subplot(2,2,2);
            imshow(label2rgb(labeledImage));
            
            
            % CALCULATE BOUNDARIES OF BINARY IMAGE
%             [boundaries, numberOfBoundaries]=Blobs.findBoundaries(mask);
            
%             subplot(2, 2, 3);
%             imshow(image);
%             axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
%             hold on;
%             for k = 1 : numberOfBoundaries
%                 thisBoundary = boundaries{k};
%                 plot(thisBoundary(:,2), thisBoundary(:,1), 'y', 'LineWidth', 1);
%             end
%             hold off;
            

            % FIND RELEVANT BLOBS
            blobMeasurements = regionprops(labeledImage, 'all');
            numberOfBlobs = size(blobMeasurements, 1);
            
            allBlobOrientations = [blobMeasurements.Orientation];
            
            allowableIndexes = (allBlobOrientations > 65);
            keeperIndexes = find(allowableIndexes);
            keeperMaskOrientation = ismember(labeledImage, keeperIndexes);
            keeperLabel = bwlabel(keeperMaskOrientation);


            % KEEP ONLY BIGGEST RELEVANT BLOB
            allowableBlobsAreas = regionprops(keeperLabel, 'Area');
            allowableBlobsAreas = [allowableBlobsAreas.Area];
            biggestBlobArea = max(allowableBlobsAreas);
            keeperAreas = find(allowableBlobsAreas == biggestBlobArea);
            keeperMask = ismember(keeperLabel, keeperAreas);
            
            subplot(2,2,3);
            imshow(keeperMask);
            
            
            % USE MASK ON ORIGINAL IMAGE
            keeperBlobsImage = repmat(keeperMask,1,1,3);
            
            segImageRGB = image; % copy of original image
            segImageRGB(~keeperBlobsImage) = 0;  % set all non-keeper pixels to zero

            
            % FIND BOUNDING BOX & CROP IMAGE
            bBox = regionprops(keeperMask, 'BoundingBox').BoundingBox;
%             disp(bBox);
%             points = bbox2points(bBox);
            
            segImageRGB = imcrop(segImageRGB, bBox);
            segImageBW = imcrop(keeperMask, bBox);
            
            subplot(2,2,4);
            imshow(segImageBW);
            
            
            % SAVE CROPPED IMAGES
            imwrite(segImageRGB, "../assets/segmentOriginal.png");
            imwrite(segImageBW, "../assets/segmentBW.png");
            
            % SAVE ORIGINAL SIZE IMAGES
%             imwrite(segImageRGB, "../assets/segmentRGB.png");               
%             imwrite(keeperMask, "../assets/segment.png");


%% TEXTBILD - uncomment to compute skeleton for text image
            
%             % CREATE BINARY IMAGE
%             binaryText = BinaryImage.imageToBinary(image);
%             subplot(2,2,1);
%             imshow(binaryText);
%             
%             % CREATE SKELETON
%             skel = bwskel(binaryText, 'MinBranchLength', 50); % remove sidebranches
%             subplot(2,2,2);
%             imshow(skel);
%  
%             subplot(2,2,4);
%             imshow(labeloverlay(image,skel,'Transparency',0, 'Colormap', 'hot'));
%             
%             
% %% IMAGE REGISTRATION - uncomment to register images
% 
%             % FIXED & MOVING HAVE TO BE RGB OR GRAYSCALE IMAGES
%             fixedOriginal = skel;
%             fixed = uint8(255 * skel);
%             
%             % cropped version
%             movingOriginal = imread("../assets/segmentOriginal.png");
%             movingBW = imread("../assets/segmentBW.png");
%             movingSkel = bwskel(movingBW, 'MinBranchLength', 50);
%             moving = uint8(255 * movingSkel);
%             %moving = rgb2gray(movingOriginal);
%             
%             % uncropped version
% %             movingOriginal = imread("../assets/segmentRGB.png");
% %             movingBW = imread("../assets/segment.png");
% %             %moving = uint8(255 * movingBW);
% %             moving = rgb2gray(movingOriginal);
%             
%             
%             % CREATE REGISTRATION CONFIGURATION DATA
%             [optimizer, metric] = imregconfig('multimodal');
%             
%             % OPTIONAL ADJUSTMENTS
%             %optimizer = registration.optimizer.OnePlusOneEvolutionary;
%             %optimizer = registration.optimizer.RegularStepGradientDescent;
%             optimizer.InitialRadius = optimizer.InitialRadius * 0.8;
%             %optimizer.MaximumIterations = 300;
%             %metric = registration.metric.MattesMutualInformation;
%             %metric = registration.metric.MeanSquares;
%             
%             
%             % REGISTER IMAGES
%             % 'rigid', 'similarity', 'translation' or 'affine'
%             registered = imregister(moving, fixed, 'rigid', optimizer, metric);
%             figure;
%             imshowpair(registered, fixed);
%             
%             % CALCULATE HOW IT WAS TRANSFORMED
%             tform = imregtform(moving, fixed, 'rigid', optimizer, metric);
%             
%             % USE TRANSFORMATION ON ORIGINAL IMAGES
%             registeredOriginal = imwarp(movingOriginal,tform,'OutputView',imref2d(size(fixed)));
%             fusedOriginals = imfuse(registeredOriginal, fixedOriginal, 'blend');
%             figure;
%             imshow(fusedOriginals);
%              
        end
    end
end