function processed_image = image_filtering_JR(A,blank,p)
% Parameters for Filtering the Image
KE = 150;

[y, x] = size(A);

%     [J,noise] = wiener2(unfiltered_image,[5 5]);
%     J = wiener2(unfiltered_image,[5 5],noise);
%% Diffbild
AA=double(A);
BB=double(blank);
CC=AA-BB;

mi=min(min(CC));
CC=CC-mi;
ma=max(max(CC));
C=CC/ma*255;
C=uint8(C);
C=imadjust(C);
[J,noise] = wiener2(C,[5 5]);
J = wiener2(C,[5 5],noise);
imshowpair(J,C,'montage')

%J=A;
%%
Kante1 = edge(J,'canny',p,0.9);
%     imshow(Kante1)%(1:241,1:800))
%%
SE2 = strel('disk',3);              %Erzeugt eine Scheibe mit Radius 2
%     SE2 = strel('line',10,0);
%     Kante2 = imdilate(Kante1,SE2);
%     imshow(Kante2)

Kante2 = imdilate(Kante1,SE2);
Kante2=[true(y,1) Kante2 true(y,1)];

%     imshow(Kante2)
%%
%--------------------------- FÜLLEN ---------------------------------------
Fill = imfill(Kante2,'holes');
%----------------------- Kleine Elemente Ausblenden -----------------------
filter_image = bwareaopen(Fill,KE);
%     imshowpair(Fill,Kante2,'montage')
% %     imshow(filter_image)
SE2 = strel('disk',2);              %Erzeugt eine Scheibe mit Radius
filter_image=imerode(filter_image,SE2);
%%
%     s = regionprops(filter_image,'Perimeter');
CC = bwconncomp(filter_image, 8);
%     s = regionprops(CC,'basic');
%     total = CC.NumObjects;
numPixels = cellfun(@numel,CC.PixelIdxList);
[sortedValues,sortIndex] = sort(numPixels,'descend');
% the below code outputs top 2 contuors
if sortedValues(1) >=  10000
    maxIndex = sortIndex(1);
    for t = 1:CC.NumObjects
        if sortedValues(t) <10000 %t~=maxIndex(1) && t~=maxIndex(2)
            filter_image(CC.PixelIdxList{sortIndex(t)}) = 0;
        end
    end
    processed_image=filter_image(:,2:(x+1));
    %
    processed_image=edge(processed_image,'canny', 0.3);
    
else
    maxIndex = sortIndex(1:2);
    for t = 1:CC.NumObjects
        if t ~= maxIndex(1) && t~=maxIndex(2)
            filter_image(CC.PixelIdxList{t}) = 0;
        end
    end
    processed_image=filter_image(:,2:(x+1));
    %         imshow(processed_image)
end
%     imshow(processed_image)
end


% function processed_image = image_filtering_JR(unfiltered_image)
%     % Parameters for Filtering the Image
%     KE = 175;
%
%     [y, x] = size(unfiltered_image);
%     %%
%     Kante1 = edge(unfiltered_image,'canny', 0.3);
% %     imshow(Kante1)%(1:241,1:800))
%     %%
%     SE2 = strel('disk',2);              %Erzeugt eine Scheibe mit Radius 2
% %     SE2 = strel('line',10,0);
%     Kante2 = imdilate(Kante1,SE2);
%
% %     imshow(Kante2)
%     %%
%
%     Kante2=[true(y,1) Kante2 true(y,1)];
%
% %     imshow(Kante2)
%     %%
%     %--------------------------- FÜLLEN ---------------------------------------
%     Fill = imfill(Kante2,'holes');
%     %----------------------- Kleine Elemente Ausblenden -----------------------
%     filter_image = bwareaopen(Fill,KE);
% %     imshowpair(Fill,Kante2)
% %     imshow(filter_image)
%     filter_image=imerode(filter_image,SE2);
%     %%
% %     s = regionprops(filter_image,'Perimeter');
%     CC = bwconncomp(filter_image, 8);
% %     s = regionprops(CC,'basic');
% %     total = CC.NumObjects;
%     numPixels = cellfun(@numel,CC.PixelIdxList);
%     [sortedValues,sortIndex] = sort(numPixels,'descend');
%     % the below code outputs top 2 contuors
%     maxIndex = sortIndex(1);
%     for t = 1:CC.NumObjects
%         if t ~= maxIndex(1) %&& t~=maxIndex(2)
%             filter_image(CC.PixelIdxList{t}) = 0;
%         end
%     end
%     processed_image=filter_image(:,2:(x+1));
% %     imshow(processed_image)
% processed_image=edge(processed_image,'canny', 0.2);
%
% end
