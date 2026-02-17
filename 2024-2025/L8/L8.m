%% test bwlabel
original = imread('coins.png');
l = bwlabel(imbinarize(original), 4);
imshow(original);
hold on;
[r, c] = find(l == 17);
plot(c, r, '*');

%% test regionprops
original = imread('text.png');
l = regionprops(original, 'BoundingBox');
figure();
imshow(original); title('Original Image');
for i = 1:length(l)
    rectangle('Position',l(i).BoundingBox,'EdgeColor','red');  title('Label of image');
end

%% test bwselect
BW1 = imread('text.png');
c = [126 187 11];
r = [34 172 20];
BW2 = bwselect(BW1);
figure, imshow(BW1)
figure, imshow(BW2)

%%
folder = fileparts(which('cameraman.tif'));
