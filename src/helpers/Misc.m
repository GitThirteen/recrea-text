classdef Misc
    %MODFLOODFILL Summary of this class goes here
    %   Detailed explanation goes here

    methods(Static)
           % skel - a skeletonized blob/label
           % startP - the starting point of a passed-in line
           % endP - the end of a passed-in line
           function result = modFloodFill(skel, startP, endP, counter)
               sRow = startP(1);
               sCol = startP(2);
               eRow = endP(1);
               eCol = endP(2);

               if (skel(sRow, sCol) == 0 || (sRow == eRow && sCol == eCol))
                   result = skel;
                   return;
               end
               
               if (mod(counter, 20) == 0)
                   gap = imdilate(skel(sRow, sCol), strel('cube', 9));
                   skel = skel - gap;
               end
                   
               Misc.modFloodFill(skel, [sRow - 1, sCol + 1], endP, counter + 1);
               Misc.modFloodFill(skel, [sRow + 0, sCol + 1], endP, counter + 1);
               Misc.modFloodFill(skel, [sRow + 1, sCol + 1], endP, counter + 1);
               Misc.modFloodFill(skel, [sRow - 1, sCol + 0], endP, counter + 1);
               Misc.modFloodFill(skel, [sRow + 1, sCol + 0], endP, counter + 1);
               Misc.modFloodFill(skel, [sRow - 1, sCol - 1], endP, counter + 1);
               Misc.modFloodFill(skel, [sRow + 0, sCol - 1], endP, counter + 1);
               Misc.modFloodFill(skel, [sRow + 1, sCol - 1], endP, counter + 1);

               return;
           end
     
           
           function dev = curvature(skelblob, endp1, endp2)
                
               % endp1 & endp2 are of type [row, col]
               
                numPixelsInBlob = sum(sum(skelblob==1));
                
                middlePix = skelblob ;
                middlePix(endp1) = 0;
                middlePix(endp2) = 0;
                countPix = 0 ;
                
                % entferne wiederholt die endpunkte des skeletons, damit
                % nur mehr mittleres Pixel übrig bleibt
                while countPix < numPixelsInBlob/2-2
                    endpix = bwmorph(middlePix, 'endpoints');
                    endpix1 = find(endpix, 1, 'first');
                    endpix2 = find(endpix, 1, 'last');
                    middlePix(endpix1) = 0;
                    middlePix(endpix2) = 0;
                    countPix = countPix +1;
                end
                
                %[rowsLastHalfPixels, colsLastHalfPixels] = find(skelblob, numPixelsInBlob/2 , 'last');
                [rMiddle, cMiddle] = find(middlePix==1);
                

                % berechnet Abstand der jeweiligen Pixel, die
                % in der Mitte der Kurve bzw. Vergleichsgeraden liegen.
                devX = (endp1(2) + endp2(2))/2 - (cMiddle(1));
                devY = (endp1(1) + endp2(1))/2 - (rMiddle(1));
                dev = norm([devX, devY]);
                
                return;
               
           end
    end
end

