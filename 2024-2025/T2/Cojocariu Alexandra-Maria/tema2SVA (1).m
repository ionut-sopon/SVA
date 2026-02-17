clc; clear; close all;

% 1. Citire imagine
img = imread('1305B_1306A.png');
imshow(img)
title('Imaginea')

hsv_img = rgb2hsv(img);
imshow(hsv_img);

% 2. Inițializare afișare
imshow(img); hold on;

% 3. Definim praguri HSV pentru fiecare culoare
colorRanges = {
'Roșu',       [0.95 0.05], [0.5 1], [0.4 1];
'Galben',     [0.13 0.18],   [0.8 1], [0.8 1];
'Albastru',   [0.58 0.70], [0.5 1], [0.4 1];
'Mov',        [0.7 0.85], [0.4 1], [0.1 0.6];
'Verde',      [0.25 0.45], [0.4 1], [0.3 1];
'Cyan',       [0.48 0.55], [0.4 1], [0.4 1];
'Maro',       [0.04 0.09],   [0.5 1], [0.3 0.7];
'Portocaliu', [0.095 0.125], [0.8 1], [0.8 1];
'Roz',        [0.83 0.95], [0.5 1], [0.75 1];
};

H = hsv_img(:,:,1);
S = hsv_img(:,:,2);
V = hsv_img(:,:,3);

for i = 1:size(colorRanges,1)
name = colorRanges{i,1};
h_range = colorRanges{i,2};
s_range = colorRanges{i,3};
v_range = colorRanges{i,4};

% Masca pentru culoare
if h_range(1) > h_range(2)
    mask = (H >= h_range(1) | H <= h_range(2)) & ...
           (S >= s_range(1) & S <= s_range(2)) & ...
           (V >= v_range(1) & V <= v_range(2));
else
    mask = (H >= h_range(1) & H <= h_range(2)) & ...
           (S >= s_range(1) & S <= s_range(2)) & ...
           (V >= v_range(1) & V <= v_range(2));
end

% Curățare mască și umplere găuri
mask = bwareaopen(mask, 300);
mask = imfill(mask, 'holes');

% Detectare contururi
[B, L] = bwboundaries(mask, 'noholes');
stats = regionprops(L, 'Centroid', 'Area', 'Perimeter', ...
                    'BoundingBox', 'Eccentricity');

for k = 1:length(B)
    boundary = B{k};
    area = stats(k).Area;
    perimeter = stats(k).Perimeter;
    circularity = 4 * pi * area / (perimeter^2);
    centroid = stats(k).Centroid;
    ecc = stats(k).Eccentricity;
    bbox = stats(k).BoundingBox;
    aspect = bbox(3)/bbox(4);

    % Detectăm colțuri cu corner()
    regionMask = (L == k);
    corners = corner(regionMask, 'QualityLevel', 0.01, 'SensitivityFactor', 0.04);
    numCorners = size(corners,1);

    shape = 'Necunoscut';

    if numCorners == 3
        shape = 'Triunghi';
        [~, idxTop] = min(corners(:,2));
        topPoint = corners(idxTop, :);
        otherPoints = corners(setdiff(1:3, idxTop), :);
        if all(topPoint(2) < otherPoints(:,2))
            orientation = 'sus';
        else
            orientation = 'jos';
        end
        shape = [shape, ' ', orientation];

   elseif numCorners == 4
% Obținem colțurile într-un ordin mai stabil (prin convhull)
kHull = convhull(corners(:,1), corners(:,2));
ordered = corners(kHull(1:4), :);

% Calculează lungimile laturilor
sides = vecnorm(diff([ordered; ordered(1,:)]), 2, 2);

% Calculează unghiurile dintre laturi
angles = zeros(4,1);
for j = 1:4
    v1 = ordered(mod(j-2,4)+1,:) - ordered(j,:);
    v2 = ordered(mod(j,4)+1,:) - ordered(j,:);
    cosAngle = dot(v1,v2) / (norm(v1)*norm(v2));
    angles(j) = acosd(cosAngle);
end

equalSides = std(sides) < 10;
rightAngles = all(abs(angles - 90) < 15);

if equalSides && rightAngles
    shape = 'Pătrat';
elseif ~equalSides && rightAngles
    shape = 'Dreptunghi';
elseif equalSides && ~rightAngles
    shape = 'Romb';
else
    shape = 'Patrulater';
end


    elseif numCorners >= 10 && circularity < 0.6
        shape = 'Stea';

    elseif circularity > 0.85 && ecc < 0.6
        shape = 'Cerc';

    elseif circularity > 0.6 && ecc >= 0.6
        shape = 'Elipsă';
    end

    % Afișare
   plot(boundary(:,2), boundary(:,1), 'Color', [0.5 0.5 0.5], 'LineWidth', 2);
   text(centroid(1), centroid(2), {shape; name}, 'Color', 'black','FontSize', 12, 'FontWeight', 'bold');
end


end

%%
clc; clear; close all;

% 1. Citește imaginea
img = imread('1305B_1306A.png');

% 2. Conversie RGB -> HSV
hsv_img = rgb2hsv(img);

% 3. Afișează imaginea HSV cu informații despre pixeli
figure;
imshow(hsv_img);
title('Imagine HSV - H (nuanță), S (saturație), V (luminozitate)');

% 4. Activează afișajul valorilor HSV sub cursor
impixelinfo;