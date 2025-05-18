clear; close all; clc;

%1. Citire imagine și preprocesare
I = imread('1305B_1306A.png');        
Igray = rgb2gray(I);                

% Binarizare
I1 = Igray >= 255;     
figure; imshow(I1);
title('Imagine binarizată');

% Complementarea imaginii binare
bw = imcomplement(I1);
figure; imshow(bw); 
title('Imagine binară complementată');

% Etichetare componente conexe
[L, no] = bwlabel(bw);                % L = matricea etichetată; no = număr de forme
stats = regionprops(bw, 'all');       % Extrage toate proprietățile geometrice
%2. Afișare imagine originală cu detecții
figure; imshow(I);
title('Forme detectate');
hold on;

% Parcurgere fiecare obiect detectat
for i = 1:length(stats)
    % Trasare bounding box-ului
    rectangle('Position', stats(i).BoundingBox, 'EdgeColor', 'b', 'LineWidth', 0.5);
    
    % Coordonatele centrului formei
    xC = stats(i).Centroid(1);
    yC = stats(i).Centroid(2);
    
    %3. Clasificare forme pe baza caracteristicilor
    %3.1 Cerc 
    if stats(i).Circularity >0.97
        text(xC, yC, 'Cerc', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);
    
    %3.2 Elipsă
    elseif stats(i).Circularity > 0.90 && stats(i).Eccentricity > 0.7
        text(xC, yC, 'Elipsa', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);
    
    %3.3 Dreptunghi
    elseif abs(stats(i).BoundingBox(3) - stats(i).BoundingBox(4)) > 50
        text(xC, yC, 'Dreptunghi', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);

    %3.4 Romb
    elseif abs(stats(i).BoundingBox(3) - stats(i).BoundingBox(4)) == 0 && stats(i).Orientation == 0
        text(xC, yC, 'Romb', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);

    %3.5 Triunghi cu gaură
    elseif stats(i).EulerNumber == 0
        text(xC, yC, 'Triunghi cu gaura', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);

    %3.6 Triunghi cu vârful în jos
    elseif size(corner(stats(i).Image), 1) == 3 && stats(i).Orientation == -90
        text(xC, yC, 'Triunghi cu varful in jos', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);

    %3.7 Triunghi cu vârful în sus
    elseif size(corner(stats(i).Image), 1) == 3 && stats(i).Orientation == 90
        text(xC, yC, 'Triunghi cu varful in sus', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);

    %3.8 Pătrat rotit cu 30 de grade
    elseif abs(stats(i).BoundingBox(3) - stats(i).BoundingBox(4)) < 1 && stats(i).Orientation ~= 0
        text(xC, yC, 'Patrat rotit cu 30 de grade', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);

    %3.9 Stea
    elseif (stats(i).Perimeter^2) / (stats(i).Area) > 2
        text(xC, yC, 'Stea', 'Color', 'black', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 6);
    
    end
end

hold off;
