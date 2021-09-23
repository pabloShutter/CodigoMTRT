% -----------------------------------------------------------
% freqIndex.m
%
% Devuelve el �ndice Matlab (semieje negativo a continuaci�n
% del positivo) para una determinada frecuencia que se le pasa
% como par�metros. Si esa frecuencia concreta no est� en el eje
% de frecuencia, se devuelve el �ndice de la siguiente frecuencia
% m�s cercana.
% -----------------------------------------------------------
% function [index,f]=freqIndex(freq,fs,Df)
% -----------------------------------------------------------
% Entrada/s:
%   freq: valor de la frecuencia de entrada
%   fs:   frecuencia de muestreo
%   Df:   paso en frecuencia
% Salidas:
%   index: �ndice de la frecuencia 'freq' o una frec cercana
%   f:     frec correspondiente a 'index' en el eje de frecuencias
% -----------------------------------------------------------

function [index,f]=freqIndex(freq,fs,Df)

%eje de frecuencia Matlab
tam=int32(fs/Df);
f_axis=zeros(1,tam);
f_axis(1:tam/2)=0:Df:fs/2-Df;
f_axis(tam/2+1:end)=-fs/2:Df:-Df;

index=find(f_axis>=abs(freq),1);
if freq<0
    index=(tam+1)-(index-1);
end
f=f_axis(index);
