%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author       : Manish Jain
% Dept         : TTD, TU Darmstadt
% License      : TTD, TU Darmstadt
% Project Name : Jet Flow Stitching for Roughness Detection
% Parameters to set:
% KE - Image Filtering parameter
% [a, b, c, d] - Jet Flow Cropping Area dimensions
% fontsize - for printing on the image
% Description:
% In this code, We can test for Image Filtering and reference box testing
% The code takes an image and opens a ui for selection of an area to crop. 
% It stores the area and crops the same area from other image. It then
% displays both the areas.

%%
clc
clear all;
close all;

KE = 200;
a = 1;  %von x Anfang  (von links aus betrachtet!)
b = 100;  %von y Anfang  (von oben aus betrachtet!)
c = 1328;  %Breite        (Breite des Bildes)
d = 400;  %Höhe          (Höhe des Bildes)

crop_area = [a b c d];

fontSize = 16;

%% Directory Settings
directory = 'D:\Germany\Studies\HiWi\TTD\Image_Stitch\HighSpeed\ld133';

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

filename = strcat(directory,'\', Names(1).name);
input = imread(filename);
% Crop the image for Flow
input = imcrop(input, crop_area);
% Display the name of the reference image
[Pfad,DateiVorname,Erweiterung] = fileparts(filename);
disp(['Aktuelles Bild : ', filename])
% The below part opens up and image and then a part of the flow can be
% selected to track. It is recommend that entire height of the shown image
% be selected to compensate for the irregularity in the height of flow over
% time

imshow(input);
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

Ref_Area = input(y_init+1:y_init+height, x_init:x_init+width);
Ref_Area = image_filtering_JR(Ref_Area);
SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_Original.png'));
imwrite(Ref_Area,SpeichernName);
subplot(2,1,1)
imshow(input);

% Check for Width of the part to be inconsistent with the next image
crop_area(2) = y_init;
crop_area(4) = height;
%Take a new image and compare them
filename = strcat(directory,'\', Names(21).name);
Test_image = imread(filename);
subplot(2,1,2)
imshow(Test_image);
[Pfad,DateiVorname,Erweiterung] = fileparts(filename);
disp(['Aktuelles Bild : ', filename])
im_corr = Test_image;
Schnitt_new = imcrop(im_corr,crop_area);

subplot(2,1,1)
imshow(Ref_Area)
subplot(2,1,2)
imshow(image_filtering_JR(input))




