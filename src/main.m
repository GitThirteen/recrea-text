classdef main
    methods(Static)
        %% SEGMENTIER-BILD
        function image = mainFunc(imageObj, imageText)
            addpath('./helpers');
            addpath('../assets');

            %PRE-PROCESSING
            imageAdjusted = imadjust(imageObj, [0.3 0.7], []);
            %imageWithGauss = Filter.gaussFilter(imageAdjusted, 1, 4);
            
            %CREATE BINARY IMAGE
            mask = Filter.imageToBinary(imageAdjusted, 0.85);
            
            %subplot(2,2,1);
            figure;
            imshow(mask);
           
            %CREATE LABELED IMAGE -> need REGION GROWING instead
            [labeledImage, numOfLabels] = bwlabel(mask);
            
            %deviation array
            deviationsBlobs = zeros(1,numOfLabels); 
            
            %SAVE BLOBS IN CELL ARRAY
            blobs = cell(numOfLabels, 1); % contains all blobs
            %SAVE ENDPOINTS IN ARRAY
            endpointsBlobs = zeros(numOfLabels, 4);
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

                endpoints = bwmorph(skelblob, 'endpoints');
                [r1, c1] = find(endpoints, 1, 'first'); % x, y of point A
                [r2, c2] = find(endpoints, 1, 'last');  % x, y of point B
                endpointsBlobs(i,:) = [r1,c1,r2,c2];
                
                deviationsBlobs(i) = Misc.curvature(skelblob, [r1, c1], [r2,c2]);
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
            skel(branchPoints) = 0;
     
            %label single branches of skeleton
            [labeledTextSkel, numOfTextLabels] = bwlabel(skel);
            
            colLabel = label2rgb(labeledTextSkel, 'jet', 'k');
            
            figure;
            imshow(colLabel)
            
            %compute deviation of skeleton from straight line, that
            %connects both endpoints 
            % save endpoints and deviation values in arrays
            deviationsText = zeros(numOfTextLabels); 
            endpointsCurves = zeros(numOfTextLabels,4);
            for i = 1 : numOfTextLabels
                curve = labeledTextSkel == i;

                endpoints = bwmorph(curve, 'endpoints');
                [row1, col1] = find(endpoints, 1, 'first');
                [row2, col2] = find(endpoints, 1, 'last');
                imgFF = Misc.traceLine(curve, [row1, col1], [row2, col2]);
                figure;
                
                for j = 1 : length(imgFF)
                    row = imgFF(j, 1);
                    col = imgFF(j, 2);
                    
                    skel = imdilate(skel(row, col), strel('cube', 9));
                end
                
                imshow(skel);
                
                imshow(imgFF);
                %steigung = (row2-row1)/(col2-col1);
                
                % dieser Part findet noch nicht das richtige Pixel in der
                % Mitte der Kurve
                numPixelsInCurve = int16(sum(sum(curve==1)));
                
                [rowsLastHalfPixelsCurve, colsLastHalfPixelsCurve] = find(curve, numPixelsInCurve/2 , 'last');
                rowMiddle = rowsLastHalfPixelsCurve(1);
                colMiddle = colsLastHalfPixelsCurve(1);
                
                endpointsCurve = bwmorph(curve, 'endpoints');
                [row1, col1] = find(endpointsCurve, 1, 'first');
                [row2, col2] = find(endpointsCurve, 1, 'last');
                endpointsCurves(i,:) = [row1, col1, row2, col2];
               % imgFF = Misc.modFloodFill(curve, [row1, col1], [row2, col2], 0);
               % figure;
               % imshow(imgFF);
               
                deviationsText(i) = Misc.curvature(curve, [row1, col1], [row2, col2]);   
            end
            
            figure;
            for l = 1:numOfTextLabels
            % suche Blob, der den (annähernd) gleichen deviation Wert aufweist
            % wie die Kurve des Branches im Text
            TextDev = deviationsText(l);
            minDiff = 100000;
            closestBlob = zeros(2);
            index = 0;
            for k=1:length(blobs)
                difference = abs(TextDev) - abs(deviationsBlobs(k));
                if abs(difference) < minDiff
                    minDiff = abs(difference);
                    closestBlob = blobs{k};
                    index = k;
                end
            end
            
            % rotiere den gefundenen Blob
            rotatedBlob = Transform.rotate(closestBlob, endpointsBlobs(index,:), endpointsCurves(l,:), deviationsBlobs(index), TextDev);
            
            subplot(2,numOfTextLabels,l)
            imshow(rotatedBlob)
            
            end
        
            
            
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