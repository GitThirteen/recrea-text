classdef main
    % MAIN
    % Main part of the RecreaText program
    % to start, run RecreaText.mlapp
    %
    % Functions:
    % > mainFunc(imageObj, imageText)
    % > Author: Multiple
    % Main entry point of this program, runs all needed functions and
    % calculations and saves the output image in ../output.
    %
    % Disclaimer: UNCOMMENT line 101 and COMMENT line 102 if you want to
    %             use Matlab's skeletonization which might work better 
    %             with certain images
    %
    % > trackTime(oldTimestamp, part)
    % > Author: Michael Eickmeyer
    % Calculates the difference between 2 timestamps and displays it
    % (amongst other information like the current time) in the console.
    % Furthermore, tracks how long the program takes to generate an output
    % image.
    
    methods(Static)
        %% MAIN FUNCTION
        
        % > Parameters:
        % imageObj - an image containing segmentable objects
        % imageText - an image containing text
        function mainFunc(imageObj, imageText)
            addpath('./helpers');
            addpath('../assets');
            
            appTStart = main.trackTime(NaN, "start");
            %% PART 1: OBJECT IMAGE

            % PRE-PROCESSING (increase contrast, filter with gauß)
            imageAdjusted = imadjust(imageObj, [0.3 0.7], []);

            imageWithGauss = Filter.gaussFilter(imageAdjusted, 1, 3);
            
            % CREATE BINARY IMAGE
            mask = Filter.imageToBinary(imageWithGauss, 0.85);
            %figure;
            %imshow(mask);
           
            % SEGMENT IMAGE (Region Growing) & LABEL IMAGE
            [labeledImage, numOfLabels] = bwlabel(mask);
            %[labeledImage, numOfLabels] = Filter.regionLabeling(imageWithGauss, 0.85);
            %figure;
            %imshow(labeledImage);
            
            % EXTRACT BLOBS & THEIR PROPERTIES FROM LABELED IMAGE
            % (save each blob (=segmented object) separately in cell array)
            % (find out curvature properties of blobs)
            
            % array for saving curvature properties
            % distance value, deviationRow and deviationColumn
            deviationsBlobs = zeros(numOfLabels, 5);  
            % cell array for saving all blobs
            blobs = cell(numOfLabels, 1); 
            % array for saving endpoints of blobs
            endpointsBlobs = zeros(numOfLabels, 4);
            
            % loop over all existing object-blobs
            for i = 1 : numOfLabels
                
                % find blob with label i
                blob = labeledImage == i;
                
                % extract blob from imageObj
                img = imageObj;
                mask = repmat(blob,1,1,3);
                img(~mask) = 0;
                
                % compute bounding box, crop blob & save in cell array
                bBox = regionprops(blob, 'BoundingBox').BoundingBox;
                img = imcrop(img, bBox);
                blobs{i} = img;
                
                % compute skeleton & find its endpoints
                skelblob = bwskel(blob);
                % skelblob = Skeletonization.skeleton(skelblob);
                
                endpoints = bwmorph(skelblob, 'endpoints');
                [r1, c1] = find(endpoints, 1, 'first'); % x, y of point A
                [r2, c2] = find(endpoints, 1, 'last');  % x, y of point B
                endpointsBlobs(i,:) = [r1,c1,r2,c2];
                
                % compute curvature properties
                deviationsBlobs(i,:) = Algorithms.curvature(skelblob, endpointsBlobs(i,:));
                
            end

            part1TEnd = main.trackTime(appTStart, 1);
            %% PART 2: TEXT IMAGE
          
            % CREATE BINARY IMAGE
            binaryText = Filter.imageToBinary(imageText, 0.85);
            
            % CREATE SKELETON & REMOVE BRANCHPOINTS
            %skel = bwskel(binaryText, 'MinBranchLength', 40);
            skel = Skeletonization.skeleton(binaryText);
            
            % remove branchpoints
            branchPoints = zeros(size(skel));
            branchPointArray = Algorithms.findBranchpoints(skel);
            
            if (size(branchPointArray, 1) > 0)
                for i = 1 : size(branchPointArray, 1)
                    row = branchPointArray(i, 1);
                    col = branchPointArray(i, 2);

                    branchPoints(row, col) = 1;
                end
            end
            
            bp = imdilate(branchPoints, strel('cube', 9));
            skel(bp == 1) = 0;
            
            % SEGMENT IMAGE (Region Growing) & LABEL IMAGE
            [labeledTextSkel, numOfTextLabels] = bwlabel(skel);
            %[labeledTextSkel, numOfTextLabels] = Filter.regionLabeling(skel);
            
            % arrays for saving curvature properties and endpoints of skeleton
            deviationsText = zeros(numOfTextLabels,5); 
            endpointsCurves = zeros(numOfTextLabels,4);
            
            % loop over all existing text-blobs
            for i = 1 : numOfTextLabels
                
                % find curve (=blob) with label i
                curve = labeledTextSkel == i;

                % find endpoints of curve
                endpoints = bwmorph(curve, 'endpoints');
                [row1, col1] = find(endpoints, 1, 'first');
                [row2, col2] = find(endpoints, 1, 'last');
                endpointsCurves(i,:) = [row1, col1, row2, col2];
                
                % compute curvature properties 
                deviationsText(i,:) = Algorithms.curvature(curve, endpointsCurves(i,:));
                
                % in case it has curvature value greater than the
                % maximum curvature of the blobs (which means, that it
                % cannot be properly reconstructed by an object-blob), the
                % curve is split up
                if deviationsText(i,1) > max(deviationsBlobs(:,1))
                
                    imgFF = Algorithms.traceLine(curve, [row1, col1], [row2, col2], "default");

                    if (size(imgFF, 1) > 0)
                        for j = 1 : size(imgFF, 1)
                            row = imgFF(j, 1);
                            col = imgFF(j, 2);

                            mask = false(size(skel));
                            mask(row, col) = 1;
                            pt = imdilate(mask, strel('cube', 9));
                            skel(pt) = 0;
                        end
                    end 
                end
            end

            part2TEnd = main.trackTime(part1TEnd, 2);
            %% PART 3: MATCH OBJECT-BLOBS & TEXT-BLOBS 
            % FIRST: REPEAT PREVIOUS LOOP 
            % because there might be more curves in the text-skeleton now, 
            % in case some were split up
   
            [labeledTextSkel, numOfTextLabels] = bwlabel(skel);
            
            deviationsText = zeros(numOfTextLabels, 5);
            endpointsCurves = zeros(numOfTextLabels,4);
            usedBlobs = cell(numOfTextLabels, 1); % contains all used blobs;
          
            % loop over all text blobs (incl. the new ones)
            for l = 1:numOfTextLabels  
                
                curve = labeledTextSkel == l;

                % find endpoints of curve
                endpoints = bwmorph(curve, 'endpoints');
                [row1, col1] = find(endpoints, 1, 'first');
                [row2, col2] = find(endpoints, 1, 'last');
                endpointsCurves(l,:) = [row1, col1, row2, col2];

                % compute curvature properties 
                deviationsText(l,:) = Algorithms.curvature(curve, endpointsCurves(l,:));

                % FIND OBJECT-BLOB THAT IS THE BEST MATCH FOR TEXT-BLOB(CURVE)
   
                % compare curvature properties
                % find the blob with minimal difference of curvature value
                TextDev = deviationsText(l,1);
                minDiff = 1000000;
                closestBlob = zeros(2);
                index = 1;
                for k=1:length(blobs)
                    difference = abs(TextDev) - abs(deviationsBlobs(k));
                    if abs(difference) < minDiff
                        minDiff = abs(difference);
                        closestBlob = blobs{k};
                        index = k;
                    end
                end

                % TRANSFORM BLOB ACCORDING TO LOCATION OF TEXT-CURVE
    
                % find transformation factors [angle, scalingFactor]
                factors = Transform.transformFactors(endpointsBlobs(index,:), endpointsCurves(l,:), deviationsBlobs(index,:), deviationsText(l,:));

                % rotate & scale
                rotatedBlob = Transform.rotate(closestBlob, factors(1));
                scaledBlob = Transform.scale(rotatedBlob, factors(2));

                % save transformed blob in cell array
                usedBlobs{l} = scaledBlob;
            
            end
         
            main.trackTime(part2TEnd, 3); % end part 3 
            %% CREATE OUTPUT            
            
            img = zeros(size(imageText));
            for i = 1 : numOfTextLabels
                % create temporary image with original size  for each blob
                % & locate the blob at correct position
                inposition = zeros(size(imageText));
                blobOut = usedBlobs{i};
                curveOut = labeledTextSkel == i;
                
                % find centroid for positioning the center of the
                % object-blob at the center of the text-blob
                % (in order to avoid big shifts)
                centroid = regionprops(curveOut, 'Centroid').Centroid;

                numRowsBlob = size(blobOut,1);
                firsthalfRows = uint16(round(numRowsBlob/2));
                numColsBlob = size(blobOut,2);
                firsthalfCols = uint16(round(numColsBlob/2));
                
                beginRow = centroid(2)-firsthalfRows;
                endRow = beginRow + numRowsBlob-1;
                beginCol = centroid(1)-firsthalfCols;
                endCol = beginCol + numColsBlob-1;
                
                a = 1;
                b = 1;
                
                % case: blob indices outside the image boundaries on the 
                % top or left
                if beginRow <1
                    a = a + abs(beginRow)+1;
                    beginRow = 1;
                end
                if beginCol <1
                    b = b + abs(beginCol)+1;
                    beginCol = 1;
                end
                
                inposition( beginRow : endRow, beginCol : endCol, :) = blobOut(a:end,b:end,:);
               
                % add temporary image to output image
                % (background pixels with value 0 don't affect already
                % existing nonzero pixels -> no overlap of
                % blob-backgrounds)
                % case: part of the positioned blob-image lies outside
                % the image size on the right or bottom, 
                % inposition is cropped to the original size before adding
                img = img + inposition(1:size(img,1), 1:size(img,2),:);
             
            end
            
            % DISPLAY INPUT IMAGES
            figure('Name', 'Input Images');
            subplot(1, 2, 1);
            imshow(imageObj);
            
            subplot(1, 2, 2);
            imshow(imageText);
            
            % DISPLAY FINAL IMAGE
            figure('Name', 'Output Images');
            subplot(1, 2, 1);
            finalImage = uint8(img);
            imshow(finalImage);
            
            % DISPLAY OVERLAY IMAGE (FINAL & ORIGINAL TEXT)
            subplot(1, 2, 2);
            finalImageText = imageText;
            tempImage = rgb2gray(img);
            
            for x = 1 : size(finalImageText, 1)
                for y = 1 : size(finalImageText, 2)
                    if (tempImage(x, y) ~= 0)
                        finalImageText(x, y, :) = img(x, y, :);
                    end
                end
            end
            imshow(finalImageText);
            
            % SAVE OUTPUT AS FILE
            imwrite(finalImage, '../output/result.jpg');
            imwrite(finalImageText, '../output/resultwithtext.jpg');

            main.trackTime(appTStart, "end");
        end
        
        %% TIMING FUNCTION
        
        % > Parameters
        % oldTimestamp - a (preferably) old timestamp for calculating the time a certain process took to complete
        % part - a name or number of whichever part got completed, type "start" or "end" to get a special start or end message
        %
        % > Returns
        % a timestamp which can be used for further calculations
        function timestamp = trackTime(oldTimestamp, part)
            timestamp = datestr(now, 'HH:MM:SS');
            
            if (strcmp(part, "start"))
                disp("----------------");
                disp("Application started at: " + timestamp);
            elseif (strcmp(part, "end"))
                diff = (datenum(timestamp) - datenum(oldTimestamp)) * 24 * 60 * 60;
                disp("Application ended at: " + timestamp);
                disp("Duration: " + diff + "s");
            else
                diff = (datenum(timestamp) - datenum(oldTimestamp)) * 24 * 60 * 60;
                disp("Finished Part " + part + " at: " + timestamp + " (" + diff + "s)");
            end
        end
    end
end