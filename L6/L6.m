%% aplicatia 1
im1 = imread('L6_image_01.tif');

h = [-1 0 1; -1 0 1;-1 0 1];
h1 = h';
% contururi extrase folosind masca P
im1h = imfilter(im1,h);
% contururi extrase folosind masca Q
im1ht = imfilter(im1,h1);
% Extragerea contururilor folosind operatorul Prewitt
prewitt_image = edge(im1,'prewitt');

% vizualizare
subplot(2,2,1);
imshow(im1);
subplot(2,2,2);
imshow(im1h);
subplot(2,2,3);
imshow(im1ht);
subplot(2,2,4);
imshow(prewitt_image);

%% aplicatia 2
im1 = imread('L6_image_01.tif');
sobel_image = edge(im1,'sobel');
prewitt_image = edge(im1,'prewitt');
canny_image = edge(im1,'canny');
log_image = edge(im1,'log');
roberts_image = edge(im1,'roberts');

subplot(2,3,1);
imshow(im1);
title('imagine originala');

subplot(2,3,2);
imshow(sobel_image);
title('imagine filtrata cu sobel');

subplot(2,3,3);
imshow(prewitt_image);
title('imagine filtrata cu prewitt');

subplot(2,3,4);
imshow(canny_image);
title('imagine filtrata cu canny');

subplot(2,3,5);
imshow(log_image);
title('imagine filtrata cu log');

subplot(2,3,6);
imshow(roberts_image);
title('imagine filtrata cu roberts');

%% aplicatia 3
im1 = imread('L6_image_01.tif');
% h=fspecial('gauss',[7 7],1.25);
% filter = imfilter(im1,h);
sobel = edge(im1,'canny',0.45);
imshow(im1);
[r,c] = find(sobel == 1);
hold on
plot(c,r,'.r');
%% aplicatia 4
im1 = imread('coins.png');
i1 = imnoise(im1,'salt & pepper');
imshow(i1);

ii1 = edge(im1,'sobel');
ii2 = edge(i1,'sobel');
figure(1);imshow(ii1);
figure(2);imshow(ii2);

%% opi
f = imread('L6_image_02.tif');
[m,n] = size(f);
x = 2:m-1;
y = 2:n-1;
f=double(f);
v1 = max(abs(f(x+1,y)-f(x,y)),abs(f(x-1,y)-f(x,y)));
v2 = max(abs(f(x,y-1)-f(x,y)),abs(f(x,y+1)-f(x,y)));
v3 = max(abs(f(x-1,y+1)-f(x,y)),abs(f(x+1,y-1)-f(x,y)));
v4 = max(abs(f(x+1,y+1)-f(x,y)),abs(f(x-1,y-1)-f(x,y)));
vmin = min(cat(3,v1,v2,v3,v4),[],3);
alpha =60;
[a,b] = find(vmin>alpha);
a= a+1;
b = b+1;

imshow(uint8(f));
hold on
plot(b,a,'rx')


%% 
im1 = imread('coins.png');
subplot(1,2,1);
imshow(im1);
title('imagine originala');
corners = detectMinEigenFeatures(im1);
subplot(1,2,2);
imshow(im1);
hold on
plot(corners.selectStrongest(10));
title('imagine cu IPO');
%% 
im2 = imread('L6_image_01.tif');
figure 
subplot(1,2,1);
imshow(im2);
title('imagine originala');
corners1 = detectMinEigenFeatures(im2); 
subplot(1,2,2);
imshow(im2)
hold on
plot(corners1.selectStrongest(50));
title('imagine cu IPO');