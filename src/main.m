addpath('./filter');
addpath('../assets');

% Placeholder Class / Main
    
 image = imread('../assets/privjet.jpg');
 image = BinaryImage.imageToBinary(image);
 imshow(image)
