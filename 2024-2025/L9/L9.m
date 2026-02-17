%% Detectarea unor piese metalice dreptunghiulare - Studiu de caz
clear, close all;

%% Pas 1: Citirea si afisarea imaginii
[J] = imread('PieseO.bmp');
figure, imshow(J), title('imaginea initiala');

%% Pas 2: Transformarea formatului imaginii intr-o imagine grayscale
I = rgb2gray(J);
% I = uint8(I*255);
figure, imshow(I), title('transformarea formatului imaginii - imaginea grayscale')

%% Pas 3: Afisarea histogramei imaginii grayscale
figure, imhist(uint8(I)), title('histograma imaginii')

%% Pas 4: Calcularea nivelului de prag pentru segmentare
prag = graythresh(I);

%% Pas 5: Segmentarea imaginii
BW = im2bw(I, prag);
str = sprintf('segmentarea imaginii - imaginea binarizata cu pragul %.1f', prag*255);
figure, imshow(BW), title(str);

%% Pas 6: Eliminarea regiunilor mici folosind operatia morfologica de
% deschidere - se foloseste ca obiect morfologic, un patrat de latura 5
se = strel('square',5);
BWopen = imopen(BW,se);
figure, imshow(BWopen), title('eliminarea regiunilor mici - deschiderea imaginii folosind un patrat de latura 5')

%% Pas 7: Calcularea frontierelor regiunilor si afisarea acestora
BWperim = bwperim(BWopen, 8);
figure, imshow(BWperim), title('perimetrele regiunilor obtinute')

%% Pas 8: Afisarea frontierelor obtinute peste imaginea initiala pentru evaluarea
% intermediara a rezultatelor - se foloseste o nuanta de rosu pentru frontiere
% I8 = uint8(I);
% I8 = imadd(I8, -1);
Iperim = imadd(I, uint8(double(BWperim*255)));
map = gray(255);
map(255, :)=[1 0 0];
figure, imshow(Iperim, map);

% Pas 8.5: Afisarea regiunilor in culori diferite
[L, nrObiecte] = bwlabel(BWopen, 8);
pseudo_color = label2rgb(L, @jet, 'c', 'shuffle');
figure, imshow(pseudo_color);

%% Pas 9: Calcularea proprietatilor regiunilor
prop = regionprops(L,'all');

%% Pas 10: initializarea vectorului de trasaturi
% coloana 1: aria, 
% coloana 2: perimetrul, 
% coloana 3: compactitatea, 
% coloana 4: lungimea axei mari, 
% coloana 5: lungimea axei mici,
% coloana 6: excentricitatea 
trasaturi = zeros(nrObiecte, 6);

% Pas 11: atribuirea valorilor trasaturilor
% coloana 1: aria, 
trasaturi(:, 1)=[prop.Area]';
% for k = 1:nrObiecte, 
%     trasaturi(k, 1)=bwarea(prop(k).Image);
% end

% coloana 2: perimetrul
for k = 1:nrObiecte 
    bw4 = bwperim(prop(k).Image, 4);
    bw8 = bwperim(prop(k).Image, 8);
    trasaturi(k, 2)=sqrt(2)*sum(bw8(:)) + (1-sqrt(2))*sum(bw4(:));
end

% coloana 3: compactitatea
for k = 1:nrObiecte 
    trasaturi(k, 3)=trasaturi(k, 2)^2 / trasaturi(k, 1);
end

% coloana 4: lungimea axei mari 
trasaturi(:, 4)=[prop.MajorAxisLength]';

% coloana 5: lungimea axei mici,
trasaturi(:, 5)=[prop.MinorAxisLength]';
% coloana 6: excentricitatea 
trasaturi(:, 6)=[prop.Eccentricity]';
trasaturi_tr = trasaturi;
% Pas 13: stabilirea modelului, stiind ca toate obiectele din imagine sunt identice
model = mean(trasaturi);
pause

%% Pas 14: Aplicarea pasilor 1-12 pentru imaginea 2
[J] = imread('piese.jpg');
figure, imshow(J), title('imaginea initiala');
I = rgb2gray(J);
figure, imshow(I), title('transformarea formatului imaginii - imaginea grayscale')
figure, imhist(uint8(I)), title('histograma imaginii')
prag = graythresh(I);
BW = im2bw(I, prag);
str = sprintf('segmentarea imaginii - imaginea binarizata cu pragul %.1f', prag*255);
figure, imshow(BW), title(str);
se = strel('square',5);
BWopen = imopen(BW,se);
figure, imshow(BWopen), title('eliminarea regiunilor mici - deschiderea imaginii folosind un patrat de latura 5')
BWperim = bwperim(BWopen, 8);
figure, imshow(BWperim), title('perimetrele regiunilor obtinute')
I8 = uint8(I);
I8 = imadd(I8, -1);
Iperim = imadd(I8, uint8(BWperim*255));
map = gray(255);
map(255, :)=[1 0 0];
figure, imshow(Iperim, map);
[L, nrObiecte] = bwlabel(BWopen, 8);
pseudo_color = label2rgb(L, @spring, 'c', 'shuffle');
figure, imshow(pseudo_color);
prop = regionprops(L,'all');
trasaturi = zeros(nrObiecte, 6);
trasaturi(:, 1)=[prop.Area]';
for k = 1:nrObiecte
    bw4 = bwperim(prop(k).Image, 4);
    bw8 = bwperim(prop(k).Image, 8);
    trasaturi(k, 2)=sqrt(2)*sum(bw8(:)) + (1-sqrt(2))*sum(bw4(:));
end
for k = 1:nrObiecte
    trasaturi(k, 3)=trasaturi(k, 2)^2 / trasaturi(k, 1);
end
trasaturi(:, 4)=[prop.MajorAxisLength]';
trasaturi(:, 5)=[prop.MinorAxisLength]';
trasaturi(:, 6)=[prop.Eccentricity]';


% Pas 15: calcularea si afisarea erorilor relative
err = zeros(size(trasaturi));
for k = 1:size(trasaturi, 1)
    % err(k, :) = trasaturi(k,:) - model;
    for j = 1:size(trasaturi, 2)
        err(k,j)=100*abs(trasaturi(k,j) - model(j))/model(j);
    end
end
err