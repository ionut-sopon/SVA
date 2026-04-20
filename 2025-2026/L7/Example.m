%% 1) Crearea imaginii și plasarea celor 5 puncte
% Creăm o imagine binară de 200 x 200
BW = zeros(200, 200);
% Definim coordonatele a 5 puncte coliniare pe dreapta y = x
puncte = [10, 10;
         50, 50;
         100, 100;
         150, 150;
         190, 190];
% Plasăm punctele în imagine
for i = 1:size(puncte, 1)
   BW(puncte(i,1), puncte(i,2)) = true;
end

imshow(BW);
%% 2) Aplicarea transformatei Hough
% Calculăm matricea acumulator (H), vectorul de unghiuri (theta) și distanțele (rho)
[H, theta, rho] = hough(BW);
% Vizualizăm acumulatorul
figure;
imshow(imcomplement(imadjust(rescale(H))), 'XData', theta, 'YData', rho, 'InitialMagnification', 'fit');
title('Acumulatorul Hough cu vârful detectat');
xlabel('\theta (grade)');
ylabel('\rho (pixeli)');
% colormap(cool);
axis on; axis normal;
hold on;

%% 3) Detectarea vârfurilor cu houghpeaks
% Căutăm 1 singur vârf (NumPeaks = 1), deoarece avem o singură dreaptă
P = houghpeaks(H, 1);
% Extragem coordonatele vârfului pentru a-l desena pe acumulator
theta_peak = theta(P(:,2));
rho_peak = rho(P(:,1));
% Marcăm vârful pe acumulator cu un pătrat alb
plot(theta_peak, rho_peak, 's', 'color', 'white', 'LineWidth', 2, 'MarkerSize', 10);
hold off;

%% 4) Extragerea segmentelor cu houghlines și suprapunerea pe imagine
lines = houghlines(BW, theta, rho, P, 'FillGap', 75, 'MinLength', 10);
% Afișăm imaginea originală
figure;
imshow(BW);
title('Linia detectată suprapusă peste punctele originale');
hold on;
% Desenăm linia/liniile detectate
for k = 1:length(lines)
   % Extragem coordonatele capetelor segmentului
   xy = [lines(k).point1; lines(k).point2];
  
   % Trasăm linia (cu roșu)
   plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'red');
  
   % Marcăm capetele segmentului (cu galben)
   plot(xy(1,1), xy(1,2), 'x', 'Color', 'yellow', 'MarkerSize', 8);
   plot(xy(2,1), xy(2,2), 'x', 'Color', 'yellow', 'MarkerSize', 8);
end
hold off;
