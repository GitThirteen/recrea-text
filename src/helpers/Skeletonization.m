%Author: Alexander Schallhart(11809596)
classdef Skeletonization
    %SKELETONIZATION (skeletonization of a binary image)
    % implementation of an iterative thinning algorithm
    %
    % Functions:
    % > skeleton(inputImage)
    % > Author: Alexander Schallhart
    % uses the Zhang Suen thinning algorithm to skeletonize a black/white
    % image for further processing
    
    methods(Static)
        % > Parameters:
        % inputImage - black/white image
        %
        % > Returns: skeletonized black/white image
        % 
        function result = skeleton(inputImage)
            %SKELETONIZATION Construct an instance of this class
            %   the inputImage has to be a BW image
            
            %%Skeletonize Code
            [Y, X] = size(inputImage);
            mark = zeros(Y, X);
            
            changed = 1;
            firstCheck = 1;
            while changed
                changed = 0;
                mark = zeros(Y, X);
                
                for x = 2:1:X-1
                    for y = 2:1:Y-1
                        %if the pixel is not black
                        if(inputImage(y,x) > 0)
                            
                            %mark = zeros(Y, X);
                            %pos 2 to 9 are the surrounding pixels of pos 1
                            %this exists so its easier to implement the algorithm
                            pos(1) = inputImage(y,   x);
                            pos(2) = inputImage(y-1, x);
                            pos(3) = inputImage(y-1, x+1);
                            pos(4) = inputImage(y,   x+1);
                            pos(5) = inputImage(y+1, x+1);
                            pos(6) = inputImage(y+1, x);
                            pos(7) = inputImage(y+1, x-1);
                            pos(8) = inputImage(y,   x-1);
                            pos(9) = inputImage(y-1, x-1);
                            
                            nonZeroNeighbor = 0;
                            transitSequence = 0;
                            change = pos(9);
                            
                            for n = 2:1:9
                                %N() number of non zero neighbors (white)
                                nonZeroNeighbor = sum(pos(2:end));
                                
                                %S() number of transitions from 0 to 1
                                if(double(pos(n)) - double(change)) < 0
                                    transitSequence = transitSequence + 1;
                                end
                                change = pos(n);
                            end
                            
                            if firstCheck == 1
                                %check if the pixel has to be removed
                                if((pos(2)==0 || pos(4)==0 || pos(6)==0) && (pos(4)==0 || pos(6)==0 || pos(8)==0) && 2 <= nonZeroNeighbor && nonZeroNeighbor <= 6 && transitSequence == 1)
                                    mark(y,x) = 1;
                                    changed = 1;
                               
                                %diagonal checks
                                elseif(pos(2)==1 && (pos(9)==1 || pos(3) == 1) && changed ~= 1 && 3 == nonZeroNeighbor)
                                    mark(y,x) = 1;
                                    changed = 1;
                                
                                elseif(pos(4)==1 && (pos(3)==1 || pos(5)==1)&& changed ~= 1 && 3 == nonZeroNeighbor)
                                    mark(y,x) = 1;
                                    changed = 1;
                                
%                                 if(pos(6)==1 && (pos(5)==1 || pos(7)==1)&& changed ~= 1 && 3 == nonZeroNeighbor)
%                                     mark(y,x) = 1;
%                                     changed = 1;
%                                 end
%                                 elseif(pos(8)==1 && (pos(7)==1 || pos(9)==1)&& changed ~= 1 && 3 == nonZeroNeighbor)
%                                     mark(y,x) = 1;
%                                     changed = 1;
                                end
                            end
                            
                            %second check
                            if firstCheck == 0
                                if((pos(2)==0 || pos(4)==0 || pos(8)==0) && (pos(2)==0 || pos(6)==0 || pos(8)==0) && 2 <= nonZeroNeighbor && nonZeroNeighbor <= 6 && transitSequence == 1)
                                    mark(y,x) = 1;
                                end
%                                 if((pos(3)==0 || pos(5)==0 || pos(9)==0) && (pos(3)==0 || pos(7)==0 || pos(9)==0) && 2 <= nonZeroNeighbor && nonZeroNeighbor <= 6 && transitSequence == 1 && changed ~= 1)
%                                     mark(y,x) = 1;
%                                 end
                            end
                        end
                        
                    end
                    
                    %inputImage(mark>0) = 0;
                end
                inputImage(mark>0) = 0;
                
                if sum(mark(:)) > 0
                    changed = 1; 
                end
                
                if firstCheck == 1
                   firstCheck = 0;
                end
                if firstCheck == 0
                    firstCheck = 1;
                end
                
            end
            %inputImage = bwmorph(inputImage,'bridge');
            %figure;
            %imshow(inputImage)
            result = inputImage;
        end
    end
end