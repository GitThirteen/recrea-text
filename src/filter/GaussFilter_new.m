classdef GaussFilter_new
    methods(Static)
        function retImage = gaussfilter(image, sigma, radius)
            % Generate the kernel.
            [x,y] = meshgrid(-radius:radius, -radius:radius);
            n = size(x, 1) - 1;
            m = size(y, 1) - 1;
            exp_comp = -(x .^ 2 + y .^ 2) / (2 * sigma ^ 2);
            kernel = exp(exp_comp) / (2 * pi * sigma^2);
            
            % Initialize the return image.
            retImage = zeros(size(image));
            workImage = padarray(image,[radius radius]);
            
            % Loop.
            for i = 1 : size(workImage, 1) - n
                for j = 1 : size(workImage, 2) - m
                    temp = workImage(i:(i + n), j:(j + m)) .* kernel;
                    retImage(i,j) = sum(temp(:));
                end
            end
            
            % Convert the return-image back to integer values.
            retImage = uint8(retImage);
        end
    end
end