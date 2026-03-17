%% %%%%%%%%%%%%%%%%%%%%%%% APLICATII %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%% AP1 %%%%%%%%%%%%%%%%
I = imread('coins.png');

% daca imaginea este RGB, se converteste la gri
if size(I,3) == 3
    I = rgb2gray(I);
end

% -----------------------------
% a) Binarizare
% -----------------------------
T = graythresh(I);
BW_bin = zeros(size(I), 'uint8');
BW_bin(I >= T * 255) = 255;

% -----------------------------
% b) Band-thresholding
% -----------------------------
T1 = 80;
T2 = 150;
BW_band = zeros(size(I), 'uint8');
BW_band(I >= T1 & I <= T2) = 255;

% -----------------------------
% c) Praguri multiple
% -----------------------------
T1m = 70;
T2m = 130;
T3m = 190;

I_multi = zeros(size(I), 'uint8');
I_multi(I < T1m) = 0;
I_multi(I >= T1m & I < T2m) = 85;
I_multi(I >= T2m & I < T3m) = 170;
I_multi(I >= T3m) = 255;

% -----------------------------
% d) Semiprag
% -----------------------------
Ts = 100;
I_semi = I;
I_semi(I < Ts) = 0;

% -----------------------------
% Afisare rezultate
% -----------------------------
figure;

subplot(2,3,1);
imshow(I);
title('Imagine originala');

subplot(2,3,2);
imshow(BW_bin);
title('Binarizare');

subplot(2,3,3);
imshow(BW_band);
title('Band-thresholding');

subplot(2,3,5);
imshow(I_multi);
title('Praguri multiple');

subplot(2,3,6);
imshow(I_semi);
title('Semiprag');


%% %%%%%%%%%%%%%%%% AP2 %%%%%%%%%%%%%%%%
% -----------------------------
% a) Segmentare prin binarizare
% -----------------------------
I = imread('coins.png');

% Convertim la scala de gri dacă e cazul (coins.png e grayscale)
if size(I,3) == 3
    I = rgb2gray(I);
end

% Alegem un prag experimental 
threshold = 90;

% Segmentare binară
BW = I > threshold;

% Afișarea segmentării cu colormap cu 2 culori
figure;
imagesc(BW);
colormap([1 1 1; 0 1 0]); % alb pentru fundal, albastru pentru obiecte
colorbar;
title('Segmentare binară coins.png');

% -----------------------------
% b) Filtrare si segmentare prin praguri multiple
% -----------------------------
I2 = imread('L5_image_01.tif');

% Afișare imagine originală
figure;
imshow(I2);
title('Imaginea originală L5\_image\_01.tif');

% Filtrare reducere zgomot - filtru median 3x3
I_filt = medfilt2(I2, [3 3]);

% Histogramă imagine filtrată
figure;
imhist(I_filt);
title('Histogramă imagine filtrată');

% Definim praguri multiple pe baza experimentării
% Exemplu: presupunem praguri la 50, 100, 150 pentru 4 clase
thresh1 = 50;
thresh2 = 100;
thresh3 = 150;

% Segmentare multiple clase
segmented = zeros(size(I_filt));

segmented(I_filt <= thresh1) = 1;
segmented(I_filt > thresh1 & I_filt <= thresh2) = 2;
segmented(I_filt > thresh2 & I_filt <= thresh3) = 3;
segmented(I_filt > thresh3) = 4;

% Afișăm segmentarea cu o hartă de culori (colormap) cu 4 culori distincte
figure;
imagesc(segmented);
colormap(parula(4)); % folosește 4 culori din 'parula'
colorbar('Ticks',1:4, 'TickLabels',{'Clasa 1','Clasa 2','Clasa 3','Clasa 4'});
title('Segmentare cu praguri multiple L5\_image\_01.tif');


%% %%%%%%%%%%%%%%%% AP3 %%%%%%%%%%%%%%%%
% -----------------------------
% a) Segmentare prin binarizare
% -----------------------------

clc;
clear;
close all;

% Citirea imaginii
I = imread('L5_image_02.jpg');

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

%% %%%%%%%%%%%%%%%% AP4 %%%%%%%%%%%%%%%%
%% var 1
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
subplot(2,3,1);
imshow(original_image);
title('Imagine originala');

subplot(2,3,2);
imshow(gray_image);
title('Imagine gri');

subplot(2,3,3);
imshow(img_c);
title('Complement');

subplot(2,3,4);
imshow(imge);
title('Muchii Prewitt');

subplot(2,3,5);
imshow(img_seg);
title('Masca segmentata');

subplot(2,3,6);
imshow(result_image);
title('Obiect albastru, fundal gri mediu');

%% VAR 2
original_image = imread("L5_image_03.png");
gray_image = rgb2gray(original_image);  %   imshow(gray_image)
img_c = imcomplement(gray_image);       %   imshow(img_c)
background = imopen(img_c,strel('disk',100'));  %   imshow(background)

work_data = imadjust(imsubtract(img_c,background));  %   imshow(work_data)
 
imge = edge(work_data,'Prewitt',0.03);  %   imshow(imge)
imge_beta = imclose(imge,strel('disk',10));   %   imshow(imge_beta) 
img_seg = imfill(imge_beta,'holes');   %   imshow(img_seg)
img_seg = imerode(img_seg,strel('disk',8)); %!!!!!!!!!!!   %   imshow(img_seg)

img_label=bwlabel(img_seg);
label_set=unique(img_label);
img_last2=zeros(size(img_seg));
for i=1:numel(label_set)
    aux=(img_label==label_set(i));
    img_last2(aux)=uint8(mean(mean(gray_image(aux))));
end

final_image = uint8(img_last2);
figure;imshow(final_image);



%% %%%%%%%%%%%%%%%% AP5 %%%%%%%%%%%%%%%%

clc;
clear;
close all;

I = imread('L5_image_03.png');
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