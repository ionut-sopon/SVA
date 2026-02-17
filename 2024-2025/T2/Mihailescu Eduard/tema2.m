clc; clear; close all;

% Citire imagine
img=imread('1305B_1306A.png'); % citim imaginea data (aceasta este o imagine RGB)
hsv_img = rgb2hsv(img); % Convertim imaginea în spațiul HSV (pentru a face segmentarea pe culori)

% Inițializare afișare
imshow(img); hold on; % Afișam imaginea originală și reținem figura activă pentru adăugarea de adnotari

% Definim o listă de culori cu intervalele HSV aferente fiecarei culori
colorRanges = {  
    'Roșu',       [0.95 0.05], [0.5 1], [0.4 1];
    'Galben',     [0.10 0.18], [0.5 1], [0.4 1];
    'Albastru',   [0.58 0.70], [0.5 1], [0.4 1];
    'Mov',        [0.76 0.84], [0.4 1], [0.3 1];
    'Verde',      [0.25 0.45], [0.4 1], [0.3 1];
    'Cyan',       [0.48 0.55], [0.4 1], [0.4 1];
    'Maro',       [0.05 0.08], [0.5 1], [0.2 0.6];
    'Portocaliu', [0.06 0.09], [0.5 1], [0.5 1];
    'Roz',        [0.82 0.95], [0.5 1], [0.5 1];
};

H = hsv_img(:,:,1); % Canalul de nuanță 
S = hsv_img(:,:,2); % Canalul de saturație
V = hsv_img(:,:,3); % Canalul de value

for i = 1:size(colorRanges,1)
    name = colorRanges{i,1}; % Numele culorii
    h_range = colorRanges{i,2}; % Intervalul pentru Hue
    s_range = colorRanges{i,3};  % Intervalul pentru Saturation
    v_range = colorRanges{i,4}; % Intervalul pentru Value

    % Masca binara pentru culoare
    if h_range(1) > h_range(2)  % Pentru roșu (interval ce trece prin 0)
        mask = (H >= h_range(1) | H <= h_range(2)) & ...
               (S >= s_range(1) & S <= s_range(2)) & ...
               (V >= v_range(1) & V <= v_range(2));
    else
        mask = (H >= h_range(1) & H <= h_range(2)) & ...
               (S >= s_range(1) & S <= s_range(2)) & ...
               (V >= v_range(1) & V <= v_range(2));
    end

    mask = bwareaopen(mask, 300); % Eliminăm zgomotul (forme mai mici de 300 pixeli)
    maskWithHoles = mask; % Salvam masca cu găurile inițiale (pentru detectarea găurilor)
    mask = imfill(mask, 'holes'); % Umplem găurile (pentru o formă completă)

    % Detectare contururi si proprietati
    [B, L, ~, A] = bwboundaries(mask, 'holes');
    stats = regionprops(L, 'Centroid', 'Area', 'Perimeter', ...
                        'BoundingBox', 'Eccentricity', 'Orientation');

    for k = 1:length(B)
        % Sărim contururile care au găuri 
        if A(k,k) ~= 0
            continue;
        end

        boundary = B{k}; % Conturul obiectului
        area = stats(k).Area; % Suprafața obiectului
        perimeter = stats(k).Perimeter; % Perimetrul obiectului
        circularity = 4 * pi * area / (perimeter^2); % Circularitatea
        centroid = stats(k).Centroid; % Centroidul (pentru afișare text)
        ecc = stats(k).Eccentricity;   % Excentricitatea (folosită la cerc/elipsă)
        bbox = stats(k).BoundingBox;  % Bounding box (dreptunghiul minim în care încape forma)
        aspect = bbox(3)/bbox(4);  % Raport lățime/înălțime
        orientation = abs(stats(k).Orientation); % Unghiul de rotație al formei

        regionMask = (L == k); % Extrage masca pentru forma curentă

        % Colțuri
        corners = corner(regionMask, 'QualityLevel', 0.01, 'SensitivityFactor', 0.04);
        numCorners = size(corners,1);  % Numărul de colțuri detectate

        % Clasificare formă
        shape = 'Necunoscut';

        if numCorners == 3
            shape = 'Triunghi';
            [~, idxTop] = min(corners(:,2)); % Cel mai sus punct (coordonată Y minimă)
            topPoint = corners(idxTop, :);
            otherPoints = corners(setdiff(1:3, idxTop), :);
            if all(topPoint(2) < otherPoints(:,2))
                shape = [shape, ' cu varful in sus'];
            else
                shape = [shape, ' cu varful in jos'];
            end

        elseif numCorners == 4
            if aspect > 0.85 && aspect < 1.15
                if orientation > 10  
                    shape = 'Patrat';
                else
                    shape = 'Romb';
                end
            else
                shape = 'Dreptunghi';
            end

        elseif numCorners >= 10 && circularity < 0.6
            shape = 'Stea';
        elseif circularity > 0.85 && ecc < 0.6
            shape = 'Cerc';
        elseif circularity > 0.6 && ecc >= 0.6
            shape = 'Elipsă';
        end

        

        % Detectam gaura folosind EulerNumber
        regionProps = regionprops(maskWithHoles, 'EulerNumber');
        hasHole = regionProps(k).EulerNumber < 1;

        if hasHole
            shape = [shape, ' cu gaură']; % Adaugăm etichetă "cu gaură"
        end 

        % Afișam conturul și eticheta pe imagine
        plot(boundary(:,2), boundary(:,1), 'black', 'LineWidth', 2);
        text(centroid(1), centroid(2), shape, 'Color', 'black', ...
            'FontSize', 12, 'FontWeight', 'bold');
    end
end

    
    hold off;
