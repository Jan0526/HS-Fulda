% =========================================================================
% Auswertung Wheatstone-Brücke mit PT100 inkl. statistischer Analyse
% =========================================================================
clear; clc; close all;

%% 1. Bekannte Widerstände definieren (in Ohm)
R_A1 = 4700 + 330; % 5030 Ohm
R_A2 = 2000;       % 2000 Ohm
R_B1 = 220 + 33;   % 253 Ohm

%% 2. Konstanten für PT100 nach DIN EN 60751 (für T > 0 °C)
R0 = 100;               
A = 3.9083e-3;
B = -5.775e-7;

%% 3. Messdaten eingeben
U_AB = [0.157, 0.145, 0.107, 0.092, 0.09, 0.138, 0.082, 0.077, 0.069, ...
        0.068, 0.061, 0.0572, 0.0571, 0.0573, ...
        0.0995, 0.105, 0.145, 0.1129, 0.1131, 0.1198, 0.1234, 0.1262, 0.1283, 0.1325];

U_A2 = [1.41, 1.41, 1.414, 1.414, 1.413, 1.414, 1.413, 1.413, 1.413, ...
        1.413, 1.413, 1.413, 1.413, 1.413, ...
        1.413, 1.413, 1.414, 1.413, 1.413, 1.413, 1.413, 1.413, 1.413, 1.413];

U_B2 = [1.55, 1.54, 1.499, 1.484, 1.482, 1.53, 1.474, 1.469, 1.461, ...
        1.459, 1.448, 1.448, 1.448, 1.448, ...
        1.491, 1.496, 1.538, 1.504, 1.504, 1.511, 1.515, 1.518, 1.52, 1.524];

I_ges = [14.2, 14.25, 14.41, 14.48, 14.48, 14.3, 14.51, 14.53, 14.55, ...
         14.57, 14.51, 14.51, 14.51, 14.51, ...
         14.44, 14.41, 14.25, 14.48, 14.4, 14.36, 14.35, 14.33, 14.33, 14.32] / 1000;

I_B = [13.5, 13.55, 13.7, 13.76, 13.78, 13.58, 13.81, 13.82, 13.86, ...
       13.86, 13.9, 13.9, 13.9, 13.89, ...
       13.73, 13.71, 13.55, 13.68, 13.68, 13.65, 13.63, 13.63, 13.62, 13.6] / 1000;

T = [29, 20, 15, 13, 12, 11, 10, 9, 8, ...
     8, 6, 5, 4, 3, ...
     18, 19, 20, 21, 22, 23, 24, 25, 26, 27];

%% 4. Berechnungen der Widerstände
% Gemessene Widerstände (Ohmsches Gesetz)
R_PT100_direkt = U_B2 ./ I_B;

% Theoretische Widerstände (Idealwerte)
R_PT100_soll = R0 .* (1 + A.*T + B.*T.^2);

% Fehlerberechnung (Abweichung Ist von Soll absolut und prozentual)
fehler_all = R_PT100_direkt - R_PT100_soll;
fehler_prozent_all = (fehler_all ./ R_PT100_soll) * 100;

%% 5. Trennung der Daten (Mit vs. Ohne Ausreißer)
indices_outliers = [1, 2, 6, 17];
indices_valid = setdiff(1:length(T), indices_outliers);

T_valid = T(indices_valid);
R_valid = R_PT100_direkt(indices_valid);
fehler_valid = fehler_all(indices_valid);
fehler_prozent_valid = fehler_prozent_all(indices_valid);

%% 6. Lineare Regression & Statistiken
% Regressionsgerade für ALLE Werte
p_all = polyfit(T, R_PT100_direkt, 1);
R_fit_all_eval = polyval(p_all, T);
% R^2 (Bestimmtheitsmaß) für alle Werte berechnen
SS_tot_all = sum((R_PT100_direkt - mean(R_PT100_direkt)).^2);
SS_res_all = sum((R_PT100_direkt - R_fit_all_eval).^2);
Rsq_all = 1 - SS_res_all/SS_tot_all;

% Regressionsgerade OHNE Ausreißer
p_valid = polyfit(T_valid, R_valid, 1);
R_fit_valid_eval = polyval(p_valid, T_valid);
% R^2 (Bestimmtheitsmaß) für bereinigte Werte berechnen
SS_tot_valid = sum((R_valid - mean(R_valid)).^2);
SS_res_valid = sum((R_valid - R_fit_valid_eval).^2);
Rsq_valid = 1 - SS_res_valid/SS_tot_valid;

