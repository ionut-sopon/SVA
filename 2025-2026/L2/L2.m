%% 1

coins = imread('coins.png');
peppers = imread('peppers.png');

% Convert to grayscale
peppers_gray = rgb2gray(peppers);

figure;
subplot(2,2,1); imshow(coins); title('Coins (Grayscale)');
subplot(2,2,2); imhist(coins); title('Histogram - Coins');

subplot(2,2,3); imshow(peppers_gray); title('Peppers (Grayscale)');
subplot(2,2,4); imhist(peppers_gray); title('Histogram - Peppers');

%% 2

peppers_comp = imcomplement(peppers);
peppers_gray_comp = imcomplement(peppers_gray);

bw = imbinarize(peppers_gray);
bw_comp = imcomplement(bw);

figure;
subplot(2,3,1); imshow(peppers); title('Original Peppers');
subplot(2,3,2); imshow(peppers_comp); title('Complement (Color)');
subplot(2,3,3); imshow(peppers_gray_comp); title('Complement (Gray)');
subplot(2,3,4); imshow(bw); title('Binarized Peppers');
subplot(2,3,5); imshow(bw_comp); title('Complement (Binary)');

%% 3

I1 = imread('coins.png');
I2 = imread('pout.tif');
I3 = imread('tire.tif');

I1_eq = histeq(I1);
I2_eq = histeq(I2);
I3_eq = histeq(I3);

figure;
subplot(3,2,1); imshow(I1); title('coins.png Original');
subplot(3,2,2); imshow(I1_eq); title('coins.png Equalized');
subplot(3,2,3); imshow(I2); title('pout.tif Original');
subplot(3,2,4); imshow(I2_eq); title('pout.tif Equalized');
subplot(3,2,5); imshow(I3); title('tire.tif Original');
subplot(3,2,6); imshow(I3_eq); title('tire.tif Equalized');

%% 4

low_contrast = imread('tire.tif');

% Contrast stretching
min_intensity = double(min(low_contrast(:)))/255;
max_intensity = double(max(low_contrast(:)))/255;
stretched = imadjust(low_contrast, [min_intensity max_intensity], [0 0.5]);

figure;
subplot(2,2,1); imshow(low_contrast); title('Original (Low Contrast)');
subplot(2,2,2); imhist(low_contrast); title('Histogram Original');
subplot(2,2,3); imshow(stretched); title('Contrast Stretched');
subplot(2,2,4); imhist(stretched); title('Histogram Stretched');

%% 5

lims = stretchlim(low_contrast);
adj1 = imadjust(low_contrast, lims, [0 1], 0.5); % Gamma < 1 (brighten)
adj2 = imadjust(low_contrast, lims, [0 1], 2);   % Gamma > 1 (darken)

figure;
subplot(2,2,1); imshow(adj1); title('Gamma = 0.5 (Brighten)');
subplot(2,2,2); imhist(adj1); title('Hist Gamma = 0.5');
subplot(2,2,3); imshow(adj2); title('Gamma = 2 (Darken)');
subplot(2,2,4); imhist(adj2); title('Hist Gamma = 2');

%% 6

clahe_img = adapthisteq(low_contrast);

figure;
subplot(1,2,1); imshow(clahe_img); title('CLAHE Result');
subplot(1,2,2); imhist(clahe_img); title('Histogram CLAHE');

%% %%%%%%%%%%%% TESTING %%%%%%%%%%%%%%%%%%%

I = imread('cameraman.tif');  
Itrans = imtranslate(I, [100, 100]);
M_compus = [1  0 0; ...
            0  1 0; ...
            100  100 1]; 
tform = affine2d(M_compus); 
coord = imref2d(size(Itrans));
I_mat = imwarp(I, tform, "OutputView", coord);  

figure; 
subplot 221
imshow(I)
subplot 222
imshow(Itrans)
subplot 223
imshow(I_mat); 
title('Translatie'); 

%%
I = imread('cameraman.tif');  
% Rotește imaginea cu 30 de grade  
I_std = imrotate(I, 30, 'bilinear'); 

theta = 30;     % Unghi rotație 
M_compus = [cosd(theta)  -sind(theta)  0; ...
            sind(theta)   cosd(theta)  0; ...
            0               0          1]; 

tform = affine2d(M_compus); 
I_mat = imwarp(I, tform);  
figure;  
imshow(I_mat); 
title('Rotație');



%%
img_coins = imread("peppers.png");
img_coins = rgb2gray(img_coins);
imhist(img_coins)
figure
imshow(img_coins)

%% 
im = imread('coins.png');
[m,n] = size(im);










[rez, images] = pyramidScale(im, 3, 0.5);
figure; imshow(uint8(rez));


function [rez, images] = pyramidScale(image, nrScales, stepScale)
    % vector de scalare
    scaleOfImages = 1:stepScale:nrScales;
    % vectori pentru dimensiuni
    m = zeros(length(scaleOfImages), 1);
    n = zeros(length(scaleOfImages), 1);
    % cell array pentru imagini
    images = {};
    
    for i = 1:length(scaleOfImages)
        tempIm = imresize(image, scaleOfImages(i)); % Scalarea cu factorul corespunzător
        [m1, n1] = size(tempIm);
        m(i) = m1;
        n(i) = n1;
        images{i} = tempIm;
    end

    % creare matrice globala/aia mare
    rez = zeros(m(end), n(end)); % Inițializarea matricei rez cu dimensiunile corecte
    % initializare doi indici
    k1 = 1;
    k2 = n(1);
    for i = 2:length(m)
        rez(1:m(i-1), k1:k2) = images{i-1}; % Combinarea imaginilor scalate
        k1 = k1 + n(i-1);
        k2 = k2 + n(i);
    end
    % final assignment
    rez(1:m(length(scaleOfImages)), (k1):(k2)) = images{end}; % Combinarea imaginilor scalate
end