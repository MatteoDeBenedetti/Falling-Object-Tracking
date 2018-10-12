%% Init
close all
clear all
clc

addpath('functions');



%% Parameters

% GOPR2159
% 4 cerchi grandi agli angoli
rMin1=35;
rMax1=45;
% cerchi piano inclinato
rMin2=26;
rMax2=32;
% cerchio piccolo ellisse 
rMin3=10;
rMax3=20;
% cerchio grande ellisse
rMin4=20;
rMax4=26;



%% Get video frames
% v = VideoReader('vid1.mp4');
v = VideoReader('GOPR2159.mp4');

% read a specific frame interval
% frames_vect = read(v, [1 100]); % [frame-inizio frame-fine] 

% read whole video
frames_vect = read(v); 
clear v;
n_frames = size(frames_vect, 4);

% figure, imshow(frames_vect(:,:,:,50));



%% Correct lens distortion

params1 = load('saved_variables/params.mat');
params = params1.params;

for i = 1:n_frames
    frames_vect(:,:,:,i) = undistortImage(frames_vect(:,:,:,i),params); 
end



%% Find 4 angles circles

data = frames_vect(:, :, :, 50); 
% imshow(data);

img = rgb2gray(data);
% figure, imshow(img);
% img = data(:,:,1)*1 + data(:,:,2)*1 + data(:,:,3)*1;
% figure, imshow(img);

% Apply median filter
img = medfilt2(img);
% figure, imshow(img);

% Stretch img
% img = imstretch(img);
img = imadjust(img);
% figure, imshow(img);

% Invert image
img = imcomplement(img);
% figure, imshow(img);

% Apply threshold
img_bin = imbinarize(img, 0.8);
% figure, imshow(img_bin);

% Apply morphological open
img_bin = bwareaopen(img_bin,350);
% figure, imshow(img_bin);

% Apply morphological close
mask = strel('disk',5);
img_bin = imclose(img_bin, mask);
% figure, imshow(img_bin);


centers=[];
radii=[];
metric=[];
[centers_raw,radii_raw, metric_raw] = imfindcircles(img_bin, [rMin1 rMax1], 'Sensitivity', 0.95, 'EdgeThreshold', 0.9);

result_mat = [centers_raw, radii_raw, metric_raw];
result_mat = sortrows(result_mat, 4, 'descend');
centers = result_mat(1:4,1:2);
radii = result_mat(1:4,3);
metric = result_mat(1:4,4);

blackCorners_coords = centers;
blackCorners_radii = radii;



%% Find Inlined plane

centers=[];
radii=[];
metric=[];
[centers_raw,radii_raw, metric_raw] = imfindcircles(img_bin, [rMin2 rMax2], 'Sensitivity', 0.95, 'EdgeThreshold', 0.9);

result_mat = [centers_raw, radii_raw, metric_raw];
result_mat = sortrows(result_mat, 4, 'descend');
centers = result_mat(1:2,1:2);
radii = result_mat(1:2,3);
metric = result_mat(1:2,4);

inclinedPlane_coords = centers;
inclinedPlane_radii = radii;



%% Delete angles and inclined plane circles

% delete 4 angles circles
for i = 1:size(blackCorners_coords,1)
    
    frames_vect(round(blackCorners_coords(i,2) - blackCorners_radii(i)):round(blackCorners_coords(i,2) + blackCorners_radii(i)), ...
        round(blackCorners_coords(i,1) - blackCorners_radii(i)):round(blackCorners_coords(i,1) + blackCorners_radii(i)),:,:) ...
        = 255*ones(1 + round(blackCorners_coords(i,2) + blackCorners_radii(i)) - round(blackCorners_coords(i,2) - blackCorners_radii(i)), ...
        1 + round(blackCorners_coords(i,1) + blackCorners_radii(i)) - round(blackCorners_coords(i,1) - blackCorners_radii(i)), ...
        3, n_frames);
    
end

% delete 2 inclined plane circles
for i = 1:size(inclinedPlane_coords,1)
    
    frames_vect(round(inclinedPlane_coords(i,2) - inclinedPlane_radii(i)):round(inclinedPlane_coords(i,2) + inclinedPlane_radii(i)), ...
        round(inclinedPlane_coords(i,1) - inclinedPlane_radii(i)):round(inclinedPlane_coords(i,1) + inclinedPlane_radii(i)),:,:) ...
        = 255*ones(1 + round(inclinedPlane_coords(i,2) + inclinedPlane_radii(i)) - round(inclinedPlane_coords(i,2) - inclinedPlane_radii(i)), ...
        1 + round(inclinedPlane_coords(i,1) + inclinedPlane_radii(i)) - round(inclinedPlane_coords(i,1) - inclinedPlane_radii(i)), ...
        3, n_frames);
    
end



%% Find small ellipse circle

smallEllipse_coords = zeros(n_frames,2);
smallEllipse_radii = zeros(n_frames,1);

