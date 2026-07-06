% =========================================================================
% Methodenvergleich Wheatstone-Brücke: Ohmsches Gesetz vs. Brückenspannung
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

%% 3. Messdaten eingeben (Eis, Spray, Aufwärmen)
U_AB = [0.157, 0.145, 0.107, 0.092, 0.09, 0.138, 0.082, 0.077, 0.069, ...
        0.068, 0.061, 0.0572, 0.0571, 0.0573, ...
        0.0995, 0.105, 0.145, 0.1129, 0.1131, 0.1198, 0.1234, 0.1262, 0.1283, 0.1325];

U_A2 = [1.41, 1.41, 1.414, 1.414, 1.413, 1.414, 1.413, 1.413, 1.413, ...
        1.413, 1.413, 1.413, 1.413, 1.413, ...
        1.413, 1.413, 1.414, 1.413, 1.413, 1.413, 1.413, 1.413, 1.413, 1.413];

I_B = [13.5, 13.55, 13.7, 13.76, 13.78, 13.58, 13.81, 13.82, 13.86, ...
       13.86, 13.9, 13.9, 13.9, 13.89, ...
       13.73, 13.71, 13.55, 13.68, 13.68, 13.65, 13.63, 13.63, 13.62, 13.6] / 1000;

U_B2 = [1.55, 1.54, 1.499, 1.484, 1.482, 1.53, 1.474, 1.469, 1.461, ...
        1.459, 1.448, 1.448, 1.448, 1.448, ...
        1.491, 1.496, 1.538, 1.504, 1.504, 1.511, 1.515, 1.518, 1.52, 1.524];

T = [29, 20, 15, 13, 12, 11, 10, 9, 8, ...
     8, 6, 5, 4, 3, ...
     18, 19, 20, 21, 22, 23, 24, 25, 26, 27];

%% 4. Berechnungen
% Theoretische Widerstände (Idealwerte) nach DIN-Norm
R_soll = R0 .* (1 + A.*T + B.*T.^2);

% --- Methode 1: Direkt (Ohmsches Gesetz) ---
R_direkt = U_B2 ./ I_B;
fehler_direkt = R_direkt - R_soll;

% --- Methode 2: Über Brückenspannung U_AB ---
% Versorgungsspannung rekonstruieren
U_0 = U_A2 .* ((R_A1 + R_A2) / R_A2);
% Theoretisches U_B aus U_A und U_AB berechnen (Da U_B > U_A laut Daten)
U_B2_calc = U_A2 + U_AB;
% Spannungsteiler-Regel anwenden
R_bruecke = R_B1 .* (U_B2_calc ./ (U_0 - U_B2_calc));
fehler_bruecke = R_bruecke - R_soll;

%% 5. Statistische Auswertung für die Konsole
rmse_direkt = sqrt(mean(fehler_direkt.^2));
rmse_bruecke = sqrt(mean(fehler_bruecke.^2));

bias_direkt = mean(fehler_direkt);
bias_bruecke = mean(fehler_bruecke);

fprintf('======================================================\n');
fprintf(' VERGLEICH DER BERECHNUNGSMETHODEN\n');
fprintf('======================================================\n');
fprintf('Methode 1 (Direkt über Ohmsches Gesetz am PT100):\n');
fprintf('  Mittlerer Fehler (Bias) : %6.2f Ohm\n', bias_direkt);
fprintf('  RMSE (Gesamtabweichung) : %6.2f Ohm\n\n', rmse_direkt);

fprintf('Methode 2 (Rekonstruktion über Brückenspannung U_AB):\n');
fprintf('  Mittlerer Fehler (Bias) : %6.2f Ohm\n', bias_bruecke);
fprintf('  RMSE (Gesamtabweichung) : %6.2f Ohm\n', rmse_bruecke);
fprintf('======================================================\n');

%% 6. Visualisierung: Subplot-Layout für wissenschaftlichen Bericht
figure('Name', 'Methodenvergleich PT100', 'NumberTitle', 'off', 'Color', 'w', 'Position', [100, 100, 800, 800]);

% --- Subplot 1: Absolute Widerstandswerte ---
subplot(2,1,1);
% Ideallinie
T_plot = min(T)-2 : 0.1 : max(T)+2; 
R_plot = R0 .* (1 + A.*T_plot + B.*T_plot.^2);
plot(T_plot, R_plot, '-g', 'LineWidth', 2); hold on;

% Streudiagramm der beiden Methoden
plot(T, R_direkt, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
plot(T, R_bruecke, 'xr', 'LineWidth', 1.5, 'MarkerSize', 8);

grid on;
title('Absoluter Widerstand vs. Temperatur', 'FontSize', 12);
xlabel('Temperatur in °C');
ylabel('Widerstand R_{PT100} in \Omega');
legend('Idealkennlinie (DIN EN 60751)', 'Methode 1 (R = U_{B2} / I_B)', 'Methode 2 (über U_{AB})', 'Location', 'southeast');

% --- Subplot 2: Messfehler (Abweichung vom Soll) ---
subplot(2,1,2);
% Nulllinie (perfekte Messung ohne Fehler)
yline(0, '-g', 'LineWidth', 2); hold on;

% Fehler beider Methoden plotten
plot(T, fehler_direkt, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
plot(T, fehler_bruecke, 'xr', 'LineWidth', 1.5, 'MarkerSize', 8);

grid on;
title('Messabweichung vom Soll-Wert (Fehleranalyse)', 'FontSize', 12);
xlabel('Temperatur in °C');
ylabel('\DeltaR (Ist - Soll) in \Omega');
legend('Nullfehler-Linie', 'Fehler Methode 1', 'Fehler Methode 2', 'Location', 'northwest');