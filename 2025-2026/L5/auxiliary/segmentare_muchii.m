clc;
clear;
close all;

% Citirea imaginii
I = imread('L5_image_03.png');

% Conversie la gri daca este necesar
if size(I,3) == 3
    I = rgb2gray(I);
end

% Afisare imagine originala
figure;
subplot(2,3,1);
imshow(I);
title('Imagine originala');

% Binarizare
BW = imbinarize(I);

subplot(2,3,2);
imshow(BW);
title('Imagine binara');

% Element structural
se = strel('disk', 3);

% Eroziune
BW_erode = imerode(BW, se);
subplot(2,3,3);
imshow(BW_erode);
title('Eroziune');

% Dilatare
BW_dilate = imdilate(BW, se);
subplot(2,3,4);
imshow(BW_dilate);
title('Dilatare');

% Deschidere
BW_open = imopen(BW, se);
subplot(2,3,5);
imshow(BW_open);
title('Deschidere');

% Inchidere
BW_close = imclose(BW, se);
subplot(2,3,6);
imshow(BW_close);
title('Inchidere');