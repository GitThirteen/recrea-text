classdef Algorithms
    % ALGORITHMS
    % A class containing useful algorithms necessary for the main file to
    % run.
    %
    % Functions:
    % > traceLine(skel, startP, endP, mode)
    % > Author: Michael Eickmeyer
    % A jumper function for trace(). Inputs different default values based
    % on the <mode> parameter. Alternatively, trace() can be called
    % directly to specify further details.
    %
    % > trace(skel, startP, endP, pts, ctr, index, threshold)
    % > Author: Michael Eickmeyer
    % A modified flood-fill algorithm used for tracing the line of a 
    % specified skeleton. Starts at <startP> and checks every direction 
    % (8-connectivity) if it contains a 1. If that's the case, it
    % continues until either <endP> is reached or no other 1 is found. 
    % Returns an N x 2 matrix containing the coordinates with the
    % interval/steps of the <threshold> parameter.
    %
    % > curvature(skel, endpoints)
    % > Author: Silke Buchberger
    % Determines a value describing the curvature of the given skeleton <skel>. It uses
    % traceLine() to find the middle of the skeleton and computes the
    % distance from the middle of the skeleton to the middle of the
    % straight line connecting the skeleton's endpoints. The curvature
    % value is the relation of these distances.
    % Returns a 1 x 5 array containing the curvature value, the offset
    % between the middle points and the middle point of the skeleton. The
    % last 4 values of the returned array will be important for determining
    % the rotation angle. (see Transform.m)
    %
    % > findBranchpoints(skel)
    % > Author: Michael Eickmeyer
    % Determines all branchpoints in a binary image (skeleton) by looping
    % through the entire image provided through the <skel> parameter.
    % 
    % > isBranchpoint(skel, row, col)
    % > Author: Michael Eickmeyer
    % Helper function for findBranchpoints(). Runs through all pixels
    % around a pixel specified by the <row> and <col> coordinate
    % parameters and adds a 1 to an array if a pixel is 1. If the sum of
    % 1's equals or exceeds 3, true is returned. If the sum equals 3 but
    % there are adjacent 1's, false is returned to prevent a not entirely
    % minimal skeleton from having too many branchpoints. For examples see
    % below:
    %
    % 0 1 0                                         0 0 1
    % 1 X 0 = true, because sum equals 3            0 X 0 = false, because sum < 3
    % 0 1 0                                         0 1 0
    %
    % 0 1 0                                         0 1 1
    % 1 X 1 = true, because sum > 3                 0 X 1 = false, because sum >= 3, but adjacent pixels
    % 0 1 0                                         1 0 0
    %

    methods(Static)
           %% Line Tracing (Modified Flood Fill)
           
           % > Parameters:      
           % skel - a skeletonized blob/label
           % startP - the starting point of a passed-in line
           % endP - the end of a passed-in line
           % mode - 'default' returns all points with an interval of 100 px, 'centerpt' returns the center of the line
           % 
           % > Returns:
           % an N x 2 matrix containing all coordinates
           function result = traceLine(skel, startP, endP, mode)
               if (strcmp(mode, "default"))
                   result = Algorithms.trace(skel, startP, endP, zeros(100000,2), 0, 0, 100);
               elseif (strcmp(mode, "centerpt"))
                   whitePx = sum(skel(:));
                   result = Algorithms.trace(skel, startP, endP, zeros(100000,2), 0, 0, round(whitePx * 0.5));
                   
                   if (isempty(result))
                       result = startP;
                       return;
                   end
                   
                   result = result(1, :);
               else
                   error("Unrecognizable input for parameter <mode>. Expected 'default' or 'centerpt', found '" + mode + "' instead.");
               end
           end
           
           % > Parameters:
           % skel - a skeletonized blob/label
           % startP - the starting point of a passed-in line
           % endP - the end of a passed-in line
           % pts - an N x 2 matrix for all coodinates
           % ctr - counter variable, saves point at recursion intervals specified by <threshold>
           % index - counter variable for array position
           % threshold - interval for ctr, see above
           %
           % > Returns:
           % an N x 2 matrix containing all coordinates
           function result = trace(skel, startP, endP, pts, ctr, index, threshold)
               sRow = startP(1);
               sCol = startP(2);
               eRow = endP(1);
               eCol = endP(2);

               if (sRow == eRow && sCol == eCol)
                   result = pts(1:index, :);
                   return;
               end

               if (mod(ctr, threshold) == 0 && ctr ~= 0)
                   index = index + 1;
                   pts(index, 1) = sRow;
                   pts(index, 2) = sCol;
               end

               skel(sRow, sCol) = 0;

               if (skel(sRow - 1, sCol + 1) ~= 0)
                   result = Algorithms.trace(skel, [sRow - 1, sCol + 1], endP, pts, ctr + 1, index, threshold);
                   return;
               end
               if (skel(sRow + 0, sCol + 1) ~= 0)
                   result = Algorithms.trace(skel, [sRow + 0, sCol + 1], endP, pts, ctr + 1, index, threshold);
                   return;
               end
               if (skel(sRow + 1, sCol + 1) ~= 0)
                   result = Algorithms.trace(skel, [sRow + 1, sCol + 1], endP, pts, ctr + 1, index, threshold);
                   return;
               end
               if (skel(sRow - 1, sCol + 0) ~= 0)
                   result = Algorithms.trace(skel, [sRow - 1, sCol + 0], endP, pts, ctr + 1, index, threshold);
                   return;
               end
               if (skel(sRow + 1, sCol + 0) ~= 0)
                   result = Algorithms.trace(skel, [sRow + 1, sCol + 0], endP, pts, ctr + 1, index, threshold);
                   return;
               end
               if (skel(sRow - 1, sCol - 1) ~= 0)
                   result = Algorithms.trace(skel, [sRow - 1, sCol - 1], endP, pts, ctr + 1, index, threshold);
                   return;
               end
               if (skel(sRow + 0, sCol - 1) ~= 0)
                   result = Algorithms.trace(skel, [sRow + 0, sCol - 1], endP, pts, ctr + 1, index, threshold);
                   return;
               end
               if (skel(sRow + 1, sCol - 1) ~= 0)
                   result = Algorithms.trace(skel, [sRow + 1, sCol - 1], endP, pts, ctr + 1, index, threshold);
                   return;
               end

               result = pts(1:index, :);
               return;
           end
     
           %% Curvature

           % > Parameters:      
           % skel - a skeletonized blob/label
           % endpoints - its endpoints in the form [row1, col1, row2,col2]
           %            (with endpoint1 = [row1, col1] and endpoint2 = [row2,col2])
           % 
           % > Returns:
           % an 1 x 5 array containing curvature value, row&column offset 
           % of middle points and row&column position of <skel>'s middle point      
           function dev = curvature(skel, endpoints)

                startPt = endpoints(1:2);
                endPt = endpoints(3:4);
                middlePix = Algorithms.traceLine(skel,startPt, endPt,'centerpt');

                rMiddle = middlePix(1);
                cMiddle = middlePix(2);
                
                % computes row and column offsets between middle point
                % of the skeleton and middle point of the straight line 
                % connecting <startPt> and <endPt>
                offCol = (endpoints(2) + endpoints(4))/2 - (cMiddle);
                offRow = (endpoints(1) + endpoints(3))/2 - (rMiddle);
               
                % distance of endpoints
                distEndp = norm(endpoints(1:2)-endpoints(3:4));
                
                % distance from middle of curve to middle of line
                distToLine = norm([offRow, offCol]);
                
                % relation of distances
                curvVal = distToLine/distEndp;
                
                dev = [curvVal, offRow, offCol, rMiddle, cMiddle];
                
                return;
           end
           
           %% Branchpoint Algorithm

           % > Parameters:
           % skel - a binary image (skeleton)
           %
           % > Returns:
           % an N x 2 array containing all coodinates of branchpoints found
           function branchpoints = findBranchpoints(skel)
               branchpoints = zeros(1000, 2);
               index = 1;
               
               for row = 1 : size(skel, 1)
                   for col = 1 : size(skel, 2)
                       if (skel(row, col) == 1)
                           if (Algorithms.isBranchpoint(skel, row, col))
                               branchpoints(index, 1) = row;
                               branchpoints(index, 2) = col;

                               index = index + 1;
                           end
                       end
                   end
               end
               
               branchpoints = branchpoints(1:index - 1, :);
           end
           
           % > Parameters:
           % skel - a binary image (skeleton)
           % row - the row the checked pixel is at (X in examples above)
           % col - the column the checked pixel is at (X in examples above)
           %
           % > Returns:
           % True if branchpoint is found, false otherwise
           function result = isBranchpoint(skel, row, col)
               values = zeros(1, 9);
               index = 1;
               
               for i = -1 : 1
                   for j = - 1 : 1
                       if (i ~= 0 || j ~= 0)
                           values(index) = skel(row + i, col + j);
                       end
                       
                       index = index + 1;
                   end
               end

               amount = sum(values(:));
               if (amount == 3)
                   if ((values(1) && values(2)) || (values(2) && values(3)) || (values(1) && values(4)) || (values(4) && values(7)) || (values(3) && values(6)) || values(6) && values(9) || (values(7) && values(8)) || (values(8) && values(9)))
                       result = false;
                       return;
                   end
                   
                   result = true;
                   return;
               elseif (amount >= 4)
                   result = true;
                   return;
               else
                   result = false;
               end
           end
      end
end

