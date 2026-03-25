%% Derivative

time = 0.1:0.1:100;
signal = [time(1:end/2)*0 (time((end/2 + 1):end)*0)+1];
subplot(1, 2, 1);
plot(time, signal);
subplot(1, 2, 2);
diffsig = diff(signal);
plot(time, [0 diffsig]);


%% %%%%%%%%%%%%%%%%% APLICATII %%%%%%%%%%%%%%%%%%%%%

%% 4.1

im = imread('coins.png');
%% A)
% Compass Sobel
h1 = [2 1 0; 1 0 -1; 0 -1 -2];
h3 = [0 -1 -2; 1 0 -1; 2 1 0];
h5 = -h1;
h7 = -h3;

% apply the filter
im_h1 = imfilter(im, h1, "replicate", "same");
im_h3 = imfilter(im, h3, "replicate", "same");
im_h5 = imfilter(im, h5, "replicate", "same");
im_h7 = imfilter(im, h7, "replicate", "same");

% show the images
figure();
subplot(2, 3, 1); imshow(im);       title("Original");
subplot(2, 3, 2); imshow(im_h1);    title("Upper Left");
subplot(2, 3, 3); imshow(im_h3);    title("Lower Left");
subplot(2, 3, 4); imshow(im_h5);    title("Lower Right");
subplot(2, 3, 5); imshow(im_h7);    title("Upper Right");

%% B
% apply tresholded edge
th = graythresh(im);
im_pre = edge(im, 'prewitt', th);
im_sob = edge(im, 'sobel', th);
im_can = edge(im, 'canny', th);

% showcase results
figure();
subplot(2, 2, 1); imshow(im);        title("Original");
subplot(2, 2, 2); imshow(im_pre);    title("Prewitt");
subplot(2, 2, 3); imshow(im_sob);    title("Sobel");
subplot(2, 2, 4); imshow(im_can);    title("Canny");

%% C
%% variant 1
imshow(im1);
[r,c] = find(sobel == 1);
hold on
plot(c,r,'.r', 'LineWidth',2);

%% variant 2
figure;
subplot(2, 2, 1); imshow(im);
subplot(2, 2, 2); imshow(im_can);

subplot(2, 2, [3,4]);

rgbIm = cat(3, im, im, im);
rgbIm(:, :, 1) = im - uint8(canny.*255);
rgbIm(:, :, 2) = im - uint8(canny.*255);
rgbIm(:, :, 3) = im + uint8(canny.*255);
imshow(rgbIm)

%% 4.2 
imT = imread("L4_image_01.tif");
[m,n] = size(imT); % get the size of the image
x = 2:m-1;         % define the x axis
y = 2:n-1;         % define the y axis
f=double(imT);     % transform to double for more precise mathematical calculations
% calculate the 4 variations
v1 = max(abs(f(x+1,y)-f(x,y)),abs(f(x-1,y)-f(x,y)));
v2 = max(abs(f(x,y-1)-f(x,y)),abs(f(x,y+1)-f(x,y)));
v3 = max(abs(f(x-1,y+1)-f(x,y)),abs(f(x+1,y-1)-f(x,y)));
v4 = max(abs(f(x+1,y+1)-f(x,y)),abs(f(x-1,y-1)-f(x,y)));
% concatenate the variations along the 3rd dimension and get the minimum
vmin = min(cat(3,v1,v2,v3,v4),[],3);
    
alpha = 100;              % define the threshold 
[a,b] = find(vmin>alpha); % check the indices where the minimum is over the threshold
a = a + 1; b = b + 1;     % incrementation

imshow(uint8(f)); hold on; plot(b,a,'r*');

%% 4.3
figure();
subplot(1,2,1); imshow(imT); title('imagine originala');
corners = detectMinEigenFeatures(imT);
subplot(1,2,2); imshow(imT); hold on
plot(corners.selectStrongest(10));
title('imagine cu IPO'); hold off;

%% 4.4
I1 = im2gray(imread("viprectification_deskLeft.png"));
I2 = im2gray(imread("viprectification_deskRight.png"));

% find the corners
points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);

% extract the neighborhood features.
[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);

% match the features.
indexPairs = matchFeatures(features1,features2);

% retrieve the locations of the corresponding points for each image.
matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

% visualize the corresponding points. You can see the effect of translation between the two images despite several erroneous matches.
figure; 
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);


%% 4.5 
imBook = imread('book_cover.png');
I_gray = rgb2gray(imBook);

% 2. Aplicare zgomot artificial (opțional, pentru test)
I_noisy = imnoise(I_gray, 'salt & pepper', 0.02);

subplot(2,3,2);
imshow(I_noisy);
title('Imagine cu zgomot');

% 3. Detecție muchii înainte de procesare (Sobel)
edges_before = edge(I_noisy, 'sobel');

subplot(2,3,3);
imshow(edges_before);
title('Muchii înainte de preprocesare');

% 4. Îmbunătățirea contrastului - adaptivă (equalizare histograme CLAHE)
I_contrast = adapthisteq(I_noisy);

subplot(2,3,4);
imshow(I_contrast);
title('Imagine după îmbunătățire contrast');

% 5. Reducerea zgomotului (filtru median)
I_denoised = medfilt2(I_contrast, [3 3]);

subplot(2,3,5);
imshow(I_denoised);
title('Imagine după filtrare mediană');

% I_cropped = imcrop(I_denoised);
I_cropped = I_denoised;

% 6. Detecție muchii după preprocesare
th = graythresh(I_cropped);
edges_after = edge(I_cropped, 'canny', th-0.05);

subplot(2,3,6);
imshow(edges_after);
title('Muchii după preprocesare');

% 7. Comentariu final
fprintf(['\nObservații:\n- Detecția muchiilor în imaginea inițială zgomotoasă este dificilă, ' ...
    'apare mult zgomot fals.\n- Îmbunătățirea contrastului evidențiază mai bine regiuni de interes.\n' ...
    '- Filtrul median reduce eficient zgomotul sarea și piper îmbunătățind astfel rezultatul ' ...
    'detecției muchiilor.\n']);