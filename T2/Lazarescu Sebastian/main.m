% SHAPE RECOGNITION %
% TEMA 2 %

clc
clear
close all

% Read the image
img = imread('images/shapes.png');

% Convert to gray scale
gray = rgb2gray(img);

% Binarize the image
T = 0.89;
bw = imbinarize(gray, T);

% Morphological operations
se = strel('square', 5);
bw_clean = imopen(bw, se);
bw_clean = ~bw_clean;

% Labeling
[label, num_obj] = bwlabel(bw_clean, 4);
label_color = label2rgb(label, @spring, "c", "shuffle");
% figure, imshow(label_color), title('Labeled Regions')

% Get properties
props = regionprops(logical(label), 'Eccentricity', 'Extent', ...
        'BoundingBox', 'Centroid', 'Solidity', 'EulerNumber', ...
        'Orientation', 'Circularity', 'Area', 'MajorAxisLength', ...
        'MinorAxisLength', 'PixelList');

img_annotated = img;

for i = 1 : num_obj
    shape = 'Necunoscut';
    
    % Detectie triunghuri
    if props(i).Eccentricity >= 0.4890 && props(i).Eccentricity <= 0.5050
        pixels = props(i).PixelList;

        y = pixels(:,2);
        x = pixels(:,1);

        top_band = x(y <= min(y) + 10);
        bottom_band = x(y >= max(y) - 10);

        top_width = max(top_band) - min(top_band);
        bottom_width = max(bottom_band) - min(bottom_band);

        if props(i).EulerNumber == 0
            shape = 'Triunghi cu gaura';
        elseif top_width < bottom_width
            shape = 'Triunghi cu varful in sus';
        elseif bottom_width< top_width
            shape = 'Triunghi cu varful in jos';
        end
    end

    % Detectie cercuri si elipse
    if props(i).Circularity > 0.9
        if props(i).Eccentricity == 0
            shape = 'Cerc';
        else
            shape = 'Elipsa';
        end
    end

    % Detectie patrat, patrat rotit si romb
    if (round(props(i).MajorAxisLength) == ...
            round(props(i).MinorAxisLength)) && props(i).Circularity < 0.9

        if props(i).Orientation ~= 0
            shape = 'Patrat rotit';
        elseif props(i).Extent == 1 && props(i).Solidity == 1
            shape = 'Patrat';
        elseif round(props(i).Extent, 1) == 0.5
            shape = 'Romb';
        end
    end

    % Detectie dreptunghi
    if props(i).Extent == 1 && props(i).Solidity == 1 ...
            && (round(props(i).MajorAxisLength) ~= round(props(i).MinorAxisLength))

        shape = 'Dreptunghi';
    end

    % Detectie stea
    if props(i).Solidity < 0.7
        shape = 'Stea';
    end
    
    % Drawing bounding box + annotations
    centroid = props(i).Centroid;
    img_annotated = insertText(img_annotated, centroid, shape, ...
        'BoxColor', 'white', 'TextColor', 'black', 'FontSize', 12);

     img_annotated = insertShape(img_annotated, 'Rectangle', props(i).BoundingBox, ...
        'Color', 'red', 'LineWidth', 2);
end

figure, imshow(img_annotated), title('Detected Shapes');