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
                   
               modFloodFill(skel, [sRow - 1, sCol + 1], endP, counter + 1);
               modFloodFill(skel, [sRow + 0, sCol + 1], endP, counter + 1);
               modFloodFill(skel, [sRow + 1, sCol + 1], endP, counter + 1);
               modFloodFill(skel, [sRow - 1, sCol + 0], endP, counter + 1);
               modFloodFill(skel, [sRow + 1, sCol + 0], endP, counter + 1);
               modFloodFill(skel, [sRow - 1, sCol - 1], endP, counter + 1);
               modFloodFill(skel, [sRow + 0, sCol - 1], endP, counter + 1);
               modFloodFill(skel, [sRow + 1, sCol - 1], endP, counter + 1);

               return;
           end
    end
end