%% 7. Konsolenausgabe (Detaillierte Liste + Statistische Zusammenfassung)
fprintf('=========================================================================\n');
fprintf(' Detaillierte Messwertanalyse (Ist vs. Soll)\n');
fprintf('=========================================================================\n');
for i = 1:length(T)
    marker = ' ';
    if ismember(i, indices_outliers)
        marker = '*'; % Markiert Ausreißer in der Liste
    end
    fprintf('Messpunkt %2d %s (T = %2d °C): R_Ist = %6.2f Ohm | R_Soll = %6.2f Ohm | Abw = %+6.2f Ohm (%+6.2f %%)\n', ...
            i, marker, T(i), R_PT100_direkt(i), R_PT100_soll(i), fehler_all(i), fehler_prozent_all(i));
end
fprintf(' (* = Identifizierter Ausreißer)\n\n');

fprintf('============================================================\n');
fprintf(' STATISTISCHE AUSWERTUNG FÜR DEN WISSENSCHAFTLICHEN BERICHT\n');
fprintf('============================================================\n\n');

% Ausgabe Block 1: Alle Daten
fprintf('1. Analyse des GESAMTDATENSATZES (N = %d):\n', length(T));
fprintf('------------------------------------------------------------\n');
fprintf('  Mittlerer Fehler (Bias)   : %6.4f Ohm\n', mean(fehler_all));
fprintf('  Mittlerer abs. Fehler (%%) : %6.4f %%\n', mean(abs(fehler_prozent_all)));
fprintf('  Maximaler Fehler (%%)      : %6.4f %%\n', max(abs(fehler_prozent_all)));
fprintf('  Varianz der Abweichung    : %6.4f Ohm^2\n', var(fehler_all));
fprintf('  Standardabweichung (Sigma): %6.4f Ohm\n', std(fehler_all));
fprintf('  RMSE (Root Mean Square)   : %6.4f Ohm\n', sqrt(mean(fehler_all.^2)));
fprintf('  Gemessene Empfindlichkeit : %6.4f Ohm/°C (Theorie: ~0.385)\n', p_all(1));
fprintf('  Bestimmtheitsmaß R^2      : %6.4f\n\n', Rsq_all);

% Ausgabe Block 2: Bereinigte Daten
fprintf('2. Analyse des BEREINIGTEN DATENSATZES (Ohne Ausreißer, N = %d):\n', length(T_valid));
fprintf('------------------------------------------------------------\n');
fprintf('  Mittlerer Fehler (Bias)   : %6.4f Ohm\n', mean(fehler_valid));
fprintf('  Mittlerer abs. Fehler (%%) : %6.4f %%\n', mean(abs(fehler_prozent_valid)));
fprintf('  Maximaler Fehler (%%)      : %6.4f %%\n', max(abs(fehler_prozent_valid)));
fprintf('  Varianz der Abweichung    : %6.4f Ohm^2\n', var(fehler_valid));
fprintf('  Standardabweichung (Sigma): %6.4f Ohm\n', std(fehler_valid));
fprintf('  RMSE (Root Mean Square)   : %6.4f Ohm\n', sqrt(mean(fehler_valid.^2)));
fprintf('  Gemessene Empfindlichkeit : %6.4f Ohm/°C (Theorie: ~0.385)\n', p_valid(1));
fprintf('  Bestimmtheitsmaß R^2      : %6.4f\n\n', Rsq_valid);
fprintf('============================================================\n');

%% 8. Visualisierung: Widerstand über Temperatur
figure('Name', 'PT100 Kennlinie', 'NumberTitle', 'off', 'Color', 'w');
plot(T, R_PT100_direkt, 'ob', 'LineWidth', 1.5, 'MarkerFaceColor', 'b'); hold on;

% Soll-Kurve
T_plot = min(T)-2 : 0.1 : max(T)+2; 
R_plot = R0 .* (1 + A.*T_plot + B.*T_plot.^2);
plot(T_plot, R_plot, '-g', 'LineWidth', 2);

% Ausreißer hervorheben
plot(T(indices_outliers), R_PT100_direkt(indices_outliers), 'or', 'MarkerSize', 10, 'LineWidth', 2);

% Regressionsgerade (Alle Werte)
R_fit_all_plot = polyval(p_all, T_plot);
plot(T_plot, R_fit_all_plot, ':r', 'LineWidth', 1.5);

% Regressionsgerade (Ohne Ausreißer)
R_fit_valid_plot = polyval(p_valid, T_plot);
plot(T_plot, R_fit_valid_plot, '--m', 'LineWidth', 1.5);

grid on;
title('PT100 Widerstand: Messung vs. theoretische Ideal-Kennlinie');
xlabel('Temperatur in °C');
ylabel('Widerstand R_{PT100} in \Omega');
legend('Gemessene Werte', 'Soll-Kurve (DIN EN 60751)', 'Ausreißer', ...
       'Regressionsgerade (Alle Werte)', 'Regressionsgerade (Ohne Ausreißer)', ...
       'Location', 'southeast');
