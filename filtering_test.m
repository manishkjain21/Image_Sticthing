%%
clc
clear all;
close all;

KE = 200;
a = 1;  %von x Anfang  (von links aus betrachtet!)
b = 100;  %von y Anfang  (von oben aus betrachtet!)
c = 1328;  %Breite        (Breite des Bildes)
d = 420;  %Höhe          (Höhe des Bildes)

crop_area = [a b c d];

fontSize = 16;

%% Directory Settings
directory = 'D:\Germany\Studies\HiWi\TTD\Image_Stitch\HighSpeed\ld133';
% Erstellen einer Liste der Dateinamen
Names = dir(fullfile(directory,'*.bmp'));
if isempty(Names)                                          % Falls directory keine bmp- Datei enthält:
    error('Der directory enthält keine Datei im bmp-Format.') % Fehlerausschrift anzeigen
end
p =0.1;
blank_file = strcat(directory,'\', Names(1).name);
blank = imread(blank_file);
filename = strcat(directory,'\', Names(28).name);
input = imread(filename);

% Crop the image for Flow
input = imcrop(input, crop_area);
blank = imcrop(blank, crop_area);
Ref_Area = image_filtering_JR(input, blank, p);
subplot(2, 1, 1);
imshow(input);
subplot(2, 1, 2);
imshow(Ref_Area);
