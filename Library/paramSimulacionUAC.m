path(path, 'Library');

fs=500e3;        % Frecuencia de muestreo
Tm=1/fs;         % Periodo de muestreo

%% Parámetros QPSK
Ps=2; % Potencia de la señal
d=sqrt(2*Ps);

fc=80e3;    % Frecuencia portadora modulación paso banda (DMT)

%% Parametros del Canal

% Parámetros del modelo UAC
fmin=20e3;
fmax=140e3;
d0=100;  % Separación Tx-Rx (m)
wTx=14;   % Profundidad Tx
wRx=14;   % Profundidad Rx
w=20;    % Profundidad fondo marino (desde superficie)
pmax=50; % Número máximo de rayos significativos considerados
dib=0;   % Representación respuesta del canal: '0'->No, '1'->Sí