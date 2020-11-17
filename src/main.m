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

            allowableOrientIndexes = (allBlobOrientations > 65);
            keeperIndexes = find(allowableOrientIndexes);
            keeperBlobsImage = ismember(labeledImage, keeperIndexes);

            allowableIndexes = (allBlobOrientations > 65);
            keeperIndexes = find(allowableIndexes);
            keeperMask = ismember(labeledImage, keeperIndexes);
            keeperMask = bwmorph(keeperMask, 'bridge');
            
            subplot(2,2,4);
            imshow(keeperMask);

%             boundingBox = regionprops(keeperMask, 'BoundingBox'); % [left_x, top_y, width, height]
%             coords = boundingBox.BoundingBox;
            
            keeperBlobsImage = repmat(keeperMask,1,1,3);
            
            segmentedImage = image; % Simply a copy at first.
            segmentedImage(~keeperBlobsImage) = 0;  % Set all non-keeper pixels to zero.
            
%             keeperMask = imcrop(keeperMask, [coords(1), coords(2), coords(1)+coords(3), coords(2)+coords(4)]);
            
            props = regionprops(keeperMask, 'BoundingBox'); % !
            
            bBox = props.BoundingBox; % !
            keeperMask = imcrop(keeperMask, bBox); % !

%             bBox = regionprops(keeperMask, 'BoundingBox').BoundingBox;
%             points = bbox2points(bBox);
%             keeperMask = imcrop(keeperMask, points);
            
            subplot(2,2,4);
            imshow(keeperMask);
            
            imwrite(keeperMask, "../assets/segment.png");


%% TEXTBILD - uncomment to compute skeleton for text image
%             binaryText = BinaryImage.imageToBinary(image);
%             subplot(2,2,1);
%             imshow(binaryText);
%             
%             skel = bwskel(binaryText, 'MinBranchLength', 50);
%             subplot(2,2,2);
%             imshow(skel);
%             
%             branchLengths = regionprops(skel, 'Area');
%             branchLengths = [branchLengths.Area];
%  
%             subplot(2,2,4);
%             imshow(labeloverlay(image,skel,'Transparency',0, 'Colormap', 'hot'));
%             
%             
% % IMAGE REGISTRATION - versuch
% 
%             fixedOriginal = skel;
%             fixed = uint8(255 * skel);
%             movingOriginal = imread("../assets/segment.png");
%             moving = rgb2gray(movingOriginal);
% %             moving(moving ~= 0) = 1;
% %             moving = uint8(255 * moving);
%             
% %             figure;
% %             imshowpair(fixed,moving,'montage');
%             
%             [optimizer, metric] = imregconfig('multimodal');
%             
%             %optimizer = registration.optimizer.OnePlusOneEvolutionary;
%             %optimizer = registration.optimizer.RegularStepGradientDescent;
%             %optimizer.InitialRadius = optimizer.InitialRadius * 0.8;
%             %metric = registration.metric.MattesMutualInformation;
%             %metric = registration.metric.MeanSquares;
%             
%             tform = imregtform(moving, fixed, 'translation', optimizer, metric);
%             % 'rigid', 'similarity', 'translation' or 'affine'
%             registered = imregister(moving, fixed, 'translation', optimizer, metric);
%             figure;
%             imshowpair(registered, fixed);
%             
%             registeredOriginal = imwarp(movingOriginal,tform,'OutputView',imref2d(size(fixed)));
%             fusedOriginals = imfuse(registeredOriginal, fixedOriginal, 'blend');
%             figure;
%             imshow(fusedOriginals);
%              
        end
    end
end