%% Aici am testat toate filtrele pt care am pus cod in pdf

I = imread('peppers.png');
I = imread('coins.png');
I1 = imnoise(I, 'gaussian');
I1 = imnoise(I1, 'salt & pepper');

% filtru medie aritmetica
k = fspecial('average');
I2 = imfilter(I1,k);
figure;imshow(I2);

% filtru medie geometrica
w = ones(3,3) / 9;
w1 = ones(3)/9;
A = double(I1);
I_geo = exp( imfilter(log(A), w1, 'replicate') );
imshow(uint8(I_geo));

% medie armonica
Nucleu_Sumare = ones(3,3); % Doar suma, fara impartire la 9
Suma_Inverse = imfilter(1./(double(I1)), Nucleu_Sumare);
I_armonic = 9 ./ Suma_Inverse;
figure;imshow(uint8(I_armonic))

% medie contraarmonica
Q = 1;
I_double = double(I1);
Numarator = imfilter(I_double.^(Q+1), ones(3,3));
Numitor   = imfilter(I_double.^Q,     ones(3,3));
I_contra = Numarator ./ Numitor;
figure;imshow(uint8(I_contra));

%% Aici am testat niste metrici utile

% ... 1. MSE la nivel de pixel 
I = imread('coins.png');
I1 = imnoise(I,'salt & pepper');
I2 = medfilt2(I1);

k = fspecial('average');
I3 = imfilter(I1,k);

er1 = immse(I,I2);
er2 = immse(I,I3);

er3 = ssim(I2,I);
er4 = ssim(I3,I);

%% %%%%%%%%%%%%%%%% APLICATII %%%%%%%%%%%%%%%%%%

%% 5.1
% Citire imagine (alege aici coins.png sau peppers.png)
I = imread('coins.png');
% I = imread('peppers.png');

% Conversie la gri dacă este color
if size(I,3) == 3
    I = rgb2gray(I);
end

% Definire filtre manuale (exemplu)
h0 = [0 0 0; 0 1 0; 0 0 0];           % Filtru identitate (nu modifică)
h1 = fspecial('average', [3 3]);       % Filtru de mediere 3x3
h2 = fspecial('laplacian', 0.2);       % Filtru Laplacian (detecție muchii)

% Aplicare filtre cu imfilter
I_h0 = imfilter(I, h0, 'replicate');
I_h1 = imfilter(I, h1, 'replicate');
I_h2 = imfilter(I, h2, 'replicate');

% Afișare rezultate
figure;
subplot(2,2,1), imshow(I), title('Original');
subplot(2,2,2), imshow(I_h0), title('Filtru h0 - Identitate');
subplot(2,2,3), imshow(I_h1), title('Filtru h1 - Mediere');
subplot(2,2,4), imshow(I_h2, []), title('Filtru h2 - Laplacian');

% Filtrul h0 nu modifică imaginea.
% Filtrul h1 realizează o netezire ușoară, estompează detalii mici.
% Filtrul h2 evidențiază muchiile și detaliile, accentuând contururile.
% Într-o imagine fără zgomot, filtrele de netezire estompează detalii, iar filtrele de detecție evidențiază structurile.


%% 5.2
I = imread('coins.png');
if size(I,3) == 3
    I = rgb2gray(I);
end

% Adăugare zgomot sare și piper
I_sp = imnoise(I, 'salt & pepper', 0.02);

% Adăugare zgomot gaussian
I_gauss = imnoise(I, 'gaussian', 0, 0.01);

% Adăugare zgomot poisson
I_poisson = imnoise(I, 'poisson');

% Aceleași filtre ca la 5.1

% Aplicarea filtrelor pe imaginea cu zgomot sare și piper
I_sp_h0 = imfilter(I_sp, h0, 'replicate');
I_sp_h1 = imfilter(I_sp, h1, 'replicate');
I_sp_h2 = imfilter(I_sp, h2, 'replicate');

% Aplicarea filtrelor pe imaginea cu zgomot gaussian
I_gauss_h0 = imfilter(I_gauss, h0, 'replicate');
I_gauss_h1 = imfilter(I_gauss, h1, 'replicate');
I_gauss_h2 = imfilter(I_gauss, h2, 'replicate');

% Aplicarea filtrelor pe imaginea cu zgomot poisson
I_poisson_h0 = imfilter(I_poisson, h0, 'replicate');
I_poisson_h1 = imfilter(I_poisson, h1, 'replicate');
I_poisson_h2 = imfilter(I_poisson, h2, 'replicate');

