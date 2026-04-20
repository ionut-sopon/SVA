%% LABORATOR - Estimarea vitezei vehiculelor cu stereoviziune
%  Sisteme de Vedere Artificiala 2024/2025
%
%  Principiu:
%   1. Detectam vehicule in frame-ul t si frame-ul t+5
%   2. Calculam pozitia 3D a fiecarui vehicul in ambele frame-uri
%   3. Viteza = distanta 3D parcursa / dt
%
%  Imagini necesare (4 fisiere in acelasi folder cu scriptul):
%   frame_t_L.png   -> imaginea stanga  la momentul t
%   frame_t_R.png   -> imaginea dreapta la momentul t
%   frame_t5_L.png  -> imaginea stanga  la momentul t+5
%   frame_t5_R.png  -> imaginea dreapta la momentul t+5
%
%  Parametri KITTI: f=721.54, cu=609.56, cv=172.85, b=0.5327
%  Framerate KITTI: 10 fps -> cele doua frame-uri sunt la dt=0.5s distanta

clc; clear; close all;

%% =========================================================
%  PASUL 1 - Parametrii sistemului
%% =========================================================

% Parametrii camerei stereo KITTI
f  = 721.5377;
cu = 609.5593;
cv = 172.8540;
b  = 0.5327;

% Intervalul de timp dintre cele doua frame-uri extrase
% KITTI filmeaza la 10 fps, frame-urile sunt la 5 cadre distanta
dt = 0.5;   % [secunde]  !!! NU sunt f sigur ca sunt 5 cadre distanta

fprintf('=== ESTIMARE VITEZA VEHICULE ===\n');
fprintf('dt intre frame-uri: %.1f secunde\n\n', dt);

%% =========================================================
%  PASUL 2 - Citirea imaginilor stereo
%  Pune cele 4 imagini in acelasi folder cu scriptul
%% =========================================================

IL_t_color  = imread('frame_t_L.png');
IR_t_color  = imread('frame_t_R.png');
IL_t5_color = imread('frame_t5_L.png');
IR_t5_color = imread('frame_t5_R.png');

IL_t  = rgb2gray(IL_t_color);
IR_t  = rgb2gray(IR_t_color);
IL_t5 = rgb2gray(IL_t5_color);
IR_t5 = rgb2gray(IR_t5_color);

[m, n] = size(IL_t);
 
% Afisare comparativa a celor doua frame-uri
figure('Name', 'Frame t vs Frame t+5', 'NumberTitle', 'off');
subplot(1,2,1); imshow(IL_t_color);
title('Frame t');
subplot(1,2,2); imshow(IL_t5_color);
title(sprintf('Frame t+5 (dt = %.1f s)', dt));
 
%% =========================================================
%  PASUL 3 - Calculul hartilor de disparitate
%% =========================================================
 
disparityRange = [0, 128];
 
fprintf('Calculez harta de disparitate pentru frame t...\n');
dispMap_t = disparity(IL_t, IR_t, ...
    'Method',              'SemiGlobal', ...
    'DisparityRange',      disparityRange, ...
    'UniquenessThreshold', 15);
 
fprintf('Calculez harta de disparitate pentru frame t+5...\n');
dispMap_t5 = disparity(IL_t5, IR_t5, ...
    'Method',              'SemiGlobal', ...
    'DisparityRange',      disparityRange, ...
    'UniquenessThreshold', 15);
 
% Vizualizare harti de disparitate
figure('Name', 'Harti de disparitate', 'NumberTitle', 'off');
subplot(1,2,1);
imshow(dispMap_t, disparityRange); colormap(gca, jet); colorbar;
title('Harta disparitate - Frame t');
subplot(1,2,2);
imshow(dispMap_t5, disparityRange); colormap(gca, jet); colorbar;
title('Harta disparitate - Frame t+5');
 
%% =========================================================
%  PASUL 4 - Detectia vehiculelor in cele doua frame-uri
%% =========================================================
 
detector = vehicleDetectorACF();
 
