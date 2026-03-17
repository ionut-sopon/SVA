I = imread('L5_image_04.png');
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

% Etichetarea inițială pentru a vedea câte obiecte sunt
[L, num] = bwlabel(bw_opened);
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


