clc
clear all
close all

GRADO_POLINOMIAL = 10; 

ADC_START = 205;
ADC_END = 3890;

NOMBRE_ARCHIVO_SALIDA = 'calibration_data.txt'; 

try
    datos = readtable('Mediciones JDSU.xlsx'); 
catch
    error('No esta el xlsx');
end

% Extraer las columnas: x = ADC (columna 1), y = Atenuación [dB] (columna 2)
x = table2array(datos(:,1));
y = table2array(datos(:,2));

% Realizar el ajuste polinomial
polinomio = polyfit(x, y, GRADO_POLINOMIAL);

xLookup = ADC_START:1:ADC_END; 

yLookup_dB = polyval(polinomio, xLookup);

% 1. Multiplicar por 10 
% 2. Redondear al entero más cercano 
% 3. Convertir a tipo entero de 32 bits (int32)
yLookup_raw_scaled = round(yLookup_dB * 10);
yLookup_final = int32(yLookup_raw_scaled);

% Guardar la tabla en formato CSV sin encabezados.
writematrix(yLookup_final, NOMBRE_ARCHIVO_SALIDA, ...
    'Delimiter', ',', ...
    'WriteMode', 'overwrite');

disp('--------------------------------------------------');
disp(['Proceso completado.']);
disp(['Tabla de busqueda generada en: ' NOMBRE_ARCHIVO_SALIDA]);
disp(['Elementos generados: ' num2str(length(yLookup_final)) ' (3890 - 205 + 1)']);
disp(['Rango de ADC cubierto: ' num2str(ADC_START) ' a ' num2str(ADC_END)]);
disp(['Máx. atenuación real (dB): ' num2str(max(yLookup_final)/10)]);
disp('--------------------------------------------------');


% figure('Name', 'Validación de la Curva LUT');
% plot(x,y,'o', 'DisplayName', 'Mediciones JDSU (Raw)');
% hold on
% plot(xLookup, yLookup_dB, '-', 'DisplayName', 'Aprox. Polinomial Grado 10 (dB)');
% plot(xLookup, yLookup_final/10, '--', 'DisplayName', 'LUT Cuantizada (dB)'); % Se plotea la versión cuantizada para ver el error de discretización.
% hold off
% xlim([ADC_START-100 ADC_END+100])
% ylim([0 max(y)+5]) 
% xlabel('Div. ADC (12 bits)','FontSize',11);
% ylabel('Atenuación [dB]','FontSize',11);
% title('Curva de Calibración EVOA (Polinomio Grado 10)','FontSize',12);
% legend('Location','northwest','FontSize',10);
% grid on