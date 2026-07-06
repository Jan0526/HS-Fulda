% =========================================================================
% Auswertung: U_AB vs. Temperatur
% =========================================================================
clear; clc; close all;

%% 1. Parameter und Nennwiderstände definieren
% Widerstände in Ohm
R_A1 = 4700 + 330; % 5030 Ohm
R_A2 = 2000;       % 2000 Ohm
R_B1 = 220 + 33;   % 253  Ohm
U_ges = 5;         % Speisespannung in Volt 

% Konstanten für PT100 (DIN EN 60751)
R0 = 100;               
A = 3.9083e-3;
B = -5.775e-7;

%% 2. Messdaten einlesen
% Datensatz 1: Eis
Temp_Eis = [29, 20, 15, 13, 12, 11, 10, 9, 8];
U_AB_Eis = [0.157, 0.145, 0.107, 0.092, 0.09, 0.138, 0.082, 0.077, 0.069];

% Datensatz 2: Spray
Temp_Spray = [8, 6, 5, 4, 3];
U_AB_Spray = [0.068, 0.061, 0.0572, 0.0571, 0.0573];

% Datensatz 3: Aufwärmen
Temp_Aufwaermen = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27];
U_AB_Aufwaermen = [0.0995, 0.105, 0.145, 0.1129, 0.1131, 0.1198, 0.1234, 0.1262, 0.1283, 0.1325];

% Alle Daten für die tabellarische Auswertung zusammenfassen
T_all = [Temp_Eis, Temp_Spray, Temp_Aufwaermen];
U_AB_ist_all = [U_AB_Eis, U_AB_Spray, U_AB_Aufwaermen];

% Indizes der Ausreißer definieren
idx_outliers = [1, 2, 6, 17]; % Entspricht: 29°C, 20°C(Eis), 11°C, 20°C(Aufw.)

%% 3. Theoretische Berechnung (Soll-Werte)
R_PT100_soll = R0 .* (1 + A.*T_all + B.*T_all.^2);
U_A2_soll = U_ges * (R_A2 / (R_A1 + R_A2));
U_B2_soll = U_ges .* (R_PT100_soll ./ (R_B1 + R_PT100_soll));
U_AB_soll = U_B2_soll - U_A2_soll;

% Fehlerberechnung (Ist vs Soll)
fehler_all = U_AB_ist_all - U_AB_soll;
fehler_prozent_all = (fehler_all ./ U_AB_soll) * 100;

%% 4. Trennung der Daten (Mit vs. Ohne Ausreißer)
idx_valid = setdiff(1:length(T_all), idx_outliers);
T_valid = T_all(idx_valid);
U_AB_valid = U_AB_ist_all(idx_valid);
fehler_valid = fehler_all(idx_valid);
fehler_prozent_valid = fehler_prozent_all(idx_valid);

%% 5. Lineare Regression & Statistiken
% Regressionsgerade für ALLE Werte
p_all = polyfit(T_all, U_AB_ist_all, 1);
U_fit_all_eval = polyval(p_all, T_all);

% R^2 (Bestimmtheitsmaß) für alle Werte berechnen
SS_tot_all = sum((U_AB_ist_all - mean(U_AB_ist_all)).^2);
SS_res_all = sum((U_AB_ist_all - U_fit_all_eval).^2);
Rsq_all = 1 - SS_res_all/SS_tot_all;

% Regressionsgerade OHNE Ausreißer (Gültige Daten)
p_valid = polyfit(T_valid, U_AB_valid, 1);
U_fit_valid_eval = polyval(p_valid, T_valid);

% R^2 (Bestimmtheitsmaß) für bereinigte Werte berechnen
SS_tot_valid = sum((U_AB_valid - mean(U_AB_valid)).^2);
SS_res_valid = sum((U_AB_valid - U_fit_valid_eval).^2);
Rsq_valid = 1 - SS_res_valid/SS_tot_valid;

% Theoretische lineare Empfindlichkeit (Steigung) im Bereich 0-30°C approximieren
p_theorie = polyfit(T_all, U_AB_soll, 1);
steigung_theorie = p_theorie(1);

