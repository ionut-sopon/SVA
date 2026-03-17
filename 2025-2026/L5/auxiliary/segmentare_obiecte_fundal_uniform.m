clc;
clear;
close all;

I = imread('L5_image_04.png');
I_gray = rgb2gray(I);
I_smooth = medfilt2(I_gray);

thresh = graythresh(I_smooth);
bw = imbinarize(I_smooth, thresh);
bw = ~bw;

se = strel('disk', 5);
bw_closed = imclose(bw, se);
bw_filled = imfill(bw_closed, 'holes');
bw_opened = imopen(bw_filled, se);

[L, num] = bwlabel(bw_opened);
fprintf('Numarul initial de obiecte: %d\n', num);

R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

if num >= 1
    mask1 = (L == 1);
    R(mask1) = 255;
    G(mask1) = 0;
    B(mask1) = 0;
end

if num >= 2
    mask2 = (L == 2);
    R(mask2) = 0;
    G(mask2) = 255;
    B(mask2) = 0;
end

if num >= 3
    mask3 = (L == 3);
    R(mask3) = 0;
    G(mask3) = 0;
    B(mask3) = 255;
end

RGB_overlay = cat(3, R, G, B);

figure;
subplot(1,3,1);
imshow(I);
title('Imagine originala');

subplot(1,3,2);
imshow(label2rgb(L));
title('Obiecte etichetate');

subplot(1,3,3);
imshow(RGB_overlay);
title('Obiecte colorate, fundal original');