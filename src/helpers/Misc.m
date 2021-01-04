classdef Misc
    %MODFLOODFILL Summary of this class goes here
    %   Detailed explanation goes here

    methods(Static)
           % skel - a skeletonized blob/label
           % startP - the starting point of a passed-in line
           % endP - the end of a passed-in line
           % pts - an array containing all seperation points
           function result = traceLine(skel, startP, endP)
               result = Misc.trace(skel, startP, endP, zeros(100000,2), 0, 0);
           end
           
           function result = trace(skel, startP, endP, pts, ctr, index)
               sRow = startP(1);
               sCol = startP(2);
               eRow = endP(1);
               eCol = endP(2);
               
               if (sRow == eRow && sCol == eCol)
                   result = pts(1:index, :);
                   return;
               end

               if (mod(ctr, 50) == 0)
                   index = index + 1;
                   pts(index, 1) = sRow;
                   pts(index, 2) = sCol;
               end

               skel(sRow, sCol) = 0;

               if (skel(sRow - 1, sCol + 1) ~= 0)
                   result = Misc.trace(skel, [sRow - 1, sCol + 1], endP, pts, ctr + 1, index);
                   return;
               end
               if (skel(sRow + 0, sCol + 1) ~= 0)
                   result = Misc.trace(skel, [sRow + 0, sCol + 1], endP, pts, ctr + 1, index);
                   return;
               end
               if (skel(sRow + 1, sCol + 1) ~= 0)
                   result = Misc.trace(skel, [sRow + 1, sCol + 1], endP, pts, ctr + 1, index);
                   return;
               end
               if (skel(sRow - 1, sCol + 0) ~= 0)
                   result = Misc.trace(skel, [sRow - 1, sCol + 0], endP, pts, ctr + 1, index);
                   return;
               end
               if (skel(sRow + 1, sCol + 0) ~= 0)
                   result = Misc.trace(skel, [sRow + 1, sCol + 0], endP, pts, ctr + 1, index);
                   return;
               end
               if (skel(sRow - 1, sCol - 1) ~= 0)
                   result = Misc.trace(skel, [sRow - 1, sCol - 1], endP, pts, ctr + 1, index);
                   return;
               end
               if (skel(sRow + 0, sCol - 1) ~= 0)
                   result = Misc.trace(skel, [sRow + 0, sCol - 1], endP, pts, ctr + 1, index);
                   return;
               end
               if (skel(sRow + 1, sCol - 1) ~= 0)
                   result = Misc.trace(skel, [sRow + 1, sCol - 1], endP, pts, ctr + 1, index);
                   return;
               end

               result = pts(1:index, :);
               return;
           end
     
           
           function dev = curvature(skelblob, endpoints)
                
               % endpoints of type [row1, col1, row2, col2]
               
                numPixelsInBlob = sum(sum(skelblob==1));
                
                middlePix = skelblob ;
                middlePix(endpoints(1:2)) = 0;
                middlePix(endpoints(3:4)) = 0;
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
                devCol = (endpoints(2) + endpoints(4))/2 - (cMiddle(1));
                devRow = (endpoints(1) + endpoints(3))/2 - (rMiddle(1));
          
                % 1st entry = relative distance
                % 2nd & 3rd entry = vector from middle of curve to middle
                % of line
                % 4th & 5th entry = middle point of curve
                distEndp = norm(endpoints(1:2)-endpoints(3:4));
                distToLine = norm([devRow, devCol]);
                relDist = distToLine/distEndp;
                
                dev = [relDist, devRow, devCol, rMiddle(1), cMiddle(1)];
                
                return;
               
           end
    end
end