% Filtrul de mediere (h1) are rezultate bune în reducerea zgomotului gaussian și sare și piper, dar estompează detalii.
% Filtrul Laplacian (h2) accentuează zgomotul, deci nu este potrivit ca filtru de reducere zgomot.
% Filtrul h0 este filtru identitate, nu reduce zgomot.
% Cele mai bune rezultate apar cu filtre de netezire (mediile) sau filtrul median pentru zgomot sare și piper (vezi mai jos).

%% 5.3
% Citire imagine
I = imread('coins.png');
if size(I,3)==3
    I = rgb2gray(I);
end

% Creare imagine zgomotoasa salt & pepper si gaussian
I_sp = imnoise(I, 'salt & pepper', 0.02);
I_gauss = imnoise(I, 'gaussian', 0, 0.01);

% Filtru mediere 3x3
h_mediere_3 = fspecial('average', [3 3]);

% Aplicare filtru mediere
I_sp_med = imfilter(I_sp, h_mediere_3, 'replicate');
I_gauss_med = imfilter(I_gauss, h_mediere_3, 'replicate');

% Observatie: Netezire, dar zgomot sare si piper partial redus

% Aplicare filtru median
I_sp_median = medfilt2(I_sp, [3 3]);
I_gauss_median = medfilt2(I_gauss, [3 3]);

% Observatie: Filtrul median este mai eficient pe zgomot salt & pepper
% Pentru zgomot gaussian, filtrul mediere si median dau rezultate comparabile

% Aplicare filtru mediere cu dimensiuni diferite
h_mediere_5 = fspecial('average', [5 5]);
I_sp_med_5 = imfilter(I_sp, h_mediere_5, 'replicate');
I_gauss_med_5 = imfilter(I_gauss, h_mediere_5, 'replicate');

%% 5.4
% Filtru median (medfilt2)
I_sp_median = medfilt2(I_sp, [3 3]);
I_gauss_median = medfilt2(I_gauss, [3 3]);

% Filtru Wiener (adaptiv)
I_sp_wiener = wiener2(I_sp, [5 5]);
I_gauss_wiener = wiener2(I_gauss, [5 5]);

% Comparare rezultate afișare
figure;
subplot(2,3,1), imshow(I_sp), title('S&P zgomot');
subplot(2,3,2), imshow(I_sp_median), title('Median filter');
subplot(2,3,3), imshow(I_sp_wiener), title('Wiener filter');

subplot(2,3,4), imshow(I_gauss), title('Gaussian noise');
subplot(2,3,5), imshow(I_gauss_median), title('Median filter');
subplot(2,3,6), imshow(I_gauss_wiener), title('Wiener filter');

%% 5.5
% Citire imagine reală (se poate achiziționa cu cameră)
I = imread('peppers.png');
if size(I,3)==3
    I = rgb2gray(I);
end

% Simulare iluminare nefavorabilă: scăderea contrastului
I_low_contrast = imadjust(I, [0.3 0.7], []); % limite mai restrânse reduce contrast

% Îmbunătățire contrast (histogram equalization)
I_contrast = histeq(I_low_contrast);

% Zgomot poate deveni mai vizibil după îmbunătățire
% Aplicare filtru mediere ca exemplu de reducere zgomot
I_denoised = medfilt2(I_contrast, [3 3]);

% Dacă există imagine referință de iluminare bună:
% Calcul MSE și SSIM
mse_val = immse(I_denoised, I);
ssim_val = ssim(I_denoised, I);

fprintf('MSE: %.4f, SSIM: %.4f\n', mse_val, ssim_val);

% Afișare rezultate
figure;
subplot(2,2,1), imshow(I), title('Referință iluminare bună');
subplot(2,2,2), imshow(I_low_contrast), title('Contrast scăzut');
subplot(2,2,3), imshow(I_contrast), title('Îmbunătățire contrast');
subplot(2,2,4), imshow(I_denoised), title('Reducere zgomot median filter');

% Functie calcul MSE si SSIM pentru orice 2 imagini (ipoteza aceeasi dimensiune)
function [mse_val, ssim_val] = evaluate_quality(img1, img2)
    mse_val = immse(img1, img2);
    ssim_val = ssim(img1, img2);
end