% -----------------------------------------------------------
% Receptor OFDM
% Elimina el prefijo ciclico
% Calcula el s�mbolo en el dominio de la frecuencia
% Reordena los s�mbolos (deshace la reordenaci�n del transmisor)
% -----------------------------------------------------------
% function V=RxOFDM12(v,N,M,Nutil,dib)
% -----------------------------------------------------------
% v: simbolo de entrada (longitud: N+M)
% V: vector de simbolos de salida (longitud: Nutil)
% N: Numero de puntos de la FFT
% M: Numero de muestras del prefijo c�clico
% Nutil: Numero de portadoras �tiles
% dib: 1: dibujar gr�ficas, 0: no dibujar
% -----------------------------------------------------------

function Q=RxOFDM(v,FEQ,Nutil, iFc)

Yo=fft(v);                  % FFT

Y=Yo.*FEQ; %Compensaci�n del canal

% Deshago la interpolaci�n en frecuencia para quedarme con los Nutil
% s�mbolos QPSK:
Q=zeros(1,Nutil);
Q(1:Nutil/2)=Y(iFc-Nutil/2:iFc-1);
Q(Nutil/2+1:Nutil)=Y(iFc+1:iFc+Nutil/2);