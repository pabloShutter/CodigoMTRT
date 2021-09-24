% -------------------------------------------------------------------------
% function   printParametrosConv
% -------------------------------------------------------------------------
% Presenta parametros Pr�ctica Tema 3
% -------------------------------------------------------------------------
% variables usadas
%    M   n�mero de s�mbolos del alfabeto M-QAM
%    indicePerforado   �ndice del patr�n de perforado
%    Fs  Frecuencia de s�mbolo
%    Ts  Intervalo de s�mbolo
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 31-5-2016  Jos� Tom�s Entrambasaguas
% 1-5-2020 Modificaci�n: de script se pasa a funci�n. 
% -------------------------------------------------------------------------
function printParametrosConv(M, snrdB, indicePerforado, Fs, Ts)

fprintf('\nParametros sistema')
if nargin > 0
   fprintf('\n   Modulacion %d-QAM', M)
end
if nargin > 1
   fprintf('\n   SNR %g (dB)', snrdB)
end
if nargin > 2
    fprintf('\n   IndicePerforado: %d', indicePerforado)
end
if nargin > 3
   fprintf('\n   Frecuencia de simbolo %g kHz', Fs/1000)
end
if nargin > 4
   fprintf('\n   Intervalo de simbolo %g ms', Ts*1000)
end
fprintf('\n')
