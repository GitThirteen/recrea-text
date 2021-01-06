classdef Transform

    methods(Static)
        
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
               % (this is the sign of the determinant of [ML ME] 
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
          
          normBlob = norm(endpBlob1-endpBlob2);
          normText = norm(endpText1-endpText2);
          
          scalingFactor = normText/normBlob;
                
          % return 1x2 vector with angle & scaling factor
          factors = [angle, scalingFactor];
          return;
        end
        
          % blob = the segmented object (blob) to be rotated
          % endpBlob = array of endpoints of the Blob (of the form [r1,c1,r2,c2])
          % endpText = array of endpoints of the Text-curve
          % (of the form [r1,c1,r2,c2])
          % devBlob = array of the blob describing deviation properties from straight line 
          % devText = array of the text curve describing deviation properties from straight line 
           function imRotated = rotate(blob, angle)
             % rotates the blob counterclockwise according to angle value
               
              %% this version works
              [m,n]=size(blob,1:2);
          
               maxsize = max(m,n);
                
               mm = round(maxsize*sqrt(2));
               nn = round(maxsize*sqrt(2));
               imRotated = zeros(mm,nn,3);
               for t=1:mm
                  for s=1:nn
                     i = uint16((t-round(mm/2))*cos(angle)+(s-round(nn/2))*sin(angle)+round(m/2));
                     j = uint16(-(t-round(mm/2))*sin(angle)+(s-round(nn/2))*cos(angle)+round(n/2));
                      if i>0 && j>0 && i<=m && j<=n           
                         imRotated(t,s,:)=blob(i,j,:);
                      end
                   end
               end
  %% this version doesn't work, but wanted to do it with rotation matrix 
              
              % transpose rotation matrix
%                matRotate = [cos(angle), sin(angle);
%                              -sin(angle), cos(angle)];
%                
%                [nrows, ncols] = size(blob, 1:2);
%                
%                % create new image where rotated blob is put into 
%                maxsize = max(nrows, ncols);
%                maxsize = round(maxsize * sqrt(2));
%                imRotated = zeros(maxsize, maxsize, 3);
%                
%                %center of imRotated
%                middle = round(maxsize/2);
%                
%                % center of blob
%                midRow = round(nrows/2);
%                midCol = round(ncols/2); 
%  
%                % rotate around center
%                [rowMat, colMat]  = meshgrid(1:maxsize, 1:maxsize);
%        
%                rowArr = reshape(rowMat, 1 , []);
%                colArr = reshape(colMat, 1, []);
%                
% %                rowArr = repmat(rowArr,1,maxsize); %zeilenvec
% %                colArr = repmat(colArr,1,maxsize); % zeilenvec
%                
%                coords = [rowArr-middle;colArr-middle]; % 2 x maxsize
%                rotatedcoords = round(matRotate*coords);
%                rotatedcoords(1,:) = rotatedcoords(1,:)+middle;
%                rotatedcoords(2,:) = rotatedcoords(2,:)+middle;
%                coords = [rowArr; colArr];
%                  
%               for l = 1:size(rotatedcoords,2)
%                    [a,b] = transpose(rotatedcoords(:,l))
%                    if a>0 && b>0 && a<=nrows && b<=ncols          
%                      imRotated(coords(:,l),:)=blob(a,b,:);
%                    end
% %                         if  i > size(blob,1) | j > size(blob,2) | i<1 | j<1
% %                             imRotated(r, c,:)=0;
% %                         else
% %                             imRotated(r,c,:) = blob(i,j,:);
% %                         end
% 
%               end  
               
              return;
           end
     
           function imScaled = scaling(blob, factor)
               
               %imScaled = imresize(blob, factor);

            %%# Initializations:

            scale = [factor, factor];              %# The resolution scale factors: [rows columns]
            oldSize = size(blob);                   %# Get the size of your image
            newSize = max(floor(scale.*oldSize(1:2)),1);  %# Compute the new image size
            
            %# Compute an upsampled set of indices:
            
            rowIndex = min(round(((1:newSize(1))-0.5)./scale(1)+0.5),oldSize(1));
            colIndex = min(round(((1:newSize(2))-0.5)./scale(2)+0.5),oldSize(2));
            
            %# Index old image to get new image:
            
            imScaled = blob(rowIndex,colIndex,:);
           end
           
    end
end