for fr = 1 : n_frames
% for fr = 1000 : 1150
    
    % select and crop the fr-th frame
    data = frames_vect(:, :, :, fr); %1968
    
    % convert to greyscale
    img = rgb2gray(data);
    % figure, imshow(img);
    % img = data(:,:,1)*1 + data(:,:,2)*1 + data(:,:,3)*1;
    % figure, imshow(img);
    
    % Apply median filter
    img = medfilt2(img);
    % figure, imshow(img);
    
    % Stretch img
    % img = imstretch(img);
    img = imadjust(img);
    % figure, imshow(img);
    
    % Invert image
    img = imcomplement(img);
    % figure, imshow(img);
    
    % Apply threshold
    img_bin = imbinarize(img, 0.8);
    % figure, imshow(img_bin);
    
    % Apply morphological open
    img_bin = bwareaopen(img_bin,350);
    % figure, imshow(img_bin);
    
    % Apply morphological close
    mask = strel('disk',5);
    img_bin = imclose(img_bin, mask);
    % figure, imshow(img_bin);
    
    
    centers=[];
    radii=[];
    metric=[];
    [centers_raw,radii_raw, metric_raw] = imfindcircles(img_bin, [rMin3 rMax3], 'Sensitivity', 0.95, 'EdgeThreshold', 0.9);

    result_mat = [centers_raw, radii_raw, metric_raw];
    
    if numel(result_mat) > 0
        result_mat = sortrows(result_mat, 4, 'descend');
        centers = result_mat(1,1:2);
        radii = result_mat(1,3);
        metric = result_mat(1,4);
    else
        centers = NaN(1,2, 'double');
        radii = NaN(1,1, 'double');
        metric = NaN(1,2, 'double');
    end

    smallEllipse_coords(fr,:) = centers;
    smallEllipse_radii(fr) = radii;
    
end



%% Find large ellipse circle

largeEllipse_coords = zeros(n_frames,2);
largeEllipse_radii = zeros(n_frames,1);

for fr = 1 : n_frames
% for fr = 1000 : 1150
    
    % select and crop the fr-th frame
    data = frames_vect(:, :, :, fr); %1968
    
    % convert to greyscale
    img = rgb2gray(data);
    % figure, imshow(img);
    % img = data(:,:,1)*1 + data(:,:,2)*1 + data(:,:,3)*1;
    % figure, imshow(img);
    
    % Apply median filter
    img = medfilt2(img);
    % figure, imshow(img);
    
    % Stretch img
    % img = imstretch(img);
    img = imadjust(img);
    % figure, imshow(img);
    
    % Invert image
    img = imcomplement(img);
    % figure, imshow(img);
    
    % Apply threshold
    img_bin = imbinarize(img, 0.8);
    % figure, imshow(img_bin);
    
    % Apply morphological open
    img_bin = bwareaopen(img_bin,350);
    % figure, imshow(img_bin);
    
    % Apply morphological close
    mask = strel('disk',5);
    img_bin = imclose(img_bin, mask);
    % figure, imshow(img_bin);
    
    
    centers=[];
    radii=[];
    metric=[];
    [centers_raw,radii_raw, metric_raw] = imfindcircles(img_bin, [rMin4 rMax4], 'Sensitivity', 0.95, 'EdgeThreshold', 0.9);

    result_mat = [centers_raw, radii_raw, metric_raw];
    
    if numel(result_mat) > 0
        result_mat = sortrows(result_mat, 4, 'descend');
        centers = result_mat(1,1:2);
        radii = result_mat(1,3);
        metric = result_mat(1,4);
    else
        centers = NaN(1,2, 'double');
        radii = NaN(1,1, 'double');
        metric = NaN(1,2, 'double');
    end


    largeEllipse_coords(fr,:) = centers;
    largeEllipse_radii(fr) = radii;

end



%% Convert to meters

blackCorners_coords_m = zeros(2, 2);
for i = 1:4
    [blackCorners_coords_m(i,1), blackCorners_coords_m(i,2)] = pixels2meters(blackCorners_coords(i,1), blackCorners_coords(i,2), blackCorners_coords);
end

inclinedPlane_coords_m = zeros(2, 2);
for i = 1:2
    [inclinedPlane_coords_m(i,1), inclinedPlane_coords_m(i,2)] = pixels2meters(inclinedPlane_coords(i,1), inclinedPlane_coords(i,2), blackCorners_coords);
end

smallEllipse_coords_m = zeros(n_frames, 2);
for i = 1:n_frames
    [smallEllipse_coords_m(i,1), smallEllipse_coords_m(i,2)] = pixels2meters(smallEllipse_coords(i,1), smallEllipse_coords(i,2), blackCorners_coords);
end

largeEllipse_coords_m = zeros(n_frames, 2);
for i = 1:n_frames
    [largeEllipse_coords_m(i,1), largeEllipse_coords_m(i,2)] = pixels2meters(largeEllipse_coords(i,1), largeEllipse_coords(i,2), blackCorners_coords);
end



%% Write results

