im1 = imread('Images/L10_image_04.png');  %de modificat
gray = rgb2gray(im1);


[rows, columns] = size(gray);
roi = gray(floor(rows/2):end, :);

% gaussian blur - optional; voiam doar sa vad daca reusesc sa scot putin
% din zgomot
blurred = imgaussfilt(roi, 2);

% edge detection - am mers doar cu canny; nu am testat celelalte metode
edges = edge(blurred, 'canny');

% Hough Transform
[H, theta, rho] = hough(edges);
peaks = houghpeaks(H, 5, 'threshold', ceil(0.5*max(H(:))));
lines = houghlines(edges, theta, rho, peaks, 'FillGap', 50, 'MinLength', 100);

% Plot pe imaginea originala
figure, imshow(im1), hold on
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];

    % un filtru pentru liniile orizontale (nu ar trebui sa fie benzi de
    % circulatie..
    angle = atan2(xy(2,2) - xy(1,2), xy(2,1) - xy(1,1)) * 180 / pi;
    if abs(angle) < 85 && abs(angle) > 30 % valori euristice

        % ajustarea coordonatelor liniilor pe coordonatele din imaginea originala
        xy(:,2) = xy(:,2) + floor(rows/2);

        % plotare linii pe imaginea originala
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');

        % plotare inceput si sfarsit linii - optional
        plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
        plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
    end
end
hold off

%% P1
i1 = imread('Images/building.tif');
% figure;imshow(i1);
is = edge(i1,'sobel');
ip = edge(i1,'prewitt');
ir = edge(i1,'roberts');
ic = edge(i1,'canny');
il = edge(i1,'log');
%% valori implicite
subplot(3,2,1)
imshow(is);title('Muchii detectate cu Sobel');
subplot(3,2,2)
imshow(ip);title('Muchii detectate cu Prewitt');
subplot(3,2,3)
imshow(ir);title('Muchii detectate cu Roberts');
subplot(3,2,4)
imshow(ic);title('Muchii detectate cu Canny');
subplot(3,2,5)
imshow(il);title('Muchii detectate cu LoG');
%% valori schimbate

%% P2

%% P3

%% P4
im1 = imread('Images/L10_image_02.png');
im1 = rgb2gray(im1);
imp = edge(im1,'canny',0.1);
subplot(1,2,1)
imshow(imp);
title('imaginea canny');
% [H,theta,Ro]=hough(imp,'RhoResolution',0.5,'Theta',-90:0.5:89.5);
[H,theta,Ro] = hough(imp);
% V=houghpeaks(H,2,'threshold',ceil(0.3*max(H(:))));
V=houghpeaks(H,1);
% Lines=houghlines(imp,theta,Ro,V,'FillGap',10,'MinLength',25);
Lines = houghlines(imp,theta,Ro,V);
subplot(1,2,2)
hold on
imshow(im1);
for i=1:length(Lines)
    im = [Lines(i).point1; Lines(i).point2];
    plot(im(:,1),im(:,2),'LineWidth',3,'Color','red');
end
