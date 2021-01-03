classdef Misc
    %MODFLOODFILL Summary of this class goes here
    %   Detailed explanation goes here

    methods(Static)
           % skel - a skeletonized blob/label
           % startP - the starting point of a passed-in line
           % endP - the end of a passed-in line
           % pts - an array containing all seperation points
           function result = traceLine(skel, startP, endP)
               result = Misc.trace(skel, startP, endP, zeros(5,2), 0, 1);
           end
           
           function result = trace(skel, startP, endP, pts, ctr, index)
               sRow = startP(1);
               sCol = startP(2);
               eRow = endP(1);
               eCol = endP(2);
               
               if (skel(sRow, sCol) == 0)
                   result = pts;
                   return;
               end
               
               if (sRow == eRow && sCol == eCol)
                   result = pts;
                   return;
               end
               
               if (mod(ctr, 200) == 0)
                   index = index + 1;
                   pts(index, 1) = sRow;
                   pts(index, 2) = sCol;
               end
               
               skel(sRow, sCol) = 0;
                   
               Misc.trace(skel, [sRow - 1, sCol + 1], endP, pts, ctr + 1, index);
               Misc.trace(skel, [sRow + 0, sCol + 1], endP, pts, ctr + 1, index);
               Misc.trace(skel, [sRow + 1, sCol + 1], endP, pts, ctr + 1, index);
               Misc.trace(skel, [sRow - 1, sCol + 0], endP, pts, ctr + 1, index);
               Misc.trace(skel, [sRow + 1, sCol + 0], endP, pts, ctr + 1, index);
               Misc.trace(skel, [sRow - 1, sCol - 1], endP, pts, ctr + 1, index);
               Misc.trace(skel, [sRow + 0, sCol - 1], endP, pts, ctr + 1, index);
               Misc.trace(skel, [sRow + 1, sCol - 1], endP, pts, ctr + 1, index);

               result = pts;
               return; 
           end
    end
end

