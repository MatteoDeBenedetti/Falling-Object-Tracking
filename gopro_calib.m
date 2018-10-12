clc
addpath('functions')

%% find parameters

% load images 
imds = imageDatastore('.\datastore\*.jpg');
[imagePoints,boardSize] = detectCheckerboardPoints(imds.Files);

squareSize = 25; % millimeters
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

I = readimage(imds,1);

% estimate parameters
imageSize = [size(I,1) size(I,2)];
params = estimateCameraParameters(imagePoints,worldPoints, 'ImageSize', imageSize);

J1 = undistortImage(I,params); %, 'Interp', 'Nearest');

% compare previous image with corrected image
figure
imshowpair(I,J1,'montage')
title('Original Image (left) vs. Corrected Image (right)')

% save parameters
% save('params.mat', 'params');


%% inspect detected points for calibration
figure
imshow(I);
hold on
plot(imagePoints(:,1,1),imagePoints(:,2,1),'go');
plot(params.ReprojectedPoints(:,1,1),params.ReprojectedPoints(:,2,1),'r+');
legend('Detected Points','Reprojected Points');
hold off