fprintf('\nDetectez vehicule in frame t...\n');
[bboxes_t,  scores_t]  = detect(detector, IL_t_color,  'MinSize', [50, 50]);

[~, idx_best] = max(scores_t);
bboxes_t  = bboxes_t(idx_best, :);
scores_t  = scores_t(idx_best);
 
fprintf('Detectez vehicule in frame t+5...\n');
[bboxes_t5, scores_t5] = detect(detector, IL_t5_color, 'MinSize', [50, 50]);

[~, idx_best1] = max(scores_t5);
bboxes_t5  = bboxes_t5(idx_best1, :);
scores_t5  = scores_t5(idx_best1);
 
fprintf('Vehicule detectate in frame t   : %d\n', size(bboxes_t,  1));
fprintf('Vehicule detectate in frame t+5 : %d\n', size(bboxes_t5, 1));
 
% Vizualizare detectii in ambele frame-uri
figure('Name', 'Detectie vehicule', 'NumberTitle', 'off');
subplot(1,2,1);
imshow(IL_t_color); hold on;
for i = 1:size(bboxes_t,1)
    rectangle('Position', bboxes_t(i,:), 'EdgeColor', 'g', 'LineWidth', 2);
    text(bboxes_t(i,1), bboxes_t(i,2)-5, sprintf('V%d', i), ...
        'Color', 'g', 'FontWeight', 'bold', 'FontSize', 10);
end
title(sprintf('Frame t - %d vehicule', size(bboxes_t,1))); hold off;
 
subplot(1,2,2);
imshow(IL_t5_color); hold on;
for i = 1:size(bboxes_t5,1)
    rectangle('Position', bboxes_t5(i,:), 'EdgeColor', 'y', 'LineWidth', 2);
    text(bboxes_t5(i,1), bboxes_t5(i,2)-5, sprintf('V%d', i), ...
        'Color', 'y', 'FontWeight', 'bold', 'FontSize', 10);
end
title(sprintf('Frame t+5 - %d vehicule', size(bboxes_t5,1))); hold off;
 
%% =========================================================
%  PASUL 5 - Asocierea vehiculelor intre cele doua frame-uri
%  (IoU matching - Intersection over Union)
%% =========================================================
 
% Asociem fiecare vehicul din frame t cu cel mai apropiat din frame t+5
% folosind centrul bounding box-ului ca criteriu de proximitate
 
nV_t  = size(bboxes_t,  1);
nV_t5 = size(bboxes_t5, 1);
 
% Calculam centrele bounding box-urilor
centers_t  = [bboxes_t(:,1)  + bboxes_t(:,3)/2,  bboxes_t(:,2)  + bboxes_t(:,4)/2];
centers_t5 = [bboxes_t5(:,1) + bboxes_t5(:,3)/2, bboxes_t5(:,2) + bboxes_t5(:,4)/2];
 
% Pentru fiecare vehicul din t, gasim cel mai apropiat din t+5
perechi = [];   % [idx_t, idx_t5]
 
for i = 1:nV_t
    distante = sqrt( (centers_t5(:,1) - centers_t(i,1)).^2 + ...
                     (centers_t5(:,2) - centers_t(i,2)).^2 );
    [dist_min, idx_min] = min(distante);
 
    % Acceptam asocierea doar daca centrul nu s-a deplasat prea mult in imagine
    % (mai mult de 200px inseamna probabil alt vehicul)
    if dist_min < 200
        perechi = [perechi; i, idx_min, dist_min];
    end
end
 
fprintf('\nPerechi de vehicule asociate intre frame-uri: %d\n', size(perechi,1));
 
%% =========================================================
%  PASUL 6 - Calculul pozitiei 3D si estimarea vitezei
%% =========================================================
 
[u_mat, v_mat] = meshgrid(1:n, 1:m);
 
fprintf('\n%-10s %-15s %-15s %-15s %-15s\n', ...
    'Vehicul', 'Z_t [m]', 'Z_t5 [m]', 'dZ [m]', 'Viteza [km/h]');
fprintf('%s\n', repmat('-', 1, 70));
 
