% MATLAB-Skript: Zusammenhang zwischen Temperatur und U_AB
clear; clc; close all;

%% 1. Daten einlesen
% Datensatz 1: Eis
Temp_Eis = [29, 20, 15, 13, 12, 11, 10, 9, 8];
U_AB_Eis = [0.157, 0.145, 0.107, 0.092, 0.09, 0.138, 0.082, 0.077, 0.069];

% Datensatz 2: Spray
Temp_Spray = [8, 6, 5, 4, 3];
U_AB_Spray = [0.068, 0.061, 0.0572, 0.0571, 0.0573];

% Datensatz 3: Aufwärmen
Temp_Aufwaermen = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27];
U_AB_Aufwaermen = [0.0995, 0.105, 0.145, 0.1129, 0.1131, 0.1198, 0.1234, 0.1262, 0.1283, 0.1325];

%% 2. Ausreißer definieren und aus den Linien-Daten extrahieren
% Identifizierte Ausreißer-Indizes innerhalb der jeweiligen Datensätze:
idx_outliers_eis = [1, 2, 6];     % 29°C, 20°C und 11°C im Eis-Datensatz
idx_outliers_aufw = [3];          % 20°C im Aufwärmen-Datensatz

% Indizes der gültigen (validen) Punkte bestimmen
idx_valid_eis = setdiff(1:length(Temp_Eis), idx_outliers_eis);
idx_valid_aufw = setdiff(1:length(Temp_Aufwaermen), idx_outliers_aufw);

% Bereinigte Vektoren erstellen (diese werden durchgängig verbunden)
Temp_Eis_valid = Temp_Eis(idx_valid_eis);
U_AB_Eis_valid = U_AB_Eis(idx_valid_eis);

Temp_Aufwaermen_valid = Temp_Aufwaermen(idx_valid_aufw);
U_AB_Aufwaermen_valid = U_AB_Aufwaermen(idx_valid_aufw);

%% 3. Diagramm 1: Alle Datensätze in einem Diagramm
figure('Name', 'Zusammenhang Temp - U_AB (Alle zusammen)', 'Position', [100, 100, 600, 400]);
hold on; grid on;

% 3a. Datensatz Eis: Durchgehende blaue Linie nur durch valide Punkte + alle validen Marker (ausgefüllt)
plot(Temp_Eis_valid, U_AB_Eis_valid, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Eis (Trend)');
plot(Temp_Eis_valid, U_AB_Eis_valid, 'bo', 'MarkerFaceColor', 'b', 'HandleVisibility', 'off');

% 3b. Datensatz Spray: Komplett normal (keine Ausreißer)
plot(Temp_Spray, U_AB_Spray, '-s', 'Color', [1.0 0.5 0.0], 'LineWidth', 1.5, 'MarkerFaceColor', [1.0 0.5 0.0], 'DisplayName', 'Spray');

% 3c. Datensatz Aufwärmen: Durchgehende rote Linie nur durch valide Punkte + alle validen Marker (ausgefüllt)
plot(Temp_Aufwaermen_valid, U_AB_Aufwaermen_valid, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Aufwärmen (Trend)');
plot(Temp_Aufwaermen_valid, U_AB_Aufwaermen_valid, 'r^', 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');

% 3d. Die Ausreißer nach Gruppenschema plotten (gleiche Form/Farbe, aber unaufgefüllt und dicker)
plot(Temp_Eis(idx_outliers_eis), U_AB_Eis(idx_outliers_eis), 'ob', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Ausreißer (Eis)');
plot(Temp_Aufwaermen(idx_outliers_aufw), U_AB_Aufwaermen(idx_outliers_aufw), '^r', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Ausreißer (Aufwärmen)');

axis padded;
xlabel('Temperatur in °C', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Spannung U_{AB} in V', 'FontSize', 11, 'FontWeight', 'bold');
title('Temperatur vs. U_{AB}', 'FontSize', 12);
legend('Location', 'southeast', 'FontSize', 10);
hold off;

%% 4. Diagramm 2: Alle Datensätze in getrennten Diagrammen (Subplots)
figure('Name', 'Zusammenhang Temp - U_AB (Getrennt)', 'Position', [100, 600, 1200, 380]);

% Subplot 1: Eis
subplot(1, 3, 1);
hold on; grid on;
plot(Temp_Eis_valid, U_AB_Eis_valid, 'b-', 'LineWidth', 1.5);
plot(Temp_Eis_valid, U_AB_Eis_valid, 'bo', 'MarkerFaceColor', 'b');
% Ausreißer Eis (blaue, unaufgefüllte Kreise)
plot(Temp_Eis(idx_outliers_eis), U_AB_Eis(idx_outliers_eis), 'ob', 'MarkerSize', 8, 'LineWidth', 2);
axis padded;
xlabel('Temperatur in °C'); ylabel('U_{AB} in V');
title('Datensatz 1: Eis');
hold off;

% Subplot 2: Spray
subplot(1, 3, 2);
plot(Temp_Spray, U_AB_Spray, '-s', 'Color', [1.0 0.5 0.0], 'LineWidth', 1.5, 'MarkerFaceColor', [1.0 0.5 0.0]);
axis padded; grid on;
xlabel('Temperatur in °C'); ylabel('U_{AB} in V');
title('Datensatz 2: Spray');

% Subplot 3: Aufwärmen
subplot(1, 3, 3);
hold on; grid on;
plot(Temp_Aufwaermen_valid, U_AB_Aufwaermen_valid, 'r-', 'LineWidth', 1.5);
plot(Temp_Aufwaermen_valid, U_AB_Aufwaermen_valid, 'r^', 'MarkerFaceColor', 'r');
% Ausreißer Aufwärmen (rote, unaufgefüllte Dreiecke)
plot(Temp_Aufwaermen(idx_outliers_aufw), U_AB_Aufwaermen(idx_outliers_aufw), '^r', 'MarkerSize', 8, 'LineWidth', 2);
axis padded;
xlabel('Temperatur in °C'); ylabel('U_{AB} in V');
title('Datensatz 3: Aufwärmen');
hold off;

% Gesamttitel 
sgtitle('Zusammenhang zwischen Temperatur und U_{AB} (Getrennte Ansicht)', 'FontSize', 14, 'FontWeight', 'bold');