function numarabomboane(imagine_path)
% NUMARABOMBOANE - Numara bomboanele M&M din imagine dupa culoare
%
% Utilizare:
%   numarabomboane('MM1.jpg')

    % ---------------------------------------------------------------
    % 1. Citire imagine si conversie HSV
    % ---------------------------------------------------------------
    img = imread(imagine_path);
    hsv = rgb2hsv(im2double(img));

    H = hsv(:,:,1);
    S = hsv(:,:,2);
    V = hsv(:,:,3);

    % ---------------------------------------------------------------
    % 2. Parametri morfologici scalati dupa rezolutia imaginii
    %    O bomboana ocupa ~5.5% din latura mica a imaginii
    % ---------------------------------------------------------------
    [nr, nc, ~] = size(img);
    raza = round(min(nr, nc) * 0.055);

    se_inchidere = strel('disk', round(raza * 0.20));
    se_erodare   = strel('disk', round(raza * 0.25));

    aria_min = pi * (raza * 0.12)^2;
    aria_max = pi * (raza * 1.00)^2;

    % ---------------------------------------------------------------
    % 3. Segmentare pe culori folosind praguri HSV
    %    H in [0,1] corespunde la [0, 360] grade
    %    Maro definit primul si exclus din Rosu/Portocaliu
    % ---------------------------------------------------------------
    mask_maro       = (H <  0.10) & (S > 0.15) & (S < 0.65) & (V > 0.08) & (V < 0.48);
    mask_rosu       = ((H < 0.03) | (H > 0.97)) & (S > 0.28) & (V > 0.22) & ~mask_maro;
    mask_portocaliu = (H >= 0.03) & (H < 0.09)  & (S > 0.40) & (V > 0.38) & ~mask_maro;
    mask_galben     = (H >= 0.09) & (H < 0.20)  & (S > 0.35) & (V > 0.35);
    mask_verde      = (H >= 0.24) & (H < 0.46)  & (S > 0.30) & (V > 0.20);
    mask_albastru   = (H >= 0.54) & (H < 0.73)  & (S > 0.28) & (V > 0.15);

    nume_culori  = {'Rosu', 'Portocaliu', 'Galben', 'Verde', 'Albastru', 'Maro'};
    masti_culori = {mask_rosu, mask_portocaliu, mask_galben, ...
                    mask_verde, mask_albastru, mask_maro};
    culori_plot  = {[1 0 0], [1 0.5 0], [0.85 0.85 0], ...
                    [0 0.8 0], [0.1 0.4 1], [0.5 0.25 0]};

    % ---------------------------------------------------------------
    % 4. Procesare per culoare si afisare rezultate
    % ---------------------------------------------------------------
    figure('Name', 'Bomboane detectate', 'NumberTitle', 'off');
    subplot(1,2,1); imshow(img); title('Imagine originala');
    subplot(1,2,2); imshow(img); hold on; title('Bomboane detectate');

    total = 0;

    fprintf('\n%-15s | Numar\n', 'Culoare');
    fprintf('%s\n', repmat('-', 1, 23));

    for i = 1:numel(nume_culori)

        % Curatare masca si separare bomboane lipite prin erodare
        m = imclose(masti_culori{i}, se_inchidere);
        m = imfill(m, 'holes');
        m = imerode(m, se_erodare);

        % Detectie componente conexe cu BoundingBox
        cc    = bwconncomp(m);
        props = regionprops(cc, 'Area', 'BoundingBox');

        numar = 0;
        for k = 1:cc.NumObjects
            if props(k).Area >= aria_min && props(k).Area <= aria_max
                numar = numar + 1;

                % Deseneaza bounding box si eticheta
                bb = props(k).BoundingBox;
                % bb = [x, y, latime, inaltime] - coltul stanga-sus
                % Compensam erodarea: extindem bbox cu raza_erodare
                offset = round(raza * 0.25);
                x = bb(1) - offset;
                y = bb(2) - offset;
                w = bb(3) + 2 * offset;
                h = bb(4) + 2 * offset;

                rectangle('Position', [x, y, w, h], ...
                          'EdgeColor', culori_plot{i}, ...
                          'LineWidth', 2);
                text(x, y - 5, nume_culori{i}, ...
                     'Color', culori_plot{i}, ...
                     'FontWeight', 'bold', 'FontSize', 8);
            end
        end

        fprintf('%-15s | %d\n', nume_culori{i}, numar);
        total = total + numar;
    end

    fprintf('%s\n', repmat('-', 1, 23));
    fprintf('%-15s | %d\n\n', 'TOTAL', total);
    hold off;

end