classdef Transform

    methods(Static)
          % blob = the segmented object (blob) to be rotated
          % devBlob = value of the blob describing deviation from straight line 
          % devText = value of the text curve describing deviation from straight line 
           function imRotated = rotate(blob, endpBlob, endpText, devBlob, devText)
                
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
              angle = atan2d(vectorT(2), vectorT(1)) - atan2d(vectorB(2), vectorB(1));
              
              %rotate
              imRotated = imrotate(blob, angle);
               
              return;
           end
     
           function imScaled = scaling(blob, areaBlob, areaText)
               
               factor = areaText/areaBlob;
               
               imScaled = imresize(blob, factor);
               
           end
           
    end
end

