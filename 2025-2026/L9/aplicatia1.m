clc; clear; close all;

%% =========================================================
%  PASUL 1 — Parametrii camerei stereo
%% =========================================================

f  = 721.5377;   % distanta focala [pixeli]
cu = 609.5593;   % centrul de proiectie - coordonata orizontala
cv = 172.8540;   % centrul de proiectie - coordonata verticala
b  = 0.5327;     % baseline - distanta fizica dintre camere [metri]

%% =========================================================
%  PASUL 2 — Citirea imaginilor stereo
%% =========================================================

I_left_color  = imread('kitti_subset/image_L/1_L.png');
I_right_color = imread('kitti_subset/image_R/1_R.png');

% Conversie la grayscale pentru calculul disparitatii
I_left  = rgb2gray(I_left_color);
I_right = rgb2gray(I_right_color);

[m, n] = size(I_left);

% Afisare imagini stereo
figure('Name', 'Imagini Stereo', 'NumberTitle', 'off');
subplot(1,2,1); imshow(I_left_color);  title('Imaginea Stanga');
subplot(1,2,2); imshow(I_right_color); title('Imaginea Dreapta');

%% =========================================================
%  PASUL 3 — Calculul hartii de disparitate
%% =========================================================

disparityRange = [0, 128];

dispMap = disparity(I_left, I_right, ...
    'Method',             'SemiGlobal', ...
    'DisparityRange',     disparityRange, ...
    'UniquenessThreshold', 15);

% Vizualizare harta de disparitate
figure('Name', 'Harta de Disparitate', 'NumberTitle', 'off');
imshow(dispMap, disparityRange);
colormap(jet); colorbar;
title('Harta de Disparitate - SemiGlobal Matching');
xlabel('Valori mari (galben/rosu) = obiecte aproape');

%% =========================================================
%  PASUL 4 — Detectia pietonilorcu peopleDetectorACF
%% =========================================================

detector = peopleDetectorACF();

% Detectie pe imaginea stanga colorata
% 'MinSize' limiteaza detectiile la persoane suficient de mari in imagine
[bboxes, scores] = detect(detector, I_left_color, ...
    'MinSize', [100, 41],'Threshold',0.5);

fprintf('=== DETECTIE PIETONI ===\n');
fprintf('Numar persoane detectate: %d\n\n', size(bboxes, 1));

% Afisare rezultat detectie pe imaginea originala
figure('Name', 'Detectie Pietoni', 'NumberTitle', 'off');
imshow(I_left_color); hold on;
title(sprintf('Persoane detectate: %d', size(bboxes, 1)));

for i = 1:size(bboxes, 1)
    rectangle('Position', bboxes(i,:), 'EdgeColor', 'g', 'LineWidth', 2);
    text(bboxes(i,1), bboxes(i,2) - 5, ...
        sprintf('%.2f', scores(i)), ...
        'Color', 'g', 'FontSize', 10, 'FontWeight', 'bold');
end
hold off;

%% =========================================================
%  PASUL 5 — Reconstructia 3D a fiecarui pieton detectat
%% =========================================================

% Generare matrice coordonate u si v pentru intreaga imagine
[u_mat, v_mat] = meshgrid(1:n, 1:m);

fprintf('%-10s %-20s %-15s %-15s\n', 'Pieton', 'Score detectie', 'Dist. medie', 'Dist. minima');
fprintf('%s\n', repmat('-', 1, 60));

for i = 1:size(bboxes, 1)

    % --- 5.1 Extrage coordonatele bounding box
    col_start = max(1, bboxes(i,1));
    row_start = max(1, bboxes(i,2));
    col_end   = min(n, bboxes(i,1) + bboxes(i,3) - 1);
    row_end   = min(m, bboxes(i,2) + bboxes(i,4) - 1);

    % --- 5.2 Creeaza masca bounding box (imaginea B din pseudocod)
    masca_B = false(m, n);
    masca_B(row_start:row_end, col_start:col_end) = true;

    % --- 5.3 Aplica masca peste harta de disparitate (imaginea C)
    masca_C = masca_B & (dispMap > 0);

    % --- 5.4 Coordonatele pixelilor valizi
    [rows_idx, cols_idx] = find(masca_C);

    if isempty(rows_idx)
        fprintf('Pieton %-4d  -> niciun pixel valid in zona!\n', i);
        continue;
    end

    % --- 5.5 Reconstructie 3D
    nrPuncte = length(rows_idx);
    X_3d = zeros(nrPuncte, 1);
    Y_3d = zeros(nrPuncte, 1);
    Z_3d = zeros(nrPuncte, 1);
    gri  = zeros(nrPuncte, 1);

    for k = 1:nrPuncte
        r = rows_idx(k);
        c = cols_idx(k);

        d = dispMap(r, c);
        if d <= 0; continue; end

        % Formula adancime
        Z = f * b / d;

        % Formulele de recuperare a pozitiei 3D
        X = (u_mat(r,c) - cu) * Z / f;
        Y = (v_mat(r,c) - cv) * Z / f;

        X_3d(k) = X;
        Y_3d(k) = Y;
        Z_3d(k) = Z;
        gri(k)  = double(I_left(r,c)) / 255;
    end

    % Elimina punctele nule
    valid = Z_3d > 0;
    X_3d = X_3d(valid);
    Y_3d = Y_3d(valid);
    Z_3d = Z_3d(valid);
    gri  = gri(valid);

    % --- 5.6 Estimarea distantei
    Z_medie = mean(Z_3d);
    Z_min   = min(Z_3d);

    fprintf('Pieton %-4d  %.4f            %.2f m       %.2f m\n', ...
        i, scores(i), Z_medie, Z_min);

    % --- 5.7 Vizualizare 3D cu plot3
    figure('Name', sprintf('plot3 - Pieton %d', i), 'NumberTitle', 'off');
    scatter3(X_3d, Z_3d, -Y_3d, 3, gri, 'filled');
    colormap(gray);
    xlabel('X [m]'); ylabel('Z - Adancime [m]'); zlabel('-Y [m]');
    title(sprintf('Reconstructie 3D plot3 - Pieton %d | Distanta medie: %.2f m', i, Z_medie));
    grid on; axis equal; view([-30, 20]);

    % --- 5.8 Vizualizare 3D cu pcshow
    figure('Name', sprintf('pcshow - Pieton %d', i), 'NumberTitle', 'off');
    culori_rgb = repmat(gri, 1, 3);
    pc = pointCloud([X_3d, Z_3d, -Y_3d], 'Color', single(culori_rgb));
    pcshow(pc);
    xlabel('X [m]'); ylabel('Z [m]'); zlabel('-Y [m]');
    title(sprintf('Reconstructie 3D pcshow - Pieton %d | Distanta medie: %.2f m', i, Z_medie));

end

fprintf('\n=== SFARSIT LABORATOR ===\n');