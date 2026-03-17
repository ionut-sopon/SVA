original_image = imread("L5_image_03.png");
gray_image = rgb2gray(original_image);  %   imshow(gray_image)
img_c = imcomplement(gray_image);       %   imshow(img_c)
background = imopen(img_c,strel('disk',100'));  %   imshow(background)

work_data = imadjust(imsubtract(img_c,background));  %   imshow(work_data)
 
imge = edge(work_data,'Prewitt',0.03);  %   imshow(imge)
imge_beta = imclose(imge,strel('disk',10));   %   imshow(imge_beta) 
img_seg = imfill(imge_beta,'holes');   %   imshow(img_seg)
img_seg = imerode(img_seg,strel('disk',8)); %!!!!!!!!!!!   %   imshow(img_seg)


%% varianta 2 - obiectele si fundalul ca medie
img_label=bwlabel(img_seg);
label_set=unique(img_label);
img_last2=zeros(size(img_seg));
for i=1:numel(label_set)
    aux=(img_label==label_set(i));
    img_last2(aux)=uint8(mean(mean(gray_image(aux))));
end

final_image = uint8(img_last2);
figure;imshow(final_image);



