classdef Transform

    methods(Static)
          % blob = the segmented object (blob) to be rotated
          % endpBlob = endpoints of the skeleton of the blob (in the form
          %             [r1, c1, r2, c2])
          % endpText = endendpoints of the skeleton of the text curve (in the form
          %             [r1, c1, r2, c2])
          % devBlob = value of the blob describing deviation from straight line 
          % devText = value of the text curve describing deviation from straight line 
           function imRotated = rotate(blob, endpBlob, endpText, devBlob, devText)
               
               signBlob = sign(devBlob);
               signText = sign(devText);
               
               % different signs means curvature in other direction
               % -> rotate 180 degrees and change order of endpoints
               % accordingly
               if signBlob ~= signText
                   blob = imrotate(blob, 180);
                   temp1= endpBlob(1);
                   temp2= endpBlob(2);
                   endpBlob(1) = endpBlob(3);
                   endpBlob(2) = endpBlob(4);
                   endpBlob(3) = temp1;
                   endpBlob(4) = temp2;
               end
               
               % compute angles between straight line (connecting
               % endpoints) and horizontal axis
               vecBlob = [endpBlob(1) - endpBlob(3), endpBlob(2)-endpBlob(4)];
               angleBlob = acosd(dot(vecBlob,[0,1])/norm(vecBlob));
               
               vecText = [endpText(1) - endpText(3), endpText(2)-endpText(4)];
               angleText = acosd(dot(vecText,[0,1])/norm(vecText));
               
               % rotate blob by the difference of the angles
               imRotated = imrotate(blob, angleBlob-angleText);
               
               return;
           end
     
           
    end
end

