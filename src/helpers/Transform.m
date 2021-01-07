classdef Transform
    
    % TRANSFORM
    % > Author: Silke Buchberger
    % A class containing functions for geometric transformations used in
    % Part 3 of the main file.
    %
    % Functions:
    % > transformFactors(endpBlob, endpText, devBlob, devText)
    % Determines the angle for rotation and the scaling factor based on the
    % properties of the image to be transformed (<endpBlob>, <devBlob>) 
    % and the destination properties (<endpText>, <devText>)
    % Returns 1 x 2 array containing the rotation angle and the scaling factor
    %
    % > rotate(blob, angle)
    % Performs counterclockwise rotation of <blob> with the given <angle>
    % around the center. Therefore includes a translation to the center of
    % the image.
    % Uses "backwards transformation" and Nearest-Neighbor-Interpolation.
    % (for each pixel in the resulting rotated image interpolate the original image) 
    % Returns rotated image 
    %
    % > scale(blob, factor)
    % Performs scaling of <blob> by the given <factor>.
    % Uses "backwards transformation" and Nearest-Neighbor-Interpolation.

    
    methods(Static)     
%% transformFactors

      % endpBlob = array of endpoints of the Blob (of the form [r1,c1,r2,c2])
      % endpText = array of endpoints of the Text-curve (of the form [r1,c1,r2,c2])
      % devBlob = array of the blob describing deviation from straight line properties
      % devText = array of the text curve describing deviation from straight line properties
        function factors = transformFactors(endpBlob, endpText, devBlob, devText)
        % 1st: find angle for rotation
               %endpoints of curves
               endpBlob1 = endpBlob(1:2);
               endpBlob2 = endpBlob(3:4);
               endpText1 = endpText(1:2);
               endpText2 = endpText(3:4);
               
               % vectors from middle of curve to middle of
               % verbindungsgeraden
               vecBlob = devBlob(2:3);
               vecText = devText(2:3);
               
               % vector from middle of curve to endpoint1
               vecPointBlob = endpBlob1 - devBlob(4:5);
               vecPointText = endpText1 - devText(4:5);
               
               % check, on which side of the vector endpoint1 is
               % located ( -1 means one side, +1 means the other)
               % (this is the sign of the determinant of [ML ME] )
               % (M = middle of curve, L = middle of line, E = endpoint1)
               positionBlob = sign((vecBlob(1) * vecPointBlob(2) - vecPointBlob(1)*vecBlob(2)));
               positionText =  sign((vecText(1) * vecPointText(2) - vecPointText(1)*vecText(2)));
               
               % vector between endpoints of text curve
               vectorT = endpText1 - endpText2;
               % check if curves are located on the same side relative to the
               % according line
               % if not, change orientation of one of them
               if positionBlob ~= positionText
                   vectorB = endpBlob2 - endpBlob1;
               else
                   vectorB = endpBlob1 - endpBlob2;
               end

              % angle between vectors of text & object 
              % orientation: from object to text 
              angle = atan2(vectorT(2), vectorT(1)) - atan2(vectorB(2), vectorB(1));
              
          %2nd: find scaling factor
              % proportion of the distances of the endpoints
              normBlob = norm(vectorB);
              normText = norm(vectorT);
              
              % avoid division by 0
              if normBlob == 0
                  scalingFactor = normText;
              else
                  scalingFactor = normText/normBlob;
              end
                
          % return 1x2 vector with angle & scaling factor
          factors = [angle, scalingFactor];
          
          return;
        end
        
%% rotate
          % blob = the image (in our case: segmented object (blob)) to be rotated
          % angle = the angle (in radians), which the blob should be 
          %         rotated counterclockwise
           function imRotated = rotate(blob, angle)
              
               % transpose rotation matrix, because performing the rotation
               % "backwards", multiplying the matrix with the new
               % coordinates
               matRotate = [cos(angle), sin(angle);
                             -sin(angle), cos(angle)];
               
               [nrows, ncols] = size(blob, 1:2);
               
               % create new image where rotated blob is put into 
               maxsize = max(nrows, ncols);
               maxsize = round(maxsize * sqrt(2));
               imRotated = zeros(maxsize, maxsize, 3);
 
               % find centers, because we want to rotate around the center
               % center of imRotated
               middle = round(maxsize/2);
               
               % center of blob image
               midRow = round(nrows/2);
               midCol = round(ncols/2); 

               % create new coordinates
               [rowMat, colMat]  = meshgrid(1:maxsize, 1:maxsize);
       
               % create column vectors out of matrix and then transpose to
               % get row vectors
               rowArr = transpose(rowMat(:));
               colArr = transpose(colMat(:));
               coords = [rowArr-middle;colArr-middle]; % size: 2 x maxsize
               
               % rotate 
               rotatedcoords = matRotate*coords;
               rotatedcoords(1,:) = round(rotatedcoords(1,:)+midRow);
               rotatedcoords(2,:) = round(rotatedcoords(2,:)+midCol);
               coords = [rowArr; colArr];
               
               for l = 1:size(rotatedcoords,2)
                   a = rotatedcoords(1,l);
                   b = rotatedcoords(2,l);
                   if a>0 && b>0 && a<=nrows && b<=ncols          
                     imRotated(coords(1,l), coords(2,l),:)=blob(a,b,:);
                   end
               end  
        
               return;
           end
           
%% scale 
           % blob = the image to be scaled
           % factor = scaling factor (is used for both x & y)
           function imScaled = scale(blob, factor)

                % scaleRowCol = [factor, factor];            
                sizeBlob = size(blob);  
                % take max(..,1), so that scaling to 0 is not possible for
                % small factor, so minimum scaled size is 1 pixel
                sizeScaled = max(floor(factor.*sizeBlob(1:2)),1); 

                % indices of blob that are needed for scaled image
                % case: upscaling -> containing duplicates
                % case: downscaling -> leaving out indices
                % use nearest neighbor
                rowsScaled = min(round(((1:sizeScaled(1))-0.5)./factor+0.5),sizeBlob(1));
                colsScaled = min(round(((1:sizeScaled(2))-0.5)./factor+0.5),sizeBlob(2));

                imScaled = blob(rowsScaled,colsScaled,:);
           end
           
    end
end

