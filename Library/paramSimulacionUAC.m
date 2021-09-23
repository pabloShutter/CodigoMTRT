path(path, 'Library');

fs=500e3;        % Frecuencia de muestreo
Tm=1/fs;         % Periodo de muestreo

%% Par�metros QPSK
Ps=2; % Potencia de la se�al
d=sqrt(2*Ps);

fc=80e3;    % Frecuencia portadora modulaci�n paso banda (DMT)

%% Parametros del Canal

% Par�metros del modelo UAC
fmin=20e3;
fmax=140e3;
d0=100;  % Separaci�n Tx-Rx (m)
wTx=14;   % Profundidad Tx
wRx=14;   % Profundidad Rx
w=20;    % Profundidad fondo marino (desde superficie)
pmax=50; % N�mero m�ximo de rayos significativos considerados
dib=0;   % Representaci�n respuesta del canal: '0'->No, '1'->S