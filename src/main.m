classdef main

    methods(Static)
        function image = mainFunc(image) % need : mainFunc(imSegments, imText)
            addpath('./filter');
            addpath('../assets');
%% SEGMENTIER-BILD

            %PRE-PROCESSING
            imageAdjusted = imadjust(image, [0.3 0.7], []);
            imageWithGauss = GaussFilter.gauss(imageAdjusted, 7);
            
            %CREATE BINARY IMAGE
            mask = BinaryImage.imageToBinary(imageWithGauss);
            
            %subplot(2,2,1);
            imshow(mask);
            
            %CREATE LABELED IMAGE -> need REGION GROWING instead
            [labeledImage, numOfLabels] = bwlabel(mask);
            
            %deviation array
            deviationsBlobs = zeros(1,numOfLabels); 
            
            %SAVE BLOBS IN CELL ARRAY
            blobs = cell(numOfLabels, 1); % contains all blobs
            for i = 1 : numOfLabels
                blob = labeledImage == i;
                
                img = image;
                mask = repmat(blob,1,1,3);
                img(~mask) = 0;
                
                bBox = regionprops(blob, 'BoundingBox').BoundingBox;
                img = imcrop(img, bBox);
                blobs{i} = img;
                
                %skeleton & deviation from straight line 
                skelblob = bwskel(blob);

                endpointsBlob = bwmorph(skelblob, 'endpoints');
                [r1, c1] = find(endpointsBlob,1, 'first');
                [r2, c2] = find(endpointsBlob,1, 'last');
                %steigungBlob = (r2-r1)/(c2-c1);

                numPixelsInBlob = int16(sum(sum(skelblob==1)));
                [rowsLastHalfPixels, colsLastHalfPixels] = find(skelblob, numPixelsInBlob/2 , 'last');
                rMiddle = rowsLastHalfPixels(1);
                cMiddle = colsLastHalfPixels(1);

                % berechnet vorerest nur Abstand der jeweiligen Pixel, die
                % in der Mitte der Kurve bzw. Vergleichsgeraden liegen.
                devX = (c1+c2)/2 - (cMiddle) ;
                devY = (r1+r2)/2 - (rMiddle);
                dev = norm([devX, devY]);
                deviationsBlobs(i) = dev;
            end
         
            % provisorisch - kann sonst nicht auf die Werte zugreifen, wenn
            % der Teil auskommentiert ist
            writecell(blobs, 'blobscell.dat');
            writematrix(deviationsBlobs, 'deviationsBlobs.dat');
            
%% TEXTBILD - uncomment to compute skeleton for text image
            
%             % CREATE BINARY IMAGE
%             binaryText = BinaryImage.imageToBinary(image);
%             %imshow(binaryText);
%             
%             % CREATE SKELETON -> need SKELETONIZATION algorithm
%             skel = bwskel(binaryText, 'MinBranchLength', 40); % removes short sidebranches
%             
%             % remove branchpoints
%             branchPoints = bwmorph(skel, 'branchpoints');
%             branchPoints = imdilate(branchPoints, strel('cube', 9));
%             skel = skel - branchPoints;
%             %endPoints = bwmorph(skel, 'endpoints'); 
%             
%             %label single branches of skeleton
%             [labeledTextSkel, numOfTextLabels] = bwlabel(skel);
%             
%       % FEHLER KÖNNTE HIER LIEGEN
%             blobs = readcell('blobscell.dat');
%             deviationsBlobs = readmatrix('deviationsBlobs.dat');
%             
%             %compute deviation of skeleton from straight line connecting
%             %both endpoints & saving value in array.
%             deviationsText = zeros(numOfTextLabels); 
%             for i = 1 : numOfTextLabels
%                 curve = labeledTextSkel == i;
%                 
%                 endpoints = bwmorph(curve, 'endpoints');
%                 [row1, col1] = find(endpoints,1, 'first');
%                 [row2, col2] = find(endpoints,1, 'last');
%                 %steigung = (row2-row1)/(col2-col1);
%                 
%                 numPixelsInCurve = int16(sum(curve(:)));
%                 lastHalfPixelsInCurve = find(curve, numPixelsInCurve/2, 'last');
%                 [rowMiddle, colMiddle] = find(lastHalfPixelsInCurve, 1, 'first');
%                 
%                 % berechnet vorerest nur Abstand der jeweiligen Pixel, die
%                 % in der Mitte der Kurve bzw. Vergleichsgeraden liegen.
%                 deviationX = (col1+col2)/2 - (colMiddle) ;
%                 deviationY = (row1 + row2)/2 - (rowMiddle);
%                 deviation = norm([deviationX, deviationY]);
%                 deviationsText(i) = deviation;
%         
%             end
%             
%             % suche Blob, der den (annähernd) gleichen deviation Wert aufweist
%             % wie die Kurve des Branches im Text
%             firstTextDev = deviationsText(1);
%             minDiff = 10000;
%             closestBlob = zeros(2);
%             for k=1:length(blobs)
%                 difference = firstTextDev - deviationsBlobs(k);
%                 if difference < minDiff
%                     closestBlob = blobs{k};
%                 end
%             end
%             
%             imshowpair(closestBlob, image)
            
%             %firstEndPoint = find(endPoints, 1, 'first');
%             %[width, height, depth] = size(skel);
%             %fx = mod(firstEndPoint, width);
%             %fy = firstEndPoint / width;
%             
%             %skel = skel - branchPoints - endPoints;
            
%             % REVERSE FLOOD-FILL
%             %skel = revFloodFill(skel, fx, fy, 1, 0.5);
%             %subplot(2,2,2);
%             imshow(skel);
%  
%             %subplot(2,2,4);
%             %imshow(labeloverlay(image, skel, 'Transparency', 0, 'Colormap', 'hot'));
%             
%        end
%         
%         % 
%         function skel = revFloodFill(skel, x, y, targetColor, replColor)
%             if (targetColor == replColor)
%                 return;
%             elseif (skel(x, y) ~= targetColor)
%                 return;
%             else
%                 skel(x, y) = replColor;
%             end
%             
%             revFloodFill(skel, x - 1, y - 1, targetColor, replColor);
%             revFloodFill(skel, x, y - 1, targetColor, replColor);
%             revFloodFill(skel, x + 1, y - 1, targetColor, replColor);
%             revFloodFill(skel, x + 1, y, targetColor, replColor);
%             revFloodFill(skel, x + 1, y + 1, targetColor, replColor);
%             revFloodFill(skel, x, y + 1, targetColor, replColor);
%             revFloodFill(skel, x - 1, y + 1, targetColor, replColor);
%             revFloodFill(skel, x - 1, y, targetColor, replColor);
%             
%             skel = skel;
%             return;
         end
     end
end