classdef main
    methods(Static)
        %% SEGMENTIER-BILD
        function mainFunc(imageObj, imageText)
            addpath('./helpers');
            addpath('../assets');
            
            appTStart = main.trackTime(NaN, "start");

            %PRE-PROCESSING
            imageAdjusted = imadjust(imageObj, [0.3 0.7], []);
            
            %figure;
            %imshow(imageAdjusted)
            
            imageWithGauss = Filter.gaussFilter(imageAdjusted, 1, 3);
            
            figure;
            imshow(imageWithGauss);
            
            %CREATE BINARY IMAGE
            mask = Filter.imageToBinary(imageWithGauss, 0.85);
            
            figure;
            imshow(mask);
           
            %CREATE LABELED IMAGE -> need REGION GROWING instead
            [labeledImage, numOfLabels] = bwlabel(mask);
            
            %deviation array containing distance value, deviationRpw and
            %deviationColumn
            deviationsBlobs = zeros(numOfLabels, 5);  
            
            %SAVE BLOBS IN CELL ARRAY
            blobs = cell(numOfLabels, 1); % contains all blobs
            %SAVE ENDPOINTS IN ARRAY
            endpointsBlobs = zeros(numOfLabels, 4);
            areaBlobs = zeros(numOfLabels,1);
            for i = 1 : numOfLabels
                blob = labeledImage == i;
                
                img = imageObj;
                mask = repmat(blob,1,1,3);
                img(~mask) = 0;
                
                bBox = regionprops(blob, 'BoundingBox').BoundingBox;
                img = imcrop(img, bBox);
                blobs{i} = img;
                
                %skeleton & deviation from straight line
                skelblob = bwskel(blob);
                areaBlobs(i) = sum(sum(skelblob==1));

                endpoints = bwmorph(skelblob, 'endpoints');
                [r1, c1] = find(endpoints, 1, 'first'); % x, y of point A
                [r2, c2] = find(endpoints, 1, 'last');  % x, y of point B
                endpointsBlobs(i,:) = [r1,c1,r2,c2];
                
                deviationsBlobs(i,:) = Algorithms.curvature(skelblob, endpointsBlobs(i,:));
                
            end
            
            part1TEnd = main.trackTime(appTStart, 1);
%% TEXTBILD 
          
            % CREATE BINARY IMAGE
            binaryText = Filter.imageToBinary(imageText, 0.85);
            %imshow(binaryText);
            
            % CREATE SKELETON -> need SKELETONIZATION algorithm
            %skel = bwskel(binaryText, 'MinBranchLength', 40); % removes short sidebranches
            skel = Skeletonization.skeleton(binaryText);
            
            % remove branchpoints
            branchPoints = bwmorph(skel, 'branchpoints');
            %branchPoints = imdilate(branchPoints, strel('cube', 9));
            skel(branchPoints) = 0;
     
            figure;
            imshow(skel);
            
            %label single branches of skeleton
            [labeledTextSkel, numOfTextLabels] = bwlabel(skel);
            
            %colLabel = label2rgb(labeledTextSkel, 'jet', 'k');
            
            %figure;
            %imshow(colLabel);
            
            %compute deviation of skeleton from the straight line that
            %connects boths endpoints 
            % save endpoints and deviation values in arrays
            deviationsText = zeros(numOfTextLabels,5); 
            endpointsCurves = zeros(numOfTextLabels,4);
            
            for i = 1 : numOfTextLabels
                % get curve i
                curve = labeledTextSkel == i;

                % find endpoints of curve
                endpoints = bwmorph(curve, 'endpoints');
                [row1, col1] = find(endpoints, 1, 'first');
                [row2, col2] = find(endpoints, 1, 'last');
                endpointsCurves(i,:) = [row1, col1, row2, col2];
                
                % compute curvature value 
                deviationsText(i,:) = Algorithms.curvature(curve, endpointsCurves(i,:));
                
                % split curve in case it has curvature value greater than the
                % maximum curvature of the blobs (i.e. the curves with
                % biggest curvatures) 
                if deviationsText(i,1) > max(deviationsBlobs(:,1))
                
                    imgFF = Algorithms.traceLine(curve, [row1, col1], [row2, col2]);

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
            
            %figure;
            %imshow(skel);
             
            [labeledTextSkel, numOfTextLabels] = bwlabel(skel);
            
            deviationsText = zeros(numOfTextLabels, 5);
            endpointsCurves = zeros(numOfTextLabels,4);
            areaCurves = zeros(numOfTextLabels,1);
            usedBlobs = cell(numOfTextLabels, 1); % contains all used blobs;
            figure;
            for l = 1:numOfTextLabels
                
            % berechne nochmal deviation werte, weil zusätzliche kurven 
            curve = labeledTextSkel == l;
            areaCurves(l) = sum(sum(curve==1));

            % find endpoints of curve
            endpoints = bwmorph(curve, 'endpoints');
            [row1, col1] = find(endpoints, 1, 'first');
            [row2, col2] = find(endpoints, 1, 'last');
            endpointsCurves(l,:) = [row1, col1, row2, col2];

            % compute curvature value 
            deviationsText(l,:) = Algorithms.curvature(curve, endpointsCurves(l,:));
            
