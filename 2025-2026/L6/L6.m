%% --- aplicatia 5.1 ---
im = imread('PieseA.bmp');
im = rgb2gray(im);

level = graythresh(im);
bw = imbinarize(im, level);

[L, nr] = bwlabel(bw, 8);

fprintf('Numarul de obiecte este: %d\n', nr);

pseudo_color = label2rgb(L);
figure, imshow(pseudo_color);
title('Obiecte etichetate');
%% --- aplicatia 5.2 - centroid
im = imread('PieseA.bmp');
stats = regionprops(bw,'all');
[m, n]= size(stats);
figure;
imshow(im);
hold on
for i = 1 : m
    plot(stats(i).Centroid(1),stats(i).Centroid(2),'*r');
end

%% --- aplicatia 5.2 - BB
im = imread('PieseA.bmp');
figure;imshow(im)
hold on
for i = 1 : m
    BB = stats(i).BoundingBox;
    rectangle('Position',[BB(1),BB(2),BB(3),BB(4)],'EdgeColor','r')
end

%% --- aplicatia 5.3 detectie triunghi si cerc
I = imread('L6_image_01.png');
figure; imshow(I)

bw = imbinarize(rgb2gray(I)); figure; imshow(bw);
[L, num] = bwlabel(bw, 8);
fprintf('Numar de obiecte detectate: %d\n', num);

RGB = label2rgb(L, 'jet', 'k', 'shuffle'); figure; imshow(RGB);

stats = regionprops(L, 'Area', 'Perimeter', 'Centroid', 'BoundingBox', 'Extent', 'Eccentricity');

figure;
imshow(I);
title('Clasificarea formelor');
hold on;

for k = 1:length(stats)
    A = stats(k).Area;
    P = stats(k).Perimeter;
    C = (P^2) / A;     % compactitate
    ext = stats(k).Extent;
    BB  = stats(k).BoundingBox;
    xc  = stats(k).Centroid(1);
    yc  = stats(k).Centroid(2);

    % Reguli simple de clasificare
    % Pentru cerc: compactitate aproape de 4*pi
    if abs(C - 4*pi) < 1.5
        forma = 'Cerc';
        culoare = 'c';
    else
        forma = 'Triunghi';
        culoare = 'r';
    end

    % Bounding box
    rectangle('Position', BB, 'EdgeColor', culoare, 'LineWidth', 2);

    % Centroid
    plot(xc, yc, 'y*', 'MarkerSize', 10, 'LineWidth', 1.5);

    % Text cu clasa
    text(xc + 10, yc, sprintf('%s', forma), ...
        'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');

    % Afisare in Command Window
    fprintf('\nObiectul %d:\n', k);
    fprintf('  Arie = %.2f\n', A);
    fprintf('  Perimetru = %.2f\n', P);
    fprintf('  Compactitate = %.2f\n', C);
    fprintf('  Extent = %.2f\n', ext);
    fprintf('  Clasa = %s\n', forma);
end

hold off;

%% --- aplicatia 5.4 - imagine mai complexa
% aici problema prinicpala apare si din fundal
I = imread('L6_image_02.png'); figure; imshow(I);

I1 = imbinarize(rgb2gray(I)); 
I2 = imcomplement(I1); imshow(I2);

%% Conversie la double
Id = im2double(I);

colorDiff = max(I, [], 3) - min(I, [], 3);
bw = colorDiff > 50;

bw = imfill(bw, 'holes');
bw = bwareaopen(bw, 2000);

se = strel('disk', 3);
bw = imopen(bw, se);
bw = imclose(bw, se);

figure;
imshow(bw);
title('Masca binara');

%% Etichetare
[L, num] = bwlabel(bw, 8);
fprintf('Numar de obiecte detectate: %d\n', num);

%% Proprietati
stats = regionprops(L, 'Area', 'Perimeter', 'Centroid', ...
                       'BoundingBox', 'Extent', 'Orientation');

%% Clasificare
figure;
imshow(I);
title('Clasificarea obiectelor');
hold on;

for k = 1:length(stats)
    A = stats(k).Area;
    P = stats(k).Perimeter;
    C = (P^2) / A;
    BB = stats(k).BoundingBox;
    xc = stats(k).Centroid(1);
    yc = stats(k).Centroid(2);
    ext = stats(k).Extent;
    theta = stats(k).Orientation;

    w = BB(3);
    h = BB(4);
    aspectRatio = w / h;

    % normalizare orientare
    thetaAbs = abs(theta);

    % clasificare
    if abs(C - 4*pi) < 1.5
        forma = 'cerc';

    elseif abs(aspectRatio - 1) < 0.15
        % obiect aproape "patratos"
        if thetaAbs < 15 || thetaAbs > 75
            forma = 'patrat';
        elseif thetaAbs >= 30 && thetaAbs <= 60
            forma = 'romb';
        else
            forma = 'patrat/romb';
        end

    elseif ext > 0.8
        forma = 'dreptunghi';

    else
        forma = 'forma necunoscuta';
    end

    rectangle('Position', BB, 'EdgeColor', 'y', 'LineWidth', 2);
    plot(xc, yc, 'r*', 'MarkerSize', 10, 'LineWidth', 1.5);
    text(xc + 10, yc, forma, 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');

    fprintf('\nObiect %d\n', k);
    fprintf('  Compactitate = %.2f\n', C);
    fprintf('  Extent = %.2f\n', ext);
    fprintf('  Aspect ratio = %.2f\n', aspectRatio);
    fprintf('  Orientation = %.2f\n', theta);
    fprintf('  Clasa = %s\n', forma);
end

hold off;