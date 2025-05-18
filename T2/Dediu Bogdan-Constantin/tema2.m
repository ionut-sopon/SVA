clear all; close all; clc;

img = imread('1305B_1306A.png');  % Citesc imaginea
gray = rgb2gray(img);  % Transformare in nivel de gri

% Binarizare imaginii pentru a separa formele
bw = imbinarize(gray, 'adaptive', 'Sensitivity', 0.65);
bw = imcomplement(bw);

% Detecteaza contururile obiectelor si eticheteaza regiuni
[B, L] = bwboundaries(bw, 'noholes');
stats = regionprops(L, 'Centroid', 'BoundingBox', 'Eccentricity', 'Circularity', 'Orientation', 'MinorAxisLength', 'MajorAxisLength');

imshow(img); hold on;  % Afisez imaginea originala pentru a "desena" peste ea

for k = 1:length(B)
    muchii = B{k};
    % Creaza o masca binara pentru forma curenta
    masca = poly2mask(muchii(:,2), muchii(:,1), size(bw,1), size(bw,2));

    % Detectez colturi in masca pentru a determina tipul formei
    colturi = corner(masca, 'QualityLevel', 0.3);
    numColt = size(colturi, 1);

    % Preia caracteristicile din regionprops
    circ = stats(k).Circularity;
    box = stats(k).BoundingBox;
    ori = stats(k).Orientation;
    ecc = stats(k).Eccentricity;

    areGaura = 0;  % flag pentru gaura din forma

    % Clasificare pe baza numarului de colturi si alte proprietati

    if numColt == 3
        label = 'Triunghi';
        % Determina orientarea varfului triunghiului
        if ori < -89.99999
            label = 'Triunghi cu varful in jos';
        elseif ori > 89.99999
            label = 'Triunghi cu varful in sus';
        end

        % Verifica daca forma are gaura prin umplerea regiunii
        masca = ismember(L, k);
        mascaU = imfill(masca, 'holes');
        areGaura = any(mascaU(:) ~= masca(:));

    elseif numColt == 4
        raport = box(3) / box(4);  % Raport latime/inaltime pentru a diferentia formele
        if abs(raport - 1) < 0.2
            if abs(abs(ori) - 45) < 10
                label = 'Romb';
            else
                label = 'Patrat';
                % Detecteaza daca patratul este rotit
                if (ori > 10 & ori < 80) | (ori < -10 & ori > -80)
                    label = sprintf('%s rotit cu %.f', label, ori);
                end
            end
        else
            label = 'Dreptunghi';
        end

    elseif numColt >= 5
        label = 'Stea';
        % Initial stea,dupa in functie de circularitate si excentricitate
        % clasificam ca si cerc sau elipsa
        if circ > 0.8
            if ecc < 0.6
                label = 'Cerc';
            else
                label = 'Elipsa';
            end
        end

    else
        label = 'Necunoscut';
    end

    if areGaura
        label = [label ' cu gaura'];
    end

    centru = stats(k).Centroid;  % Pozitia centrului formei

    % Afiseaza eticheta pe imagine la centrul formei
    text(centru(1), centru(2), label, 'Color', 'black', 'FontSize', 8, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

    % Deseneaza dreptunghiul de incadrare in jurul formei
    rectangle('Position', box, 'EdgeColor', 'r', 'LineWidth', 2);

    %fprintf("Forma %d: %s cu unghiul %.2f°\n", k, label, ori);  % Afisare informatii in consola (comentata)
end

title('Forme detectate');
