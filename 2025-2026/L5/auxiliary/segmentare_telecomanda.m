clc;
clear;
close all;

original_image = imread("L5_image_03.png");
gray_image = rgb2gray(original_image);          % imshow(gray_image)
img_c = imcomplement(gray_image);               % imshow(img_c)
imge = edge(img_c, 'Prewitt', 0.03);        % imshow(imge)
imge_beta = imclose(imge, strel('disk',10));    % imshow(imge_beta)
img_seg = imfill(imge_beta, 'holes');           % imshow(img_seg)
img_seg = imerode(img_seg, strel('disk',8));    % imshow(img_seg)

% Fundalul este complementul mastii
fundal = ~img_seg;

% Nivelul mediu de gri al fundalului
nivel_mediu = uint8(mean(gray_image(fundal)));

% Construirea imaginii finale
R = uint8(ones(size(img_seg)) * double(nivel_mediu));
G = uint8(ones(size(img_seg)) * double(nivel_mediu));
B = uint8(ones(size(img_seg)) * double(nivel_mediu));

% Obiectul segmentat devine albastru
R(img_seg) = 0;
G(img_seg) = 0;
B(img_seg) = 255;

result_image = cat(3, R, G, B);

% Afisare rezultate
figure;
subplot(2,4,1);
imshow(original_image);
title('Imagine originala');

subplot(2,4,2);
imshow(gray_image);
title('Imagine gri');

subplot(2,4,3);
imshow(img_c);
title('Complement');

subplot(2,4,4);
imshow(imge);
title('Muchii Prewitt');

subplot(2,4,5);
imshow(img_seg);
title('Masca segmentata');

subplot(2,4,6);
imshow(result_image);
title('Obiect albastru, fundal gri mediu');