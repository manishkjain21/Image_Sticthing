clc;
close all;
clear all;

%% The below code compares the value of two images and matches the pattern
% to another one. Using the shift in the same  pattern, we can determine
% the position of foloowing image patches

KE = 200;
a = 1;  %von x Anfang  (von links aus betrachtet!)
b = 100;  %von y Anfang  (von oben aus betrachtet!)
c = 1696;  %Breite        (Breite des Bildes)
d = 500;  %Höhe          (Höhe des Bildes)

crop_area = [a b c d];
Startbild = 1;
fontSize = 16;

%% Directory Settings
directory = 'D:\Germany\Studies\HiWi\TTD\Image_Stitch';

% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(directory,'*.bmp'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enthält:
    error('Der directory enthält keine Datei im bmp-Format.') % Fehlerausschrift anzeigen
end

%------------------ directory ERSTELLEN --------------------------------------

% Ergebnisse
O_Ergebnisse = strcat(directory, '\Ergebnisse');
if ~exist(O_Ergebnisse,'dir');      % überprüfen, ob Unterdirectory existiert; wenn nicht -dann:
    mkdir(O_Ergebnisse);            % Unterdirectory erstellen
end

% Bilder 
O_Bilder = strcat(directory, '\Ergebnisse\Bilder');
if ~exist(O_Bilder,'dir');      
    mkdir(O_Bilder);  
end

% Cropped 
O_Filtered = strcat(directory, '\Ergebnisse\Filtered');
if ~exist(O_Filtered,'dir');      
    mkdir(O_Filtered);  
end

% Cropped 
O_Cropped = strcat(directory, '\Ergebnisse\Cropped');
if ~exist(O_Cropped,'dir');      
    mkdir(O_Cropped);  
end

% Daten 
O_Daten = strcat(directory, '\Ergebnisse\Daten');
if ~exist(O_Daten,'dir');      
    mkdir(O_Daten);   
end

% Plots 
O_Plots = strcat(directory, '\Ergebnisse\Plots');
if ~exist(O_Plots,'dir');      
    mkdir(O_Plots);   
end

%% Save all the images in directory as Intensity Images so that we can later you them for joining and filtering
%% Directory Settings
directory = 'D:\Germany\Studies\HiWi\TTD\Image_Stitch';

% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(directory,'*.bmp'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enthält:
    error('Der directory enthält keine Datei im bmp-Format.') % Fehlerausschrift anzeigen
end

for range = Startbild:length(Names)
    %Read a File and Crop the Required area
    filename = strcat(directory,'\', Names(range).name);
    input = imread(filename);
    % Crop the image for Flow
    cropped = imcrop(input, crop_area);
    cropped_filtered = image_filtering(cropped);
    % Display the name of the reference image
    [Pfad,DateiVorname,Erweiterung] = fileparts(filename);
    disp(['Aktuelles Bild : ', filename]);
    % Write the images to Directory
    SpeichernName = strcat(O_Filtered,'\',strcat(DateiVorname, '_filtered.png'));
    imwrite(cropped_filtered,SpeichernName);
    
end

%% Read a File and Crop the Required area

filename = strcat(directory,'\', Names(Startbild).name);
input = imread(filename);
% Crop the image for Flow
cropped1 = imcrop(input, crop_area);
% Display the name of the reference image
[Pfad,DateiVorname,Erweiterung] = fileparts(filename);
disp(['Aktuelles Bild : ', filename]);
% The below part opens up and image and then a part of the flow can be
% selected to track. It is recommend that entire height of the shown image
% be selected to compensate for the irregularity in the height of flow over
% time

imshow(cropped1);
axis on;
title('Original Image', 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
uiwait(msgbox(message));
rect = int16(getrect);
close all;
x_init = rect(1);
y_init = rect(2);
width = rect(3);
height = rect(4);

Ref_Area = cropped1(y_init:y_init+height-1, x_init:x_init+width-1);
figure, imshow(Ref_Area);
% The below image matrix can be used for final image stitching
Ref_Area = image_filtering(Ref_Area);
SpeichernName = strcat(O_Cropped,'\',strcat(DateiVorname, '_refarea.png'));
imwrite(Ref_Area,SpeichernName);

ref_dimensions = [x_init y_init width-1 height-1];

%% The below loop continuously takes 2 images and compares them for same parts 
% This helps to identify the correct region in each image

directory_fil = strcat(directory, '\Ergebnisse\Filtered');

% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(directory_fil,'*.png'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enthält:
    error('Der directory enthält keine Datei im png-Format.') % Fehlerausschrift anzeigen
end

region_dimensions = zeros(length(Names)-1, 1, 4);

%% 
total_width = width;

for range = Startbild : length(Names)-1
    filename = strcat(directory_fil,'\', Names(range).name);
    reference_image = imread(filename);
    reference_image = imcrop(reference_image, ref_dimensions);
       
    filename = strcat(directory_fil,'\', Names(range+1).name);
    test_image = imread(filename);
    
    corr_coef = normxcorr2(reference_image, test_image);
    
    [ypeak, xpeak] = find(corr_coef ==max(corr_coef(:)));
    yoffSet = ypeak-size(Ref_Area,1);
    xoffSet = xpeak-size(Ref_Area,2);
    [y,x] = size(ypeak);
    if (y+x) == 2 
        yoffSet = ypeak-size(Ref_Area,1);
        xoffSet = xpeak-size(Ref_Area,2);
    else 
        yoffSet = ypeak(1)-size(Ref_Area,1);
        xoffSet = xpeak(1)-size(Ref_Area,2);
    end

    x_begin = x_init;
    x_width = xoffSet-x_init;
    y_begin = y_init;
    y_height = height;
    
    total_width = x_width + total_width;
    region_dimensions(range,:,:) = [x_begin,y_begin,x_width-1,y_height-1];
    [Pfad,DateiVorname,Erweiterung] = fileparts(filename);
    SpeichernName = strcat(O_Cropped,'\',strcat(DateiVorname, '_refarea.png'));
    imwrite(imcrop(test_image, [x_begin,y_begin,width-1,y_height-1]),SpeichernName);
end

%% Read the Cropped filtered Images and join them using the top edge

directory_crop = strcat(directory, '\Ergebnisse\Cropped');
% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(directory_crop,'*.png'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enthält:
    error('Der directory enthält keine Datei im png-Format.') % Fehlerausschrift anzeigen
end
Startbild = 1;
total_width =0;
for range = Startbild : length(Names)
    filename = strcat(directory_crop,'\', Names(range).name);
    reference_image = imread(filename);
    [y, x] = size(reference_image);
    total_width = total_width + x;
end
y_height = y;
% Initialise the variable for Entire Image Dimensions
stitched_image = logical(zeros( 2*y_height, total_width));
width_covered=0;
y_shift_total = 0;
for range = length(Names):-1: 2
    % Read the Last Image as the start image
    filename = strcat(directory_crop,'\', Names(range).name);
    reference_image = imread(filename);
    [y1, x1] = size(reference_image);
    if(range == length(Names))
        for x_sweep = 1:x1
                for y_sweep = 1:y1
                    stitched_image( y_sweep, width_covered + x_sweep) = reference_image(y_sweep, x_sweep);
                end
        end
    end
    
    width_covered = width_covered + x1;
    y_right_flag = 0;
    count = 0;
    % Detect the white line
    for y_sweep = 1:y1
        if((reference_image(y_sweep, x1) == 1) && y_right_flag == 0) % Check for the white part
            y_right = y_sweep;
            y_right_flag = 1;
        end
        if(reference_image(y_sweep, x1) == 1) % Check for large white part
            count = count+1;
        end
%         if(count >= 15)
%             y_right = 0;
%             y_right_flag = 0;
%         end  
    end


    filename = strcat(directory_crop,'\', Names(range-1).name);
    test_image = imread(filename);
    [y2, x2] = size(test_image);

    y_left_flag = 0;
    count = 0;
    % Detect the white line
    for y_sweep = 1:y2
        if((test_image(y_sweep, 1) == 1) && y_left_flag == 0) % Check for the white part
            y_left = y_sweep;
            y_left_flag = 1;
        end
        if(test_image(y_sweep, 1) == 1) % Check for large white part
            count = count+1;
        end
%         if(count >= 15)
%             y_left = 0;
%             y_left_flag = 0;
%         end  
    end

    y_shift = y_right - y_left;
    
    y_shift_total = y_shift_total + y_shift;

    for x_sweep = 1:x2
            for y_sweep = 1:y2
                if(y_sweep+y_shift_total >=1 && y_sweep+y_shift_total <= 2*y2)
                    stitched_image( y_sweep+y_shift_total, width_covered + x_sweep) = test_image(y_sweep, x_sweep);
                end
            end
    end
    
end

[~,DateiVorname,~] = fileparts(filename);
SpeichernName = strcat(O_Cropped,'\',strcat(DateiVorname, '_cropped_part.bmp'));
imwrite(stitched_image,SpeichernName);


