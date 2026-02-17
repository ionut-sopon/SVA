%% for those who have laptops - or try at home
camera_list = webcamlist;
camera = webcam; % cam = webcam(camera_list(1)); 
preview(camera);
img = snapshot(camera);
imshow(img);
title('Cadru achiziționat cu camera web');
clear camera;

%% image acquisition using mobile device
% installation of Matlab Mobile on phone required
% Sensor permission required (Sensors->More->Sensor Access)
% mobile dev example
% m = mobiledev;
% cam = camera(m, 'back');
% preview(camera);
% img = snapshot(camera, 'manual');
% imshow(img);
% title('Cadru achiziționat cu camera web');
% clear camera;

%% Video recording with save on the disk
% (1) Enumerarea și selectarea camerei 
camera_list = webcamlist; 
cam = webcam(camera_list(1));  

% (2) Parametri de achiziție 
fps = 20;          % rata de cadre utilizată la scrierea fișierului 
duration = 5;      % durata înregistrării (secunde) 
nFrames = fps * duration;  

% (3) Inițializarea obiectului de scriere video 
outFile = 'webcam_record.mp4'; 
v = VideoWriter(outFile, 'MPEG-4'); 
v.FrameRate = fps; open(v);  

% (4) Achiziție cadre + scriere în fișier figure; 
for k = 1:nFrames     
    frame = snapshot(cam);     % preluare cadru RGB     
    writeVideo(v, frame);      % scriere în fișier

    imshow(frame);     
    title(sprintf('Înregistrare în curs: %d / %d cadre', k, nFrames));     
    drawnow;
end  

% (5) Închidere și eliberare resurse 
close(v); 
clear cam;

disp(['Fișier video salvat: ', outFile]); 

%% Video without saving
camera_list = webcamlist; 
cam = webcam(camera_list(1));  

fps = 15; 
duration = 4; 
nFrames = fps * duration;  

frames = cell(1, nFrames);  

figure; 
for k = 1:nFrames     
    frames{k} = snapshot(cam);     
    imshow(frames{k});     
    title(sprintf('Achiziție cadre: %d / %d', k, nFrames));     
    drawnow;     
    pause(1/fps);
end  

clear cam;


%% indexed image example
[indexedImage, colorMap] = rgb2ind(oneFrameSqueze, 10);
figure(1)
imshow(oneFrameSqueze)
figure(2)
imshow(indexedImage, colorMap);


figure(1)
subplot(2, 1, 1)
imshow(oneFrameSqueze)
subplot(2, 1, 2)
imshow(oneFrameSqueze)

%% EXERCISES

%% 1. Image acquisition and discussion
% run example 1.1
% check the variable in the workspace
% discuss about dimensions, data type and values inside

%% 2. RGB vs Gray

img = imread("peppers.png");    % read 'peppers.png'
img_gray = rgb2gray(img);       % convert to gray

figure(1);          % create a figure for showcasing
subplot(1, 2, 1);   % show the RGB image 
imshow(img);
title("RBG image");
subplot(1, 2, 2);   % show the gray image 
imshow(img_gray);
title("Gray image");

%% 3. Multiframe data
load("multiframeData.mat");                 % add the data to the workspace
oneFrame = multiframeImages(1, :, :, :);    % extract one frame from the video
% imshow(oneFrame)                          % va rezulta intr-o eroare pentru ca nu se poate afisa din cauza dimensiunii 
oneFrameSqueze = squeeze(oneFrame);         % squeeze scoate una din dimensiunile egala cu 1,
imshow(oneFrameSqueze);                     % pentru a ramane cu o imagine RGB ce poate fi afisata

% to showcase all the images, use a for loop with a pause
m = size(multiframeImages, 1);
for i = 1:m
    oneFrame = squeeze(multiframeImages(i, :, :, :));
    imshow(oneFrame);
    pause(1)
end

%% 4. RGB filter separation
r = oneFrameSqueze;             % extract the red channel by setting the green and the blue to 0
r(:, :, 2) = 0; r(:, :, 3) = 0;
g = oneFrameSqueze;             % extract the green channel by setting the red and the blue to 0
g(:, :, 1) = 0; g(:, :, 3) = 0;
b = oneFrameSqueze;             % extract the blue channel by setting the green and the red to 0
b(:, :, 1) = 0; b(:, :, 2) = 0;

% show the original and the 3 filters
figure(2)
subplot(2, 2, 1);
imshow(oneFrameSqueze);
title("Original") 
subplot(2, 2, 2);
imshow(r);
title("Red")
subplot(2, 2, 3);
imshow(g);
title("Green")
subplot(2, 2, 4);
imshow(b);
title("Blue")

%% 5. RGB to HSV

img = oneFrameSqueze;   % original RGB image
img_hsv = rgb2hsv(img); % convert to HSV

% Extract HSV channels
hue = img_hsv(:, :, 1);        % range: 0 to 1 (fraction of 360 degrees)
saturation = img_hsv(:, :, 2); % range: 0 to 1
value = img_hsv(:, :, 3);      % range: 0 to 1

% Visualization
figure;
subplot(2,2,1); imshow(img); title('Original RGB Image');
subplot(2,2,2); imshow(hue); title('Hue Channel (0-1)');
subplot(2,2,3); imshow(saturation); title('Saturation Channel (0-1)');
subplot(2,2,4); imshow(value); title('Value Channel (0-1)');

figure; imagesc(hue); colormap('hsv'); colorbar; title('Hue Channel with HSV colormap');

img_hsv_modified = img_hsv;
img_hsv_modified(:, :, 1) = mod(img_hsv(:, :, 1) + 0.1, 1); % Shift hue by 10%
img_rgb_modified = hsv2rgb(img_hsv_modified);

figure;
subplot(1, 2, 1); imshow(img); title('Original RGB');
subplot(1, 2, 2); imshow(img_rgb_modified); title('Hue Shifted by 10%');


