classdef Transform

    methods(Static)
        
%% Transformation factors
          % blob = the (segmented) object to be transformed
          % endpBlob = array of endpoints of the Blob (of the form [r1,c1,r2,c2])
          % endpText = array of endpoints of the Text-curve (of the form [r1,c1,r2,c2])
          % devBlob = array of the blob describing deviation properties from straight line 
          % devText = array of the text curve describing deviation properties from straight line 
        function factors = transformFactors(blob, endpBlob, endpText, devBlob, devText)
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
               
               vectorT = endpText1 - endpText2;
               % check if they are located on the same side relative to the
               % according line
               % if not, change orientation of one 
               if positionBlob ~= positionText
                   vectorB = endpBlob2 - endpBlob1;
               else
                   vectorB = endpBlob1 - endpBlob2;
               end

              %angle between vectors of curve&blob (vectors of the verbindungsgeraden) 
              angle = atan2(vectorT(2), vectorT(1)) - atan2(vectorB(2), vectorB(1));
              
          %2nd: find scaling factor
              % proportion of the distances of the endpoints
              normBlob = norm(endpBlob1-endpBlob2);
              normText = norm(endpText1-endpText2);

              scalingFactor = normText/normBlob;
                
          % return 1x2 vector with angle & scaling factor
          factors = [angle, scalingFactor];
          
          return;
        end
        
%% Rotate
          % blob = the segmented object (blob) to be rotated
          % angle = the angle (in radians), which the blob should be 
          %         rotated counterclockwise
           function imRotated = rotate(blob, angle)
  %% this version works 
              
             % rotation matrix
               matRotate = [cos(angle), -sin(angle);
                             sin(angle), cos(angle)];
               
               [nrows, ncols] = size(blob, 1:2);
               
               % create new image where rotated blob is put into 
               maxsize = max(nrows, ncols);
               maxsize = round(maxsize * sqrt(2));
               imRotated = zeros(maxsize, maxsize, 3);
 
               %center of imRotated
               middle = round(maxsize/2);
               
               % center of blob image
               midRow = round(nrows/2);
               midCol = round(ncols/2); 
               
               % rotate around center
               
               % create coordinates
               [rowMat, colMat]  = meshgrid(1:maxsize, 1:maxsize);
       
               % create column vector out of matrix
               rowArr = rowMat(:);
               colArr = colMat(:);
               coords = [rowArr-middle,colArr-middle]; % maxsize x 2
               
               %rotate
               rotatedcoords = coords*matRotate;
               rotatedcoords(:,1) = round(rotatedcoords(:,1)+midRow);
               rotatedcoords(:,2) = round(rotatedcoords(:,2)+midCol);
               coords = [rowArr, colArr];
                
              for l = 1:size(rotatedcoords,1)
                   a = rotatedcoords(l,1);
                   b = rotatedcoords(l,2);
                   if a>0 && b>0 && a<=nrows && b<=ncols          
                     imRotated(coords(l,1), coords(l,2),:)=blob(a,b,:);
                   end
              end  
        
       %% this version works, too
%               [m,n]=size(blob,1:2);
%           
%                maxsize = max(m,n);
%                 
%                mm = round(maxsize*sqrt(2));
%                nn = round(maxsize*sqrt(2));
%                imRotated = zeros(mm,nn,3);
%                for t=1:mm
%                   for s=1:nn
%                      i = uint16((t-round(mm/2))*cos(angle)+(s-round(nn/2))*sin(angle)+round(m/2));
%                      j = uint16(-(t-round(mm/2))*sin(angle)+(s-round(nn/2))*cos(angle)+round(n/2));
%                       if i>0 && j>0 && i<=m && j<=n           
%                          imRotated(t,s,:)=blob(i,j,:);
%                       end
%                    end
%                end
%%
              return;
           end
%% Scale 
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

