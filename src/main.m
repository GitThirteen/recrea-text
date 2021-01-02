classdef main
    methods(Static)
        %% SEGMENTIER-BILD
        function image = mainFunc(imageObj, imageText)
            addpath('./helpers');
            addpath('../assets');

            %PRE-PROCESSING
            imageAdjusted = imadjust(imageObj, [0.3 0.7], []);
            imageWithGauss = Filter.gaussFilter(imageAdjusted, 7);
            
            %CREATE BINARY IMAGE
            mask = Filter.imageToBinary(imageWithGauss, 0.85);
            
            %subplot(2,2,1);
            figure;
            imshow(mask);
           
            %CREATE LABELED IMAGE -> need REGION GROWING instead
            [labeledImage, numOfLabels] = bwlabel(mask);
            
            %deviation array
            deviationsBlobs = zeros(1,numOfLabels); 
            
            %SAVE BLOBS IN CELL ARRAY
            blobs = cell(numOfLabels, 1); % contains all blobs
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

                endpointsBlob = bwmorph(skelblob, 'endpoints');
                [r1, c1] = find(endpointsBlob, 1, 'first'); % x, y of point A
                [r2, c2] = find(endpointsBlob, 1, 'last');  % x, y of point B
                %steigungBlob = (r2-r1)/(c2-c1);

                % dieser Part findet noch nicht das richtige Pixel in der
                % Mitte der Kurve
                numPixelsInBlob = int16(sum(sum(skelblob==1)));
                [rowsLastHalfPixels, colsLastHalfPixels] = find(skelblob, numPixelsInBlob/2 , 'last');
                rMiddle = rowsLastHalfPixels(1);
                cMiddle = colsLastHalfPixels(1);

                % berechnet vorerest nur Abstand der jeweiligen Pixel, die
                % in der Mitte der Kurve bzw. Vergleichsgeraden liegen.
                devX = (c1+c2)/2 - (cMiddle);
                devY = (r1+r2)/2 - (rMiddle);
                dev = norm([devX, devY]);
                deviationsBlobs(i) = dev;
            end
            
%% TEXTBILD 
          
            % CREATE BINARY IMAGE
            binaryText = Filter.imageToBinary(imageText, 0.85);
            %imshow(binaryText);
            
            % CREATE SKELETON -> need SKELETONIZATION algorithm
            skel = bwskel(binaryText, 'MinBranchLength', 40); % removes short sidebranches
            
            % remove branchpoints
            branchPoints = bwmorph(skel, 'branchpoints');
            branchPoints = imdilate(branchPoints, strel('cube', 9));
            skel = skel - branchPoints;
            %endPoints = bwmorph(skel, 'endpoints');
            
            %label single branches of skeleton
            [labeledTextSkel, numOfTextLabels] = bwlabel(skel);
            
            colLabel = label2rgb(labeledTextSkel, 'jet', 'k');
            
            figure;
            imshow(colLabel)
            
            %compute deviation of skeleton from straight line connecting
            %both endpoints & saving value in array.
            deviationsText = zeros(numOfTextLabels); 
            for i = 1 : numOfTextLabels
                curve = labeledTextSkel == i;
                
                endpoints = bwmorph(curve, 'endpoints');
                [row1, col1] = find(endpoints, 1, 'first');
                [row2, col2] = find(endpoints, 1, 'last');
               % imgFF = Misc.modFloodFill(curve, [row1, col1], [row2, col2], 0);
               % figure;
               % imshow(imgFF);
                %steigung = (row2-row1)/(col2-col1);
                
                % dieser Part findet noch nicht das richtige Pixel in der
                % Mitte der Kurve
                numPixelsInCurve = int16(sum(sum(curve==1)));
                
                [rowsLastHalfPixelsCurve, colsLastHalfPixelsCurve] = find(curve, numPixelsInCurve/2 , 'last');
                rowMiddle = rowsLastHalfPixelsCurve(1);
                colMiddle = colsLastHalfPixelsCurve(1);
                
                % berechnet vorerest nur Abstand der jeweiligen Pixel, die
                % in der Mitte der Kurve bzw. Vergleichsgeraden liegen.
                deviationX = (col1+col2)/2 - (colMiddle) ;
                deviationY = (row1 + row2)/2 - (rowMiddle);
                deviation = norm([deviationX, deviationY]);
                deviationsText(i) = deviation;         
            end
            
            % suche Blob, der den (annähernd) gleichen deviation Wert aufweist
            % wie die Kurve des Branches im Text
            fifthTextDev = deviationsText(5);
            minDiff = 100000;
            closestBlob = zeros(2);
            for k=1:length(blobs)
                difference = abs(fifthTextDev) - abs(deviationsBlobs(k));
                if abs(difference) < minDiff
                    minDiff = abs(difference);
                    closestBlob = blobs{k};
                end
            end
            
            toBeMatched = (labeledTextSkel == 5);
            
            figure;
            subplot(1,2,1)
            imshow(closestBlob)
            subplot(1,2,2)
            imshow(toBeMatched)
            
            %firstEndPoint = find(endPoints, 1, 'first');
            %[width, height, depth] = size(skel);
            %fx = mod(firstEndPoint, width);
            %fy = firstEndPoint / width;
            
            %skel = skel - branchPoints - endPoints;
            
            % REVERSE FLOOD-FILL
            %skel = revFloodFill(skel, fx, fy, 1, 0.5);
            %subplot(2,2,2);
            %imshow(skel);
 
            %subplot(2,2,4);
            %imshow(labeloverlay(image, skel, 'Transparency', 0, 'Colormap', 'hot'));
            
        end   
     end
end