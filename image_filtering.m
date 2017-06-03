function processed_image = image_filtering(unfiltered_image)
    % Parameters for Filtering the Image
    KE = 175;
    
    [y, x] = size(unfiltered_image);
    
    Kante1 = edge(unfiltered_image,'canny', .35);
    SE2 = strel('disk',2);              %Erzeugt eine Scheibe mit Radius 2
    Kante1 = imdilate(Kante1,SE2);
    Kante2(:,1)=1;
    Kante2(:,x)=1;
    
    %--------------------------- FÜLLEN ---------------------------------------
    Fill = imfill(Kante1,'holes');
    %----------------------- Kleine Elemente Ausblenden -----------------------
    filter_image = bwareaopen(Fill,KE);
   
    %s = regionprops(filter_image,'Perimeter');
    CC = bwconncomp(filter_image, 8); 
    %s = regionprops(CC,'basic');
    total = CC.NumObjects;
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [sortedValues,sortIndex] = sort(numPixels,'descend');
    % the below code outputs top 2 contuors
    maxIndex = sortIndex(1:2);
    for t = 1:total
        if t ~= maxIndex(1) && t~=maxIndex(2) 
            filter_image(CC.PixelIdxList{t}) = 0;
        end
    end
    processed_image = filter_image;

end
