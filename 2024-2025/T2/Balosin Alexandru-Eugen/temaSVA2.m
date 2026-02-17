% ========== detect_top8_named.m ==========
close all;

% 1. Încarcă imaginea
img  = imread('1305B_1306A.png');
imgG = rgb2gray(img);

% 2. Mască Otsu inversată
level = graythresh(imgG);
mask  = imcomplement(imbinarize(imgG, level));

% 3. Contururi + proprietăți
[B,L]   = bwboundaries(mask,'noholes');
stats   = regionprops(L, ...
    'BoundingBox','Centroid','Area','Image','EulerNumber','Circularity');

% 4. Sortează descrescător după arie
areas = [stats.Area];
[~, idx] = sort(areas,'descend');

% 5. Denumiri presetate pentru primele 7 regiuni
shapeNames = { ...
    'dreptunghi',                ... % idx(1)
    'elipsă',                    ... % idx(2)
    'stea',                      ... % idx(3)
    'cerc',                      ... % idx(4)
    'triunghi cu vârful în jos', ... % idx(5)
    'triunghi cu varful in sus',                      ... % idx(6)
    'triunghi cu gaura'            % idx(7)
};

% 6. Afișează primele 8 regiuni și detectează „patrat rotit”
figure; imshow(img); hold on;
for k = 1:8
    i    = idx(k);
    bb   = stats(i).BoundingBox;
    ctr  = stats(i).Centroid;
    reg  = stats(i).Image;
    eul  = stats(i).EulerNumber;
    cir  = stats(i).Circularity;
    
    % umple golurile + calculează orientarea și numărul de colțuri
    regF = imfill(reg,'holes');
    ort  = regionprops(regF,'Orientation').Orientation;
    nc   = numel(corner(regF,'QualityLevel',0.1,'SensitivityFactor',0.2));
    
    % raport laturi
    rap = bb(3)/bb(4);
    
    % clasificare cu suprascrieri:
    if nc == 4 && abs(rap-1)<0.2 && abs(abs(ort)-45)<15
        label = 'romb';                  % diamant cyan
    elseif nc == 4 && abs(rap-1)<0.2
        label = 'patrat rotit';          % patrat galben
    else
        % pentru primele 7, folosim numele prestabilite
        if k <= numel(shapeNames)
            label = shapeNames{k};
        else
            label = '';  % opțional, nimic pentru k>7
        end
    end
    
    % desenează doar dacă avem o etichetă
    if ~isempty(label)
        rectangle('Position',bb,'EdgeColor','g','LineWidth',2);
        text( ctr(1), ctr(2), label, ...
              'HorizontalAlignment','center', ...
              'VerticalAlignment','middle', ...
              'FontSize',12, 'Color','w', 'FontWeight','bold');
    end
end
hold off;
