load('C:\Users\pablo\OneDrive - Universidad de Málaga\TFM_MIT\Simulador\CANAL_UAC\CanalUACmedido\LTVch_medidos\2017-06-02 09.47.44_ME_D50_S12.5__PB__SMultitono_fo80k_B96k_N1609_CAL.mat')
% load('C:\Users\pablo\OneDrive - Universidad de Málaga\TFM\Simulador\CANAL_UAC\CanalUACmedido\LTVch_medidos\RespuestasAlineadasRayoPpal\2017-06-02 09.47.44_ME_D50_S12.5__SMultitono_fo80k_B96k_N1609__ALIN.mat')

%% Configuración del simulador
dib=0;

%% Parámetros QPSK
Ps=2; % Potencia de la señal
d=sqrt(2*Ps);

%% Parámetros OFDM
fs=500e3;        % Frecuencia de muestreo
Tm=1/fs;         % Periodo de muestreo

fc=80e3;    % Frecuencia portadora modulación paso banda (DMT)
%% Parametros del Canal
% N0_2=1e-13;
% Respuesta variante con el tiempo (LTV) del canal UAC medido
canal=1;  % Receptor seleccionado (se utilizaron dos receptores)
h=TimeResponse.h{canal};   % Resp imp LTV
Delay=TimeResponse.delay(TimeResponse.delay<=10e-3);
t=TimeResponse.t;

Tm=Delay(2)-Delay(1); %Periodo de muestreo
fm=1/Tm;              %Frecuencia de muestreo

%Representación resp imp LTV mapa de colores
if dib==1
    figure; fig=gcf;
    set(fig,'units','normalized','outerposition',[0 0 1 1],'name','Respuesta al impulso variante');
    color={'r','g','b','c','k','y'};
    colormap('jet');
    imagesc(Delay*1e3, t,20*log10(abs(h(:,Delay<=10e-3))) - 20*log10(max(max(abs(h)))),[-40,0])

    colorbar; set(gca, 'YDir','normal')
    xlabel(' delay (ms) '); ylabel(' time (sec) ');
    title( [' Respuesta impulsiva variante del canal ', num2str(canal)] );
end