clc;
close all;
clear all;


%Bilderanzahl Startwert
BA = 1;
Startbild = 1;

%Rotwert bei der Tropfendetektion
RW = 30;

%Anzahl Tropfen, bis dahin kein Zerfall
AT1 = 1;

%Anzahl Tropfen, ab da Zertropfen
AT2 = 10;

%Anzahl Tropfen, ab der Zerstäuben
AT3 = 30;

%Kritischer Wert, ab wo Zerwellen mehr auftrifft
KW = 200;

%Wert wo kleine Elemente ausgeblendet werden
KE = 200;
KE2 = 800;

%Schwellwert, ab da wird für die Ermittlung der Strahlbreite der Zählwert
%um eins steigen
sw = 40;

a = 0;  %von x Anfang  (von links aus betrachtet!)
b = 37;  %von y Anfang  (von oben aus betrachtet!)
c = 1696;  %Breite        (Breite des Bildes)
d = 652;  %Höhe          (Höhe des Bildes)

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

for i= Startbild:1
    
    filename = strcat(directory,'\', Names(i).name)
    input = imread(filename);
    [r, c] = size(input);
    
    [Pfad,DateiVorname,Erweiterung] = fileparts(filename);
    disp(['Aktuelles Bild : ', filename])
%----------------------- neue Bilderanzahl berechnen ----------------------
    BA = BA + 1;
    
%-----------------------Vignettierung entfernen-----------------------
%    figure(1)
%    lambda = 1;
%    [im_corr,im_vig] = VignettierungsKorrektur_V1(input,lambda);
    im_corr = input;
%% ---------------------------- BESCHNEIDEN ---------------------------------

    %Beschneiden
    [y,x]=size(im_corr); % Breite x und Höhe y

    %Bild beschneiden
    Schnitt = imcrop(im_corr,[a b c d]);
    
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_1Original.png'));
    imwrite(Schnitt,SpeichernName);
    
%% ------------------------- Kantendetektion --------------------------------

    Kante = edge(Schnitt,'canny');
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_2Canny.png'));
    imwrite(Kante,SpeichernName);
%----------------------------- Kanten schließen ---------------------------
%     SE2 = strel('line',10,90);              %Erzeugt eine Linie der Breite 2 und der Länge 10
    SE2 = strel('disk',1);              %Erzeugt eine Scheibe mit Radius 2
    Kante2 = imdilate(Kante,SE2);       %
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_3KanteSchliessen.png'));
    imwrite(Kante2,SpeichernName);

%% 
    Kante2(:,1)=1;
    Kante2(:,c)=1;

%--------------------------- FÜLLEN ---------------------------------------
    Fill = imfill(Kante2,'holes');
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_4Fill.png'));
    imwrite(Fill,SpeichernName);
 
%    Option:
%     figure    
%     Fill = imfill(Fill); % freie Stellen anklicken und mit Enter bestätigen
%----------------------- Kleine Elemente Ausblenden -----------------------
    Fill2 = bwareaopen(Fill,KE);
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_5FillKleineLoeschen.png'));
    imwrite(Fill2,SpeichernName);

%------------------------------ CANNY / KANTENDETEKTION -------------------
    Kante3 = edge(Fill2,'canny');  
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_6Canny2.png'));
    imwrite(Kante3,SpeichernName);
%----------------------------- Kanten schließen ---------------------------
    SE = strel('disk',2);
    Kante4 = imdilate(Kante3,SE);
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_7KanteSchliessen2.png'));
    imwrite(Kante4,SpeichernName);   
%--------------------------- FÜLLEN ---------------------------------------
    Fill3 = imfill(Kante4,'holes'); 
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_8Fill2.png'));
    imwrite(Fill3,SpeichernName); 
    
%----------------------- Kleine Elemente Ausblenden -----------------------
    Fill4 = bwareaopen(Fill3,KE2);    
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_9FillKleineLoeschen2.png'));
    imwrite(Fill4,SpeichernName);  
%---------------------------- INVERTIEREN ---------------------------------
    Inv = imcomplement(Fill4);
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_10Inv.png'));
    imwrite(Inv,SpeichernName); 


%--------------------------- TROPFEN DETEKTIEREN --------------------------

    [B,Matrix,NN,A] = bwboundaries(Inv,'holes');
    numRegions = max(Matrix(:));

    %Tropfenanzahl ermitteln
    TA = numRegions - NN;
    
    [Hoehe, Breite] = size(Matrix);


    %Matrix ändern

    %Durchlaufen und alle Linien (Werte kleiner NN) mit 1 versehen
    for jj=1:1:Hoehe
        for ii=1:1:Breite
            if Matrix(jj,ii) <= NN && Matrix(jj,ii) ~= 0
               Matrix(jj,ii) = 1;
            end
        end
    end

    %Durchlaufen und Löcher (Werte größer NN) mit 100 versehen
    for jj=1:1:Hoehe
        for ii=1:1:Breite
            if Matrix(jj,ii) > NN
               Matrix(jj,ii) = RW;
            end
        end
    end

    Bild2 = label2rgb(Matrix, hot);
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_11Bild2.png'));
    imwrite(Bild2,SpeichernName);
    
    %imshow(x);
    
    %------------------------- Strahlbreite ermitteln -------------------------

    % Kleine Elemente Ausblenden
    
    
    [Hoehe, Breite] = size(Fill);
    Anz = 0;
    W = 1;
    
    %durch die Matrix laufen und Anzahl weißer Stellen ermitteln (Anz)
    for ii = 1:Hoehe %50:5:(Breite-50)

        for jj = 1:Breite
            if Fill(ii,jj) == 1
               Anz = Anz + 1;
            end
        end

        Fliessbreite(W,1) = Anz;
        Anz = 0;
        W = W + 1;
    end


    %in 2. Spalte den Mittelwert schreiben
    MW = mean(Fliessbreite(:,1));
    Fliessbreite(:,2)= MW;

    %Differenz berechnen
    for jj=1:length(Fliessbreite)
        Fliessbreite(jj,3) = Fliessbreite(jj,1) - MW;
    end


    % Schwellwert (sw) festlegen, ab Differenz (Aktueller Wert zu Mittelwert)
    % zu groß ist und Zählen (ZW) wie oft dies pro Bild Auftrifft
    ZW = 0;
   

    for jj=1:length(Fliessbreite)
        if abs(Fliessbreite(jj,3)) >= sw;
           ZW = ZW + 1;
        end
    end
    
%--------------------- STRAHLBREITE PLOTTEN -------------------------------

    Fig2 = figure(2);
    X = (linspace(1,Hoehe,Hoehe));
    subplot(2,1,1);
    plot(X,Fliessbreite(:,1));
    hold on
    plot(X,Fliessbreite(:,2));
    title('Strahlbreite und Mittelwert')
    xlabel('x-Koordinate');
    ylabel('Strahlbreite');
    grid on
    xlim([0,Hoehe]);
    ylim([0,max(Fliessbreite(:,1))+5]);
    hold off

    subplot(2,1,2);
    plot(X,Fliessbreite(:,3));
    title('Abweichung vom Mittelwert');
    xlabel('x-Koordinate');
    ylabel('Abweichung vom MW');
    grid on
    xlim([0,Breite]);
    ylim([-40,40]);

%--------------- TABELLE UND PLOTS STRAHLBREITE SPEICHERN -----------------
    
    SpeichernName = strcat(O_Daten,'\',strcat(DateiVorname, ' - Strahlbreite.xls'));
    xlswrite(SpeichernName,Fliessbreite)
    
    SpeichernName = strcat(O_Plots,'\',strcat(DateiVorname, ' - Strahlbreite Plot.png'));
    set(Fig2,'PaperPositionMode','auto');         
%   set(Fig1,'PaperOrientation','landscape');
    set(Fig2,'Position',[50 50 1200 800]);
    saveas(Fig2,SpeichernName,'png');
%----------------------Abbildungen plotten----------------------------
    Fig3 = figure(3);
    subplot(2,1,1);
    imshow(Schnitt)
    subplot(2,1,2);
    imshow(Bild2)
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, '_Bilder.png'));
    saveas(Fig3,SpeichernName,'png');
          
    if TA <= AT3 % Zertropfen
           Auswertung(BA,1) = 3;

           elseif TA > AT3 % Zerstäuben
                  Auswertung(BA,1) = 4;

    end
    
    
    %Zurücksetzten des Wertes W
    W = 1;
    
    %Speichern der Tropfenanzhal TA, des Mittelwertes MW der Breite und der
    %Standartabweichung der Breite
    Auswertung(BA,5) = TA;
    Auswertung(BA,6) = MW;
    Auswertung(BA,7) = std(Fliessbreite(:,3),1);

    Fig3 = figure(1);
    imshow(Bild2);
    title('Tropfendetektion');
%----------------------------- SPEICHERN BIDLER ---------------------------
  

    
    SpeichernName = strcat(O_Bilder,'\',strcat(DateiVorname, sprintf(' - Tropfendetektion %i.png',i)));
    
    set(Fig3,'PaperPositionMode','auto');         
    set(Fig3,'Position',[50 50 1200 800]);
    saveas(Fig3,SpeichernName,'png');
    %%close all 
    
    
end

%Wert BA ist nun eins höher als tatsächliche Bildanzahl

    
%--------------------------- AUSWERTUNG TEIL 2 ----------------------------
%Summe, Mittelwert und Standartabweichung d. Auswertung in Matlab ermitteln
SA = sum(Auswertung(1:BA,1));
MWA = mean(Auswertung(1:BA,1));
StdA = std(Auswertung(1:BA,1),1);
Auswertung(2+BA,1) = SA;
Auswertung(2+BA,2) = MWA;
Auswertung(2+BA,3) = StdA;


%Summe und Mittelwert der Tropfen ermitteln
MWT = mean(Auswertung(1:BA,5));
StdT = std(Auswertung(1:BA,5),1);
Auswertung(2+BA,5) = MWT;
Auswertung(2+BA,4) = StdT;

%Mittelwert der mittleren Strahlbreite und 
%Mittelwert der Standartabweichung der Strahlbreite ermitteln
MW2 = mean(Auswertung(1:BA,6));
MW3 = mean(Auswertung(1:BA,7));
Auswertung(2+BA,6) = MW2;
Auswertung(2+BA,7) = MW3;

%----------------------------- SPEICHERN AUSWERTUNG------------------------

SpeichernName = strcat(O_Daten,'\',strcat('Auswertung Strahlzerfall Tabelle.xls'));
xlswrite(SpeichernName,Auswertung)

%----------------------- ZERFALLSERSCHEINUNG ERMITTELN --------------------

disp(directory)
disp(['Mittlere Tropfenanzahl ist: ', num2str(MWT)])
disp(['Standartabweichung der MittlerenTropfenanzahl ist: ', num2str(StdT)])
disp(['Mittelwert Mittlere Strahlbreite (in Pixel) ist : ', num2str(MW2)])
disp(['Mittelwert Standartabweichung der  Strahlbreite(in Pixel) ist : ', num2str(MW3)])
disp(['Auswertungswert ist : ', num2str(SA)])
disp(['Mittelwert der Auswertungswert ist : ', num2str(MWA)])
disp(['Standartabweichung Mittelwert der Auswertungswert ist : ', num2str(StdA)])

if SA >= 1*BA && SA <= 1.5*BA
        disp('Kein Zerfall')
    elseif SA > 1.5*BA && SA <= 2.5*BA 
        disp('Zerwellen')
    elseif SA > 2.5*BA && SA <= 3.5*BA
        disp ('Zertropfen')
    elseif SA > 3.5*BA 
        disp ('Zerstäuben')
end

    