classdef main
    methods(Static)
        %% SEGMENTIER-BILD
        function image = mainFunc(imageObj, imageText)
            disp("start at: " + datestr(now, 'HH:MM:SS.FFF'));
            addpath('./helpers');
            addpath('../assets');

            %PRE-PROCESSING
            imageAdjusted = imadjust(imageObj, [0.3 0.7], []);
            %imageWithGauss = Filter.gaussFilter(imageAdjusted, 1, 4);
            
            %CREATE BINARY IMAGE
            mask = Filter.imageToBinary(imageAdjusted, 0.85);
            
            figure;
            imshow(mask);
           
            %CREATE LABELED IMAGE -> need REGION GROWING instead
            [labeledImage, numOfLabels] = bwlabel(mask);
            
            %deviation array containing distance value, deviationRpw and
            %deviationColumn
            deviationsBlobs = zeros(numOfLabels,5);  
            
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
                
                deviationsBlobs(i,:) = Misc.curvature(skelblob, endpointsBlobs(i,:));
            end
            disp("end part 1 at: " + datestr(now, 'HH:MM:SS.FFF'));
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
            
            %colLabel = label2rgb(labeledTextSkel, 'jet', 'k');
            
            %figure;
            %imshow(colLabel);
            
            %compute deviation of skeleton from straight line, that
            %connects both endpoints 
            % save endpoints and deviation values in arrays
            deviationsText = zeros(numOfTextLabels,5); 
            endpointsCurves = zeros(numOfTextLabels,4);
            areaCurves = zeros(numOfTextLabels,1);
            figure;
            
            for i = 1 : numOfTextLabels
                curve = labeledTextSkel == i;
                areaCurves(i) = sum(sum(curve==1));

                endpoints = bwmorph(curve, 'endpoints');
                [row1, col1] = find(endpoints, 1, 'first');
                [row2, col2] = find(endpoints, 1, 'last');
                endpointsCurves(i,:) = [row1, col1, row2, col2];
                
                % Segmentation of remaining lines 
                deviationsText(i,:) = Misc.curvature(curve, endpointsCurves(i,:));
                
                if deviationsText(i,1) > max(deviationsBlobs(:,1))            
                    imgFF = Misc.traceLine(curve, [row1, col1], [row2, col2]);

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
                %imshow(skel);

                
%                 bbox = regionprops(curve, 'BoundingBox').BoundingBox;
%                 curve = imcrop(curve, bbox);
                
                %subplot(2,numOfTextLabels, i)
                %imshow(curve);
            end
            disp("end part 2 at: " + datestr(now, 'HH:MM:SS.FFF'));
            
            figure;
            imshow(skel);
            
            %extract all blobs in text image TODO!!!!
            
            usedBlobs = cell(numOfTextLabels, 1); % contains all used blobs;
            for l = 1:numOfTextLabels
            % suche Blob, der den (annähernd) gleichen deviation Wert aufweist
            % wie die Kurve des Branches im Text
            TextDev = deviationsText(l,1);
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
            
 
            % rotate Blob
            rotatedBlob = Transform.rotate(closestBlob, endpointsBlobs(index,:), endpointsCurves(l,:), deviationsBlobs(index,:), deviationsText(l,:));
            
            % scale Blob
            scaledBlob = Transform.scaling(rotatedBlob, areaBlobs(index), areaCurves(l));
            
            usedBlobs{l} = scaledBlob;
            
            %subplot(2,numOfTextLabels, numOfTextLabels+l)
            %imshow(scaledBlob)
            end
            disp("end part 3 at: " + datestr(now, 'HH:MM:SS.FFF'));
            
            % make output image 
            % ...
            
          
            %% other things (?) 
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