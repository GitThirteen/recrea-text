classdef Blobs
    %find & label blobs
    
    methods(Static)
        function labeledImage = label(image)
            labeledImage = bwlabel(image);
        end
       
        function cc = findCC(image)
           cc = bwconncomp(image,8); %alternative to bwlabel()
        end
        
%         function properties = getProps(labeledImage, originalImage)
%             blobMeasurements = regionprops(labeledImage, originalImage, 'all');
%             numberOfBlobs = size(blobMeasurements, 1);
%         end
        
        function [boundaries, numberOfBoundaries] = findBoundaries(image)
            boundaries = bwboundaries(image);
            numberOfBoundaries = size(boundaries, 1);
        end
        
%         function keeperBlobs = keep(image)
%             % use properties from regionprops to decide which blobs to keep
%             % properties: e.g. .Area, .MeanIntensity, .ConvexHull etc 
%         end
        
%         function maskedImage = useMask(image)
%             mask = image;
%             mask(~keeperBlobs) = 0; %set non-keeper Blobs to 0
%         end
        
    end
end

