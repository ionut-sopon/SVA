img = imread('test.png'); 
hsv = rgb2hsv(im2double(img)); 
H = hsv(:,:,1); 
S = hsv(:,:,2); 
V = hsv(:,:,3); 
% Masca pentru rosu: H aproape de 0 sau 1, saturatie si luminozitate ridicate 
mask_rosu = ((H < 0.03) | (H > 0.97)) & (S > 0.45) & (V > 0.30); 

% Verifica daca exista pixeli rosii in imagine 
if any(mask_rosu(:)) 
	fprintf('S-a detectat un obiect de culoare rosie.\n'); 
else 
	fprintf('Nu s-a detectat niciun obiect de culoare rosie.\n'); 
end 

% Vizualizare 
figure; 
subplot(1,2,1); imshow(img); title('Imagine originala'); 
subplot(1,2,2); imshow(mask_rosu); title('Masca rosu');