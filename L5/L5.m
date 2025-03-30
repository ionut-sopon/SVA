%% example
I = imread('cameraman.tif');
figure()
% show original image
subplot(1, 3, 1);
imshow(I);
title('Original Image');

% create a convolution mask of 5x5
h = ones(5,5) / 25;
% apply the mask to the image
I1 = imfilter(I,h);
% show filtered image
subplot(1, 3, 2);
imshow(I1); 
title('Filtered - Image h1');
% create a convolution mask - gaussian
h2 = [1 2 1; 2 4 2; 1 2 1];
h2= h2 / sum(h2(:));
% apply the mask to the image
I2= imfilter(I,h2);
% show filtered image
subplot(1, 3, 3);
imshow(I2);
title('Filtered - Image h2');

%% 


I = imread('coins.png');
h1 = 1/9 * ones(3);
h2 = 1/16 * [1 2 1;2 4 2; 1 2 1];
I1 = imfilter(I,h1);
I2 = imfilter(I,h2);

%% ap1

figure
subplot(1,3,1);
imshow(I);
title('imagine originala');

subplot(1,3,2);
imshow(I1);
title('filtru h1');


subplot(1,3,3);
imshow(I2);
title('filtru h2');



%% ap2

imz1 = imnoise(I,'poisson');
imz1h1 = imfilter(imz1,h1);
imz1h2 = imfilter(imz1,h2);

figure
subplot(2,2,1);
imshow(I);
title('imagine originala');
subplot(2,2,2);
imshow(imz1);
title('imagine afectata de zgomot poisson');

subplot(2,2,3);
imshow(imz1h1);
title('imaginea afectata de zgomot possion filtrata cu h1');

subplot(2,2,4);
imshow(imz1h2);
title('imagine afectata de zgomot poisson filtrata cu h2');

%
figure
imz2 = imnoise(I,'salt & pepper');
imz2h1 = imfilter(imz2,h1);
imz2h2 = imfilter(imz2,h2);

subplot(2,2,1);
imshow(I);
title('imagine originala');
subplot(2,2,2);
imshow(imz2);
title('imagine afectata de zgomot salt & pepper');

subplot(2,2,3);
imshow(imz2h1);
title('imaginea afectata de zgomot salt & pepper filtrata cu h1');

subplot(2,2,4);
imshow(imz2h2);
title('imagine afectata de zgomot salt & pepper filtrata cu h2');
%%

% ap3
imz2 = imnoise(I,'salt & pepper');
med = medfilt2(I);
figure
subplot(1,3,1);
imshow(imz2);
title('imagine afectata de zgomot sare si piper');

subplot(1,3,2);
imshow(med);
title('imaginea afectata de zgomot sare si piper filtrata cu filtru de mediere');
adj = imadjust(med);
subplot(1,3,3);
imshow(adj);
title('imaginea afectata de zgomot sare si piper filtrata cu filtru de mediere + imadjust');

%% 

I = imread('coins.png');
[m,n] = size(I);
imz1 = imnoise(I,'poisson');

%filtru medie geometrica
I1 = uint8(zeros(m,n));
I2 = uint8(zeros(m,n));
for i = 2 : m-1
    for j = 2 : n-1
        % = imz1(i-1:i+1,j-1:j+1);
        I1(i,j) = prod(prod(imz1(i-1:i+1,j-1:j+1)))^(1/9);
        I2(i,j) = min(min(imz1(i-1:i+1,j-1:j+1)));
    end
end

subplot(1,3,1);
imshow(imz1);
title('afectare zgomot poisson');

subplot(1,3,2);
imshow(I1);
title('filtrare imagine poisson cu filtru medie geom');

subplot(1,3,3);
imshow(I2);
title('filtrare imagine poisson cu filtru min');

%% 
clear all
I = imread('L5_image_01.png');
[m,n] = size(I);

subplot(1,4,1);
imshow(I)
title('originala');


median_filtered =  uint8(zeros(m,n));

gauss_filter = fspecial('gaussian',[5 5]);
filtered_image = imfilter(I,gauss_filter);
subplot(1,4,2);
imshow(filtered_image);

for i = 2 : m - 1
    for j = 2 : n-1
        median_filtered(i,j) = prod(prod(filtered_image(i-1:i+1,j-1:j+1)))^(1/9);
    end
end
subplot(1,4,3);
imshow(median_filtered);

ajustare = imadjust(median_filtered);
subplot(1,4,4);
imshow(ajustare);

for i = 2 : m - 1
    for j = 2 : n-1
        final(i,j) = prod(prod(ajustare(i-1:i+1,j-1:j+1)))^(1/9);
    end
end

figure
imshow(uint8(final));


%la imaginea 2 e alt tip de zgomot, zgomot de miscare => posibilitatea daca
%toata miscarea s a facut pe aceeasi directie sau directii multiple. 