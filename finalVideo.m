%% Load workspace for coordinates
load('saved_variables/workspace');
addpath('functions')


%% Read source video

v = VideoReader('GOPR2159.mp4');

% read whole video
frames_vect2 = read(v); 
n_frames = size(frames_vect2, 4);

% figure, imshow(frames_vect(:,:,:,50));


%% Correct lens distortion

params1 = load('saved_variables/params.mat');
params = params1.params;

for i = 1:n_frames
    frames_vect2(:,:,:,i) = undistortImage(frames_vect2(:,:,:,i),params); 
end


%% Create video

clear com;
clear x;
clear y;

outputVideo = VideoWriter('outputs/vid_out.avi');
outputVideo.FrameRate = 15;
open(outputVideo)

close(figure(100))
fig = figure(100);

j = 1;
for i = 1000:3:1150 %1000:3:size(frames_vect, 4)

    data = frames_vect2(:, :, :, i); 
    imshow(data);
    hold on

    
    %% add ellipse
    
    [x(j,:),y(j,:)] = generate_ellipse(smallEllipse_coords(i,1), smallEllipse_coords(i,2), ...
        largeEllipse_coords(i,1), largeEllipse_coords(i,2));
    
    for ii = 1:size(x,1)
        line(round(x(ii,:)), round(y(ii,:)), 'color', 'y', 'LineWIdth', 1.5);
    end
    
    
    %% add CoM trajectory
    
    com(j, 1:2) = (smallEllipse_coords(i,:) + largeEllipse_coords(i,:))/2;
    
    if j > 1
        line(com(:,1)',com(:,2)', 'color', 'r', 'LineWIdth', 2);
    end
    
    
    %% save to the vid
    
    saveas(fig, 'outputs/temp/img_vidout.png');
    img = imread('outputs/temp/img_vidout.png');
    
    writeVideo(outputVideo,img)
    
    
    j = j + 1;
end

close(outputVideo)