%% 6. Konsolenausgabe
fprintf('=========================================================================\n');
fprintf(' Detaillierte Messwertanalyse U_AB (Ist vs. Soll)\n');
fprintf('=========================================================================\n');
fprintf(' Messpunkt | Temp (°C) | U_AB Ist (V) | U_AB Soll (V) | Abs. Abw (V) | Rel. Abw (%%)\n');
fprintf('-------------------------------------------------------------------------\n');
for i = 1:length(T_all)
    marker = ' ';
    if ismember(i, idx_outliers)
        marker = '*'; 
    end
    fprintf(' %2d %s      | %7d   | %11.4f  | %12.4f  | %11.4f  | %+8.2f %%\n', ...
            i, marker, T_all(i), U_AB_ist_all(i), U_AB_soll(i), fehler_all(i), fehler_prozent_all(i));
end
fprintf(' (* = Identifizierter Ausreißer)\n\n');

fprintf('============================================================\n');
fprintf(' STATISTISCHE AUSWERTUNG DER BRÜCKENSPANNUNG (U_AB)\n');
fprintf('============================================================\n\n');

% Ausgabe Block 1: Alle Daten
fprintf('1. Analyse des GESAMTDATENSATZES (N = %d):\n', length(T_all));
fprintf('------------------------------------------------------------\n');
fprintf('  Mittlerer Fehler (Bias)   : %6.4f V\n', mean(fehler_all));
fprintf('  RMSE (Root Mean Square)   : %6.4f V\n', sqrt(mean(fehler_all.^2)));
fprintf('  Gemessene Empfindlichkeit : %6.4f V/°C (Theorie: ~%.4f V/°C)\n', p_all(1), steigung_theorie);
fprintf('  Bestimmtheitsmaß R^2      : %6.4f\n\n', Rsq_all);

% Ausgabe Block 2: Bereinigte Daten
fprintf('2. Analyse des BEREINIGTEN DATENSATZES (Ohne Ausreißer, N = %d):\n', length(T_valid));
fprintf('------------------------------------------------------------\n');
fprintf('  Mittlerer Fehler (Bias)   : %6.4f V\n', mean(fehler_valid));
fprintf('  RMSE (Root Mean Square)   : %6.4f V\n', sqrt(mean(fehler_valid.^2)));
fprintf('  Gemessene Empfindlichkeit : %6.4f V/°C (Theorie: ~%.4f V/°C)\n', p_valid(1), steigung_theorie);
fprintf('  Bestimmtheitsmaß R^2      : %6.4f\n\n', Rsq_valid);
fprintf('============================================================\n');

%% 7. Visualisierung (Plot)
% Glatte Arrays für Kurven generieren (0 bis 35 °C)
T_plot = 0:0.1:35;
R_PT100_plot = R0 .* (1 + A.*T_plot + B.*T_plot.^2);
U_B2_plot = U_ges .* (R_PT100_plot ./ (R_B1 + R_PT100_plot));
U_AB_plot = U_B2_plot - U_A2_soll;

figure('Name', 'Statistische Analyse U_AB', 'Position', [100, 100, 850, 550], 'Color', 'w');
hold on; grid on;

% 1. Theoretische Idealkurve plotten
plot(T_plot, U_AB_plot, 'g-', 'LineWidth', 2, 'DisplayName', 'U_{AB} Theorie');

% 2. Regressionsgerade (bereinigte Daten) plotten
U_fit_valid_plot = polyval(p_valid, T_plot);
plot(T_plot, U_fit_valid_plot, '--m', 'LineWidth', 1.5, 'DisplayName', 'Regressionsgerade (bereinigt)');

% 3. Gemessene Werte als Scatter plotten
plot(Temp_Eis, U_AB_Eis, 'bo', 'MarkerFaceColor', 'b', 'DisplayName', 'Methode 1: Eis');
plot(Temp_Spray, U_AB_Spray, 's', 'Color', [1.0 0.5 0.0], 'MarkerFaceColor', [1.0 0.5 0.0], 'DisplayName', 'Methode 2: Spray');
plot(Temp_Aufwaermen, U_AB_Aufwaermen, 'r^', 'MarkerFaceColor', 'r', 'DisplayName', 'Methode 3: Aufwärmen');

% 4. Ausreißer einkreisen
plot(T_all(idx_outliers), U_AB_ist_all(idx_outliers), 'or', 'MarkerSize', 12, 'LineWidth', 1.5, 'DisplayName', 'Ausreißer');

% Layout anpassen
xlabel('Temperatur in °C', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Brückenspannung U_{AB} in V', 'FontSize', 12, 'FontWeight', 'bold');
title('Theoretische und gemessene Brückenspannung', 'FontSize', 14);
legend('Location', 'southeast', 'FontSize', 11);
axis padded;
hold off;
