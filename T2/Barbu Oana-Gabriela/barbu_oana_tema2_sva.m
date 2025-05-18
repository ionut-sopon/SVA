img = imread('1305B_1306A.png');  %citesc imaginea si o stochez intr o variabila img
imshow(img)
title('imagine originala')

%conversia in alb-negru si binarizare
gray = rgb2gray(img);
bw = imbinarize(gray, 0.9); %binarizez imaginea grayscale; o transform in imagine alb-negru
                            %pixelii din gray cu o intensitate mai mare decat 0.9 
                            % (unde intensitatile sunt normalizate la intervalul [0, 1]) vor fi setati la 1 (alb) în bw, 
                            % iar cei cu o intensitate mai mica sau egala vor fi setati la 0 (negru). 
% inversez bw: formele sa fie albe, iar fundalul negru
bw = ~bw;

% identific si etichetez formele individuale
[L, num] = bwlabel(bw);  %L- matrice etichetata unde fiecare pixel al unei forme are aceeasi valoare
                         %num-  numarul de forme detectate
stats = regionprops(L, 'Centroid', 'Area', 'Perimeter', 'BoundingBox', 'Eccentricity');
%calculeaza proprietati pentru fiecare regiune etichetata din matricea L
%centroid: coordonatele centrului fiecarei forme gasite
%area: nr de pixeli din fiecare regiune
%perimeter: lungimea conturului fiecarei regiuni
%boundingbox: dreptunghiul minim care inconjoara fiecare regiune
%eccentricity: excentricitatea elipsei (masoara cat de alungita este forma)

for k = 1:num                                % iterare pentru fiecare forma detectata
    mask = (L == k);                         % creeaza o masca binara pentru forma curenta (pixelii formei 'k' sunt 1 si restul 0)
    B = bwboundaries(mask);                  % gaseste contururile formei
    boundary = B{1};                         % extrage primul contur

    % simplificare contur pentru varfuri
    simplificare = reducepoly(boundary, 0.03); % reduce nr de puncte de pe contur pentru a aproxima varfurile
                                               % 0.3 este gradul de simplificare
    num_varfuri = size(simplificare, 1) - 1;   % nrul de varfuri este nr de randuri din conturul deja simplificat minus 1

    % masuratori
    area = stats(k).Area;                   % obtine aria formei din structura 'stats'
    perimeter = stats(k).Perimeter;         % obtine perimetrul formei curente din structura 'stats'
    circularity = (4 * pi * area) / (perimeter^2); % calculeaza circularitatea
    bb = stats(k).BoundingBox;             % obtine dreptunghiul care incadreaza forma
    centroid = stats(k).Centroid;           % obtine centrul formei
    ratio = bb(3) / bb(4);                   % calculeaza raportul latime/inaltime al dreptunghiului care incadreaza forma

    % clasificare forma
    if num_varfuri == 3                     % daca forma are 3 varfuri este probabil sa fie triunghi
        shape = 'triunghi';
    elseif num_varfuri == 4                 % daca forma are 4 varfuri ar putea fi patrat, dreptunghi sau romb
        
        % analizez laturile si unghiurile cu ajutorul conturului simplificat 
        pts = simplificare(1:4, :);       % extrag cele 4 varfuri
        v1 = pts(2,:) - pts(1,:);         % vector pentru prima latura
        v2 = pts(3,:) - pts(2,:);         % vector pentru a 2a latura
        v3 = pts(4,:) - pts(3,:);         % vector pentru a 3a latura
        v4 = pts(1,:) - pts(4,:);         % vector pentru a 4a latura

        %calculez lungimile laturilor
	    l1 = norm(v1); 
	    l2 = norm(v2); 
	    l3 = norm(v3); 
	    l4 = norm(v4); 
        ang1 = acosd(dot(v1, v2) / (l1 * l2)); % calculeaza unghiul dintre prima și a 2a latura 
        ang2 = acosd(dot(v2, v3) / (l2 * l3)); % calculeaza unghiul dintre a 2a si a 3a latura

        if abs(ang1 - 90) < 10 && abs(ang2 - 90) < 10 % daca unghiurile sunt apropiate de 90 de grade
            if abs(ratio - 1) < 0.15          % daca raportul latime/inaltime este apropiat de 1 este patrat
                shape = 'patrat';
            else                               
                shape = 'dreptunghi';
            end
        else                                   % daca unghiurile nu sunt apropiate de 90 de grade este probabil un romb
            shape = 'romb';
        end
    elseif num_varfuri >= 10 && circularity < 0.65 % daca are multe varfuri și circularitatea este mica este probabil o stea
        shape = 'stea';
    elseif circularity > 0.7                 % daca circularitatea este mare ar putea fi ori cerc ori elipsa
        if stats(k).Eccentricity < 0.6      % daca excentricitatea este mica ar trebui sa fie un cerc 
            shape = 'cerc';
        else                                  
            shape = 'elipsa';
        end
    else                                     
        shape = 'alta forma';
    end

    % adnotari pe imagine
    rectangle('Position', bb, 'EdgeColor', 'red', 'LineWidth', 2); % deseneaza un dreptunghi rosu în jurul formei
    text(centroid(1), centroid(2), shape, 'Color', 'black','FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
            %adauga textul cu numele fiecarei forme 
end