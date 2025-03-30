%segmentare

%% binarizarea
clear all;
close all;
clc;
im1=imread('coins.png');
im2=im1;
prag=100;
figure;
imhist(im1);
im2(im2>=prag)=255;
im2(im2>=50 & im2<prag)=0;
figure;
imshow(im2);

map=[0 255 0;100 180 180];
mapc=cast(map,'uint8');
figure;
imshow(im2,mapc); 

%% segmentare regiuni diferite
im3=imread('L7_image_01.tif');
figure;
imshow(im3);
%atenuare zgomot
%extragere niveluri de gri de pe histograma
%segmentare (etichetare + afisare)
im4=im3;
figure;
imhist(im4);
figure;
imshow(im4);
im4(im4<67)=0;
im4(im4<130 & im4>=67)=1;
im4(im4<180 & im4>=130)=2;
im4(im4>=180)=3;
im4=medfilt2(im4);
map1=[0 0 0;255 0 0;0 255 0; 0 0 255];
map1c=cast(map1,'uint8');
figure;
imshow(im4,map1c);

%% erodare/dilatare/deschidere/inchidere
im5=imread('L7_image_03.jpg');
im5=im2bw(im5);
figure;
imshow(im5);

se=strel("disk",4,4);
im6=imerode(im5,se);
figure;
imshow(im6);

se1=strel("disk",8,8);
im7=im6;
im7=imclose(im6,se1);
figure;
imshow(im6);

%% aplicatia de segmentare imagine noua

I = imread('L7_image_04.png');
I_gray = rgb2gray(I);
I_smooth = medfilt2(I_gray);

thresh = graythresh(I_smooth);
bw = imbinarize(I_smooth, thresh);

bw = ~bw;

% Operații morfologice de bază:
se = strel('disk', 5);
bw_closed  = imclose(bw, se);   % Conectează fragmentele obiectelor
bw_filled  = imfill(bw_closed, 'holes');  % Umple găurile din interiorul obiectelor
bw_opened  = imopen(bw_filled, se);   % Elimină zgomotul mic
bw_clean   = bwareaopen(bw_opened, 500); % Elimină regiunile foarte mici

% Etichetarea inițială pentru a vedea câte obiecte sunt
[L, num] = bwlabel(bw_clean);
fprintf('Numărul inițial de obiecte: %d\n', num);

RGB = zeros([size(L) 3], 'uint8');

% Pentru eticheta 1 (obiectul 1): roșu (R=255, G=0, B=0)
RGB(:,:,1) = uint8(255 * (L == 1));  % canalul roșu
% Pentru eticheta 2 (obiectul 2): verde (R=0, G=255, B=0)
RGB(:,:,2) = uint8(255 * (L == 2));  % canalul verde
% Pentru eticheta 3 (obiectul 3): albastru (R=0, G=0, B=255)
RGB(:,:,3) = uint8(255 * (L == 3));  % canalul albastru

% Afișăm imaginea colorată
figure;
imshow(RGB);
title('Etichete: 1 - roșu, 2 - verde, 3 - albastru');
