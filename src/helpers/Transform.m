classdef Transform

    methods(Static)
          % blob = the segmented object (blob) to be rotated
          % devBlob = value of the blob describing deviation from straight line 
          % devText = value of the text curve describing deviation from straight line 
           function imRotated = rotate(blob, devBlob, devText)
     
               vecBlob = devBlob(2:3);
               vecText = devText(2:3);
               
               vecBlob = vecBlob/norm(vecBlob);
               vecText = vecText/norm(vecText);
               
              %angle between deviation vectors of curves 
              angle = atan2d(vecText(2), vecText(1)) - atan2d(vecBlob(2), vecBlob(1));
              
              imRotated = imrotate(blob, angle);
               
              return;
           end
     
           
    end
end

