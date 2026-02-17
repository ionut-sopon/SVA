clear all;
clc;
close all;


i = imread("1305B_1306A.png");
imshow(i);
ib = rgb2gray(i);

ib = im2bw(ib, 0.9);
ib = ~ib;
ib = imclose(ib, strel('disk', 3));
ib = imopen(ib, strel('disk', 2));

imshow(ib);

edges = edge(ib, "Canny");
imshow(edges);

edges = imdilate(edges, strel("disk", 2));

% edges = imclose(edges, strel("disk", 2));

[labeled, numObjects] = bwlabel(edges);

imshow(labeled);

trasaturi = regionprops(labeled, "all");

    
 
hold on;



arii = [trasaturi.Area]';
peri = [trasaturi.Perimeter]';
compactness=zeros(length(trasaturi), 1);

for i=1:length(trasaturi)
    compactness(i) = (trasaturi(i).Perimeter ^ 2)/trasaturi(i).Area ;
    bb = trasaturi(i).BoundingBox;
    rectangle('Position', bb, 'EdgeColor', 'green', 'LineWidth', 2);

end
