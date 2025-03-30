%% for those who have laptops - or try at home
camera_list = webcamlist;
camera = webcam;
preview(camera);
img = snapshot(camera);
imshow(camera);
delete(camera);

%% image acquisition using mobile device
% installation of Matlab Mobile on phone required
% Sensor permission required (Sensors->More->Sensor Access)
% mobile dev example
% m = mobiledev;
% cam = camera(m, 'back');
% img = snapshot(cam, 'manual');
% imshow(img)



%% multiframe example
load("multiframeData.mat");
oneFrame = multiframeImages(1, :, :, :);
% imshow(oneFrame) % va rezulta intr-o eroare pentru ca nu se poate afisa din cauza dimensiunii 
oneFrameSqueze = squeeze(oneFrame);
imshow(oneFrameSqueze)


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

%% exercitiu rgb: filter separation

r = oneFrameSqueze;
r(:, :, 2) = 0; r(:, :, 3) = 0;
g = oneFrameSqueze;
g(:, :, 1) = 0; g(:, :, 3) = 0;
b = oneFrameSqueze;
b(:, :, 1) = 0; b(:, :, 2) = 0;

figure(2)
subplot(2, 2, 1);
imshow(oneFrameSqueze);
subplot(2, 2, 2);
imshow(r);
subplot(2, 2, 3);
imshow(g);
subplot(2, 2, 4);
imshow(b);

% cerinta este sa afiseze intr-o fereastra de 2x2 imaginea originala si
% cele 3 filtre

