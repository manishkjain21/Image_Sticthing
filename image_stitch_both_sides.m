clc;
close all;
clear all;

%% The below code compares the value of two images and matches the pattern
% to another one. Using the shift in the same  pattern, we can determine
% the position of foloowing image patches
% Set the parameters for directory and No. of Images
%
KE = 200;
a = 1;  %von x Anfang  (von links aus betrachtet!)
b = 80;  %von y Anfang  (von oben aus betrachtet!)
c = 1328;  %Breite        (Breite des Bildes)
d = 440;  %H�he          (H�he des Bildes)
p = 0.1;
crop_area = [a b c d];
Startbild = 1;
Bilder_Vorgeben=true;
% Bilder_Vorgeben=false;
if Bilder_Vorgeben==true
    Startbild = 1;  % Set this parameter as per No. of Images in directory
    Endbild= 50;
end
fontSize = 16;

%% Referenzbild

blank=imread('D:\Germany\Studies\HiWi\TTD\Image_Stitch\HighSpeed\ld133\Blank.bmp');
blank=imcrop(blank, crop_area);

%% Directory Settings
directory = 'D:\Germany\Studies\HiWi\TTD\Image_Stitch\R_L';

% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(directory,'*.bmp'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enth�lt:
    error('Der directory enth�lt keine Datei im bmp-Format.') % Fehlerausschrift anzeigen
end

%------------------ directory ERSTELLEN --------------------------------------

% Ergebnisse
O_Ergebnisse = strcat(directory, '\Ergebnisse');
if ~exist(O_Ergebnisse,'dir');      % �berpr�fen, ob Unterdirectory existiert; wenn nicht -dann:
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
if ~exist(O_Plots,'dir')
    mkdir(O_Plots);
end

%% Save all the images in directory as Intensity Images so that we can later you them for joining and filtering
%% Directory Settings
if Bilder_Vorgeben==false
    Startbild=1;
    Endbild=length(Names);
end

for range = Startbild:Endbild
    %Read a File and Crop the Required area
    filename = strcat(directory,'\', Names(range).name);
    input = imread(filename);
    % Crop the image for Flow
    cropped = imcrop(input, crop_area);
    cropped_filtered = image_filtering_JR(cropped, blank, p);
    %       cropped_filtered = image_filtering_final(cropped);
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
% Ref_Area = image_filtering_final(Ref_Area);
%blank1 = imcrop(blank, crop_area);
blank1 = blank(y_init:y_init+height-1, x_init:x_init+width-1);
Ref_Area = image_filtering_JR(Ref_Area,blank1,p);
SpeichernName = strcat(O_Cropped,'\',strcat(DateiVorname, '_refarea.png'));
imwrite(Ref_Area,SpeichernName);

ref_dimensions = [x_init y_init width-1 height-1];
test_dimensions= [0 y_init c height-1];

%% The below loop continuously takes 2 images and compares them for same parts
% This helps to identify the correct region in each image

directory_fil = strcat(directory, '\Ergebnisse\Filtered');

% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(directory_fil,'*.png'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enth�lt:
    error('Der directory enth�lt keine Datei im png-Format.') % Fehlerausschrift anzeigen
end

region_dimensions = zeros(Endbild - Startbild, 1, 4);

%%
total_width = width;
x_begin = x_init; %Position des ausgew�hlten Rechtecks in X
y_begin = y_init; %Position des ausgew�hlten Rechtecks in Y
y_height = height; %H�he des ausgew�hlten Rechtecks
ii=1;
vx=zeros(1,Endbild-1);
Startbild = 1;  % Set this parameter as per No. of Images in directory
Endbild= 200;
for range = Startbild : Endbild-1
    filename = strcat(directory_fil,'\', Names(range).name);
    reference_image = imread(filename);
    reference_image = imcrop(reference_image, ref_dimensions);%Bild1 wird zugeschnitten
    
    filename = strcat(directory_fil,'\', Names(range+1).name);
    test_image = imread(filename);
    test_image = imcrop(test_image, test_dimensions);
    
    corr_coef = normxcorr2(reference_image, test_image); %Correlation zwischen Bild1-Zuschnitt und Bild2
    
    [ypeak, xpeak] = find(corr_coef ==max(corr_coef(:))); %Die maximale �bereinstimmung wird verwendet
    %     yoffSet = ypeak-size(Ref_Area,1);
    %     xoffSet = xpeak-size(Ref_Area,2);
    [y,x] = size(ypeak);
    if (y+x) == 2
        yoffSet = ypeak-size(Ref_Area,1);
        xoffSet = xpeak-size(Ref_Area,2);
    else
        yoffSet = ypeak(1)-size(Ref_Area,1);
        xoffSet = xpeak(1)-size(Ref_Area,2);
    end
    %     vx(ii)=xoffSet;
    %     vy(ii)=yoffSet;
    
    %     x_begin = x_init;
    if xoffSet > x_init
        x_begin = x_init;
        x_width = xoffSet-x_init; %Ben�tigte Bildbreite wird berechnet aus dem Offset-Startwert
        right_flag = 1;           % This indicates the flow is from left to right
    else
        x_width = x_init - xoffSet;
        x_begin = xoffSet+width;
        right_flag = 0;           % This indicates the flow is from right to left
    end
    
    vx(ii)=x_width;
    vy(ii)=yoffSet-y_init;
    ii=ii+1;
    total_width = x_width + total_width;
    region_dimensions(range,:,:) = [x_begin,y_begin,x_width-1,y_height];
    [Pfad,DateiVorname,Erweiterung] = fileparts(filename);
    SpeichernName = strcat(O_Cropped,'\',strcat(DateiVorname, '_refarea.png'));
    imwrite(imcrop(test_image, [x_begin,1,x_width-1,y_height-1]),SpeichernName);
end

%% Read the Cropped filtered Images and join them using the top edge

directory_crop = strcat(directory, '\Ergebnisse\Cropped');
% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(O_Cropped,'*.png'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enth�lt:
    error('Der directory enth�lt keine Datei im png-Format.') % Fehlerausschrift anzeigen
end

total_width =0;
for range = Startbild : Endbild
    filename = strcat(O_Cropped,'\', Names(range).name);
    reference_image = imread(filename);
    [y, x] = size(reference_image);
    total_width = total_width + x;
end
y_height = y;
% Initialise the variable for Entire Image Dimensions
stitched_image = false( 3*y_height, total_width); % Das leere Bild wird erstellt
width_covered=0;
y_shift_total = 0;
if right_flag == 0
    Startbild_1 = Startbild;
    Endbild_1 = Endbild;
    XX = 1;
else
    Startbild_1 = Endbild;
    Endbild_1 = Startbild;
    XX = -1;
end

for range = Startbild_1:XX:Endbild_1
    % Read the Last Image as the start image
    filename = strcat(O_Cropped,'\', Names(range).name);
    reference_image = imread(filename);
    [y1, x1] = size(reference_image);
    if(range == Startbild_1) %Das Letzte Bild wird nach vorne eingesetzt
        for x_sweep = 1:x1
            yy=0;
            for y_sweep = ceil((2*y_height-y1)/2):floor((2*y_height+y1)/2)-1
                yy=yy+1;
                stitched_image( y_sweep, width_covered + x_sweep) = reference_image(yy, x_sweep);
            end
        end
        width_covered = width_covered + x1;
    end
    %if range<Endbild_1
    %Sobald weitere Bilder eingelesen werden
    
    y_right_flag = 0;
    count = 0;
    StartPiRow=0;
    % Detect the white line of next image
    while y_right_flag==0
        StartPiRow=StartPiRow+1;
        for y_sweep = 1:y1
            if((reference_image(y_sweep, StartPiRow) == 1) && y_right_flag == 0) % Check for the white part
                y_right = y_sweep;
                y_right_flag = 1;
            end
        end
        
    end
    
    y_left_flag = 0;
    count = 0;
    EndPiRow=0;
    while y_left_flag==0 %Falls letztes Pixel nicht wei�
        
        % Detect the white line
        for y_sweep = 1:3*y_height
            if((stitched_image(y_sweep, width_covered-EndPiRow) == 1) && y_left_flag == 0) % Check for the white part
                y_left = y_sweep;
                y_left_flag = 1;
            end
            
        end
        EndPiRow=EndPiRow+1;
    end
    %Bis jetzt wurde die wei�e Linie im offenen Ende des Stitched Image
    %gefunden und im linken Teil des dazukommenden Bildes
    y_shift =y_left - y_right;
    
    y_shift_total = y_shift;
    
    for x_sweep = StartPiRow:x1
        for y_sweep = 1:y1
            if(y_sweep+y_shift_total >=1 && y_sweep+y_shift_total <= 3*y1)
                stitched_image( y_sweep+y_shift_total, width_covered + x_sweep) = reference_image(y_sweep, x_sweep);
            end
        end
    end
    width_covered = width_covered + x1-(StartPiRow-1)-EndPiRow;
end



[~,DateiVorname,~] = fileparts(filename);
SpeichernName = strcat(O_Plots,'\', '_final_stitch.bmp');
imwrite(stitched_image,SpeichernName);
% yy=zeros(2,width_covered);
%
%
% for xx=1:width_covered
%     y_flag=0;
%     for y_sweep=1:2*y_height
%         if((stitched_image(y_sweep, xx) == 1) && y_flag==0)  % Check for the white part
%             yy(1,xx)=y_sweep;
%             y_flag=1;
%         end
%     end
%     y_flag=0;
%     for y_sweep=2*y_height:-1:1
%         if((stitched_image(y_sweep, xx) == 1) && y_flag==0)  % Check for the white part
%             yy(2,xx)=y_sweep;
%             y_flag=1;
%         end
%     end
% end

