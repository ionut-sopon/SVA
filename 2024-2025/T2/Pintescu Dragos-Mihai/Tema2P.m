% SHAPE RECOGNITION %
% TEMA 2 %

img = imread('1305B_1306A.png');
figure; imshow(img); title('Imaginea originala')

img_gray = rgb2gray(img);
figure; imshow(img_gray); title("Imaginea in tonuri de gri")

img_bw = imbinarize(img_gray, 0.89);
figure; imshow(img_bw); title("Imaginea binarizata");

% imopen
se = strel('square', 5);
img_bw_op = imopen(img_bw, se);
figure; imshow(img_bw_op); title('Imaginea(imopen)')
img_bw_op = ~img_bw_op;

% getting the edges of the geometrical shapes
img_edges = edge(img_bw_op);
figure; imshow(img_edges); title("Edges");

% getting object labels
[label, num_obj] = bwlabel(img_bw_op, 4);
% verifying if all objects are detected
label_color = label2rgb(label, @spring, "c", "shuffle");
figure, imshow(label_color)

% region props
props = regionprops(logical(label), 'Area', 'Perimeter', 'Eccentricity', 'Extent', 'BoundingBox', 'Centroid', 'Solidity','Orientation');
img_annotated = img;

for i = 1:num_obj
    centroid = props(i).Centroid;
    area = props(i).Area;
    perimeter = props(i).Perimeter;
    raport = perimeter^2 / area; 
    extent = props(i).Extent;
    ecc = props(i).Eccentricity;
    solidity = props(i).Solidity;
    bbox = props(i).BoundingBox;
    aspect_ratio = bbox(3) / bbox(4);
    orientation = props(i).Orientation;
    circular = 4 * pi * area / (perimeter^2); 

    object_img = imcrop(img_bw_op, bbox);
    corners = corner(object_img);
    num_corners = size(corners, 1);

    if ecc < 0.2 && circular > 0.85
        shape = 'Cerc';
    elseif raport > 19 && raport <=21
        if orientation < 0
            shape = 'Triunghi întors';
        else
            shape = 'Triunghi';
        end
    elseif extent > 0.95 && aspect_ratio > 1
        shape = 'Dreptunghi';
    elseif raport > 15 && raport <= 16
        if aspect_ratio >= 0.9 && aspect_ratio <= 1.1
            if orientation == 0
            shape = 'Romb';
            else
            shape = sprintf('Patrat (%.1f°)', orientation);
            end
        end
    elseif num_corners >= 15 && solidity < 0.8
        shape = 'Stea';
    elseif solidity < 0.9 && ecc < 0.8
        shape = 'Triunghi cu gol';
    elseif extent > 0.7 && extent < 0.95 && solidity > 0.85
        shape = 'Elipsa';
    end

    % Adnotare cu forma
    label_text = sprintf('%s' , shape);
    img_annotated = insertText(img_annotated, centroid, label_text, 'BoxColor', 'white', 'TextColor', 'black', 'BoxOpacity', 0, 'FontSize', 20);
    img_annotated = insertShape(img_annotated, 'Rectangle', bbox, 'Color', 'red', 'LineWidth', 3);
end

figure, imshow(img_annotated), title('Forme recunoscute');
