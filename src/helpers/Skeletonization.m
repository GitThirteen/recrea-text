classdef Skeletonization
    %SKELETONIZATION skeletonization of a binary image
    %   implementation of a thinning algorithm
    
    methods
        function result = skeleton(inputImage)
            %SKELETONIZATION Construct an instance of this class
            %   Detailed explanation goes here
            
            %%Test Purpose delete later
            %inputImage = imread('../assets/ABC.jpg');
            %inputImage(inputImage<128) = 1;
            %inputImage(inputImage>=128) = 0;
            
            %%Skeletonize Code
            [Y X] = size(inputImage);
            mark = zeros(Y, X);
            
            counter = 0;
            changed = 1;
            while changed && counter < 50
                changed = 0;
                counter = counter + 1;
                mark = zeros(Y, X);
                
                for x = 2:1:X-1
                    for y = 2:1:Y-1
                        %if the pixel is not black
                        if(inputImage(y,x) > 0)
                            %pos 2 to 9 are the surrounding pixels of pos 1
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
                                %N()
                                nonZeroNeighbor = sum(pos(2:end));
                                
                                %S()
                                if(double(pos(n)) - double(change)) < 0
                                    transitSequence = transitSequence + 1;
                                end
                                change = pos(n);
                            end
                            
                            %check if the pixel has to be removed
                            if~(nonZeroNeighbor == 0 || nonZeroNeighbor == 1 || nonZeroNeighbor == 7 || nonZeroNeigbor == 8 || transitSequence >= 2)
                                mark(y,x) = 1;
                            end
                        end
                    end
                end
                inputImage(mark>0) = 0;
                if sum(mark(:)) > 0; 
                    changed = 1; 
                end
                
            end
            
            figure;
            imshow(inputImage)
            result = inputImage;
        end
    end
end

