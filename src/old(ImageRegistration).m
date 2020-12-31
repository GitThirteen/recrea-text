% %% IMAGE REGISTRATION - uncomment to register images
% 
%             % FIXED & MOVING HAVE TO BE RGB OR GRAYSCALE IMAGES
%             fixedOriginal = skel;
%             fixed = uint8(255 * skel);
%             
%             % cropped version
%             movingOriginal = imread("../assets/segmentOriginal.png");
%             movingBW = imread("../assets/segmentBW.png");
%             movingSkel = bwskel(movingBW, 'MinBranchLength', 50);
%             moving = uint8(255 * movingSkel);
%             %moving = rgb2gray(movingOriginal);
%             
%             % uncropped version
% %             movingOriginal = imread("../assets/segmentRGB.png");
% %             movingBW = imread("../assets/segment.png");
% %             %moving = uint8(255 * movingBW);
% %             moving = rgb2gray(movingOriginal);
%             
%             
%             % CREATE REGISTRATION CONFIGURATION DATA
%             [optimizer, metric] = imregconfig('multimodal');
%             
%             % OPTIONAL ADJUSTMENTS
%             %optimizer = registration.optimizer.OnePlusOneEvolutionary;
%             %optimizer = registration.optimizer.RegularStepGradientDescent;
%             optimizer.InitialRadius = optimizer.InitialRadius * 0.8;
%             %optimizer.MaximumIterations = 300;
%             %metric = registration.metric.MattesMutualInformation;
%             %metric = registration.metric.MeanSquares;
%             
%             
%             % REGISTER IMAGES
%             % 'rigid', 'similarity', 'translation' or 'affine'
%             registered = imregister(moving, fixed, 'rigid', optimizer, metric);
%             figure;
%             imshowpair(registered, fixed);
%             
%             % CALCULATE HOW IT WAS TRANSFORMED
%             tform = imregtform(moving, fixed, 'rigid', optimizer, metric);
%             
%             % USE TRANSFORMATION ON ORIGINAL IMAGES
%             registeredOriginal = imwarp(movingOriginal,tform,'OutputView',imref2d(size(fixed)));
%             fusedOriginals = imfuse(registeredOriginal, fixedOriginal, 'blend');
%             figure;
%             imshow(fusedOriginals);