f_name1 = sprintf('outputs/results_angles_%d-%d-%d--%d-%d-%f.txt', clock);
f_name2 = sprintf('outputs/results_inclinedPlane_%d-%d-%d--%d-%d-%f.txt', clock);
f_name3 = sprintf('outputs/results_smallEllipse_%d-%d-%d--%d-%d-%f.txt', clock);
f_name4 = sprintf('outputs/results_largeEllipse_%d-%d-%d--%d-%d-%f.txt', clock);

fileID1 = fopen(f_name1, 'w');
fileID2 = fopen(f_name2, 'w');
fileID3 = fopen(f_name3, 'w');
fileID4 = fopen(f_name4, 'w');

for i = 1:size(blackCorners_coords_m,1)
    
    fprintf(fileID1, '%d %d \r\n', blackCorners_coords_m(i,1), blackCorners_coords_m(i,2));
    
end

fprintf(fileID2, '%d %d \r\n', inclinedPlane_coords_m(1,1), inclinedPlane_coords_m(1,2));
fprintf(fileID2, '%d %d \r\n', inclinedPlane_coords_m(2,1), inclinedPlane_coords_m(2,2));

for i = 1:size(smallEllipse_coords_m,1)
    
    fprintf(fileID3, '%d %d \r\n', smallEllipse_coords_m(i,1), smallEllipse_coords_m(i,2));
    
end

for i = 1:size(largeEllipse_coords_m,1)
    
    fprintf(fileID4, '%d %d \r\n', largeEllipse_coords_m(i,1), largeEllipse_coords_m(i,2));
    
end

fclose(fileID1);
fclose(fileID2);
fclose(fileID3);
fclose(fileID4);



%% Plot 4 angles circles

centers = blackCorners_coords;
radii = blackCorners_radii;
data = frames_vect(:, :, :, 1010); % 1st frame


figure(), imshow(data), title(horzcat('Borders circles detection r=', num2str(rMin1), ' -- ', num2str(rMax1)));
hold on

for i = 1:size(blackCorners_coords,1)
        
        viscircles(centers(i,:),radii(1), 'color', 'red', 'lineStyle', '-', 'lineWidth', 0.3);
        
        text(centers(i,1),centers(i,2), '+', 'color', 'red')    
        a = text(centers(i,1)+10,centers(i,2), horzcat('X: ', num2str(round(centers(i,1))), '    Y: ', num2str(round(centers(i,2))), '    R: ', num2str(round(radii(i)))));
        set(a, 'FontName', 'Cambria', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'red');
         
end

hold off



%% Plot inclined plane circles

centers = inclinedPlane_coords;
radii = inclinedPlane_radii;
data = frames_vect(:, :, :, 1010); % 1st frame 

figure(), imshow(data), title(horzcat('Inclined Plane circles detection r=', num2str(rMin2), ' -- ', num2str(rMax2)));
hold on

for i = 1:size(inclinedPlane_coords,1)
        
        viscircles(centers(i,:),radii(1), 'color', 'red', 'lineStyle', '-', 'lineWidth', 0.3);
        
        text(centers(i,1),centers(i,2), '+', 'color', 'red')    
        a = text(centers(i,1)+10,centers(i,2), horzcat('X: ', num2str(round(centers(i,1))), '    Y: ', num2str(round(centers(i,2))), '    R: ', num2str(round(radii(i)))));
        set(a, 'FontName', 'Cambria', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'red');
         
end

hold off



%% Plot small elliplse circles

fr = 1010;
centers = smallEllipse_coords(fr,:);
radii = smallEllipse_radii;
data = frames_vect(:, :, :, fr); % to change frame change 4th index of frame_vect

figure(), imshow(data), title(horzcat('Small Ellipse circle detection r=', num2str(rMin3), ' -- ', num2str(rMax3)));
hold on

for i = 1:size(smallEllipse_coords(fr,:),1)
        
        viscircles(centers(i,:),radii(1), 'color', 'red', 'lineStyle', '-', 'lineWidth', 0.3);
        
        text(centers(i,1),centers(i,2), '+', 'color', 'red')    
        a = text(centers(i,1)+10,centers(i,2), horzcat('X: ', num2str(round(centers(i,1))), '    Y: ', num2str(round(centers(i,2))), '    R: ', num2str(round(radii(i)))));
        set(a, 'FontName', 'Cambria', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'red');
         
end

hold off



%% Plot large elliplse circles

centers = largeEllipse_coords(fr,:);
radii = largeEllipse_radii(fr);
data = frames_vect(:, :, :, fr); % to change frame: change 4th index of frame_vect

figure(), imshow(data), title(horzcat('Large Ellipse circle detection r=', num2str(rMin4), ' -- ', num2str(rMax4)));
hold on

for i = 1:size(largeEllipse_coords(fr,:),1)
        
        viscircles(centers(i,:),radii(1), 'color', 'red', 'lineStyle', '-', 'lineWidth', 0.3);
        
        text(centers(i,1),centers(i,2), '+', 'color', 'red')    
        a = text(centers(i,1)+10,centers(i,2), horzcat('X: ', num2str(round(centers(i,1))), '    Y: ', num2str(round(centers(i,2))), '    R: ', num2str(round(radii(i)))));
        set(a, 'FontName', 'Cambria', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'red');
         
end

hold off