% Figura pentru vizualizarea traiectoriei 3D
figure('Name', 'Pozitii 3D si viteze', 'NumberTitle', 'off');
hold on; grid on;
xlabel('X [m]'); ylabel('Z - Adancime [m]');
title('Pozitia 3D a vehiculelor in frame t (verde) si t+5 (galben)');
view(0, 90);
 
viteze = zeros(size(perechi,1), 1);
 
for k = 1:size(perechi,1)
 
    idx_t  = perechi(k,1);
    idx_t5 = perechi(k,2);
 
    % --- Pozitia 3D in frame t ---
    pos3D_t = calculeaza_centru_3D(bboxes_t(idx_t,:), dispMap_t, ...
        u_mat, v_mat, m, n, f, cu, cv, b);
 
    % --- Pozitia 3D in frame t+5 ---
    pos3D_t5 = calculeaza_centru_3D(bboxes_t5(idx_t5,:), dispMap_t5, ...
        u_mat, v_mat, m, n, f, cu, cv, b);
 
    if isempty(pos3D_t) || isempty(pos3D_t5)
        fprintf('Vehicul %-4d -> date insuficiente pentru estimare\n', k);
        continue;
    end
 
    % --- Calculul vitezei ---
    % Distanta 3D parcursa intre cele doua frame-uri
    dX = pos3D_t5(1) - pos3D_t(1);
    dY = pos3D_t5(2) - pos3D_t(2);
    dZ = pos3D_t5(3) - pos3D_t(3);
 
    distanta_3D = sqrt(dX^2 + dY^2 + dZ^2);  % [metri]
 
    viteza_ms   = distanta_3D / dt;            % [m/s]
    viteza_kmh  = viteza_ms * 3.6;             % [km/h]
 
    viteze(k) = viteza_kmh;
 
    fprintf('Vehicul %-4d  %-15.2f %-15.2f %-15.2f %.1f km/h\n', ...
        k, pos3D_t(3), pos3D_t5(3), dZ, viteza_kmh);
 
    % Vizualizare pozitii in planul XZ
    plot(pos3D_t(1),  pos3D_t(3),  'go', 'MarkerSize', 12, 'LineWidth', 2);
    plot(pos3D_t5(1), pos3D_t5(3), 'yo', 'MarkerSize', 12, 'LineWidth', 2);
    plot([pos3D_t(1), pos3D_t5(1)], [pos3D_t(3), pos3D_t5(3)], ...
        'w-', 'LineWidth', 1.5);
    text(pos3D_t(1), pos3D_t(3)+0.5, sprintf('V%d: %.0f km/h', k, viteza_kmh), ...
        'Color', 'cyan', 'FontSize', 9, 'FontWeight', 'bold');
end
hold off;
 
%% =========================================================
%  PASUL 7 - Vizualizare finala cu vitezele pe imagini
%% =========================================================
 
figure('Name', 'Rezultat final - Viteze estimate', 'NumberTitle', 'off');
subplot(1,2,1);
imshow(IL_t_color); hold on;
title('Frame t');
 
subplot(1,2,2);
imshow(IL_t5_color); hold on;
title('Frame t+5 - Viteze estimate');
 
for k = 1:size(perechi,1)
    if viteze(k) == 0; continue; end
 
    idx_t  = perechi(k,1);
    idx_t5 = perechi(k,2);
 
    % Frame t - verde
    subplot(1,2,1);
    rectangle('Position', bboxes_t(idx_t,:), 'EdgeColor', 'g', 'LineWidth', 2);
 
    % Frame t+5 - cu viteza afisata
    subplot(1,2,2);
    bb = bboxes_t5(idx_t5,:);
    rectangle('Position', bb, 'EdgeColor', 'y', 'LineWidth', 2);
 
    % Eticheta viteza
    label = sprintf('%.0f km/h', viteze(k));
    text(bb(1), bb(2)-8, label, ...
        'Color', 'yellow', 'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0 0 0 0.5]);
end
 
hold off;
 
fprintf('\n=== SFARSIT ===\n');
 
