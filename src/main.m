classdef main

    methods(Static)
        function image = mainFunc(image)
            addpath('./filter');
            addpath('../assets');
%% SEGMENTIER-BILD
            % CREATE BINARY IMAGE
            image = imadjust(image, [0.3 0.7], []);
            imageWithGauss = GaussFilter.gauss(image, 7);
            mask = BinaryImage.imageToBinary(imageWithGauss);
            
            %subplot(2,2,1);
            imshow(mask);
            
            % CREATE LABELED IMAGE
            [labeledImage, numOfLabels] = bwlabel(mask);
            
            % SAVE BLOBS IN ARRAY
            blobs = cell(numOfLabels, 1); % contains all blobs
            for i = 1 : numOfLabels
                blob = labeledImage == i;
                
                img = image;
                mask = repmat(blob,1,1,3);
                img(~mask) = 0;
                
                bBox = regionprops(blob, 'BoundingBox').BoundingBox;
                img = imcrop(img, bBox);
                blobs{i} = img;
            end
            
%% TEXTBILD - uncomment to compute skeleton for text image
            
            % CREATE BINARY IMAGE
            binaryText = BinaryImage.imageToBinary(image);
            %subplot(2,2,1);
            %imshow(binaryText);
            
            % CREATE SKELETON
            skel = bwskel(binaryText, 'MinBranchLength', 40); % remove sidebranches (todo?)
            branchPoints = bwmorph(skel, 'branchpoints');
            branchPoints = imdilate(branchPoints, strel('cube', 9));
            %endPoints = bwmorph(skel, 'endpoints');
            
            %firstEndPoint = find(endPoints, 1, 'first');
            %[width, height, depth] = size(skel);
            %fx = mod(firstEndPoint, width);
            %fy = firstEndPoint / width;
            
            %skel = skel - branchPoints - endPoints;
            skel = skel - branchPoints;
            % REVERSE FLOOD-FILL
            %skel = revFloodFill(skel, fx, fy, 1, 0.5);
            %subplot(2,2,2);
            imshow(skel);
 
            %subplot(2,2,4);
            %imshow(labeloverlay(image, skel, 'Transparency', 0, 'Colormap', 'hot'));
            
            
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
        end
        
        % 
        function skel = revFloodFill(skel, x, y, targetColor, replColor)
            if (targetColor == replColor)
                return;
            elseif (skel(x, y) ~= targetColor)
                return;
            else
                skel(x, y) = replColor;
            end
            
            revFloodFill(skel, x - 1, y - 1, targetColor, replColor);
            revFloodFill(skel, x, y - 1, targetColor, replColor);
            revFloodFill(skel, x + 1, y - 1, targetColor, replColor);
            revFloodFill(skel, x + 1, y, targetColor, replColor);
            revFloodFill(skel, x + 1, y + 1, targetColor, replColor);
            revFloodFill(skel, x, y + 1, targetColor, replColor);
            revFloodFill(skel, x - 1, y + 1, targetColor, replColor);
            revFloodFill(skel, x - 1, y, targetColor, replColor);
            
            skel = skel;
            return;
        end
    end
end