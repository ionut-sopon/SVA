I_left = imread('L2_left.png'); 
I_right = imread('L2_right.png'); 

% Calculul hartii de disparitate - metoda SemiGlobal 
dispMap = disparity(I_left, I_right, ... 
                    'Method', 'SemiGlobal', ... 
                    'DisparityRange', [0, 128], ... 
                    'UniquenessThreshold', 15); 

% Vizualizarea imaginilor originale
figure("NumberTitle","off");
subplot(2, 1, 1);
imshow(I_left);
subplot(2, 1, 2);
imshow(I_right);

% Vizualizare cu coalormap jet si colorbar 
figure("NumberTitle","off");
imshow(dispMap, [0 128]); 
colormap(jet); 
hcb = colorbar; 
hcb.Label.String = 'Disparitate [pixeli]'; 

% Adauga etichete pe colorbar pentru interpretare 
text(1.05, 0.05, '> 25 m (fundal)', 'Units','normalized', ... 
    'FontSize', 8, 'Color', 'b'); 
text(1.05, 0.35, '10-25 m (mijloc)', 'Units','normalized', ... 
    'FontSize', 8, 'Color', [0 0.6 0]); 
text(1.05, 0.65, '5-10 m (apropiat)', 'Units','normalized', ... 
    'FontSize', 8, 'Color', [0.8 0.6 0]); 
text(1.05, 0.90, '< 5 m (obstacol)', 'Units','normalized', ... 
    'FontSize', 8, 'Color', 'r'); 

title('Harta de Disparitate - valori mari = obiecte aproape');