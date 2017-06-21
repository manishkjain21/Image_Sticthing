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
d = 440;  %Höhe          (Höhe des Bildes)
p = 0.1;
crop_area = [a b c d];
Startbild = 1;
Bilder_Vorgeben=true;
% Bilder_Vorgeben=false;
if Bilder_Vorgeben==true
    Startbild = 2;  % Set this parameter as per No. of Images in directory
    Endbild= 201;
end
fontSize = 16;

%% Referenzbild

blank=imread('D:\Germany\Studies\HiWi\TTD\Image_Stitch\HighSpeed\ld133\Blank.bmp');
blank=imcrop(blank, crop_area);

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