%             bbox = regionprops(curve, 'BoundingBox').BoundingBox;
%             curve = imcrop(curve, bbox);
            
%             subplot(2, numOfTextLabels, l)
%             imshow(curve)
            
            % suche Blob, der den (annähernd) gleichen deviation Wert aufweist
            % wie die Kurve des Branches im Text
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
            
            % find transformation factors [angle, scalingFactor]
            factors = Transform.transformFactors(closestBlob, endpointsBlobs(index,:), endpointsCurves(l,:), deviationsBlobs(index,:), deviationsText(l,:));
            
            % rotate Blob
            rotatedBlob = Transform.rotate(closestBlob, factors(1));
            
            % scale Blob
            scaledBlob = Transform.scale(rotatedBlob, factors(2));
            
            usedBlobs{l} = scaledBlob;
            
%             subplot(2,numOfTextLabels, numOfTextLabels+l)
            %imshow(scaledBlob)
            
            end
            
            part3TEnd = main.trackTime(part2TEnd, 3);
            
            % create output
            img = zeros(size(imageText));
            for i = 1 : numOfTextLabels
                inposition = zeros(size(imageText));
                blobOut = usedBlobs{i};
                curveOut = labeledTextSkel == i;
                
               % bbox = regionprops(curveOut, 'BoundingBox').BoundingBox;
%                 colLeftTop = bbox(1);
%                 rowLeftTop = bbox(2);
                
                centroid = regionprops(curveOut, 'Centroid').Centroid;

                numRowsBlob = size(blobOut,1);
                firsthalfRows = round(numRowsBlob/2);
                secondhalfRows = numRowsBlob - firsthalfRows;
                numColsBlob = size(blobOut,2);
                firsthalfCols = round(numColsBlob/2);
                secondhalfCols = numColsBlob - firsthalfCols;
                
                %img(rowLeftTop:rowLeftTop+numRowsBlob-1, colLeftTop:colLeftTop+numColsBlob-1, :) = blobOut;
                inposition(centroid(2)-firsthalfRows : centroid(2)+secondhalfRows-1, centroid(1)-firsthalfCols : centroid(1)+secondhalfCols-1, :) = blobOut;
               
                img = img + inposition;
                
                imshow(uint8(img));
                
            end
            
            figure;
            subplot(2, 2, 1);
            imshow(imageObj);
            
            subplot(2, 2, 2);
            imshow(imageText);
            
            subplot(2, 2, 3);
            finalImage = uint8(img);
            imshow(finalImage);
            
            subplot(2, 2, 4);
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
            
            imwrite(finalImage, '../output/result.jpg');
            imwrite(finalImageText, '../output/resultwithtext.jpg');
            
            main.trackTime(appTStart, "end");
        end
        
        
        function timestamp = trackTime(oldTimestamp, part)
            timestamp = datestr(now, 'HH:MM:SS');
            
            if (strcmp(part, "start"))
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