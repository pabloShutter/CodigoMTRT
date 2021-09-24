% -------------------------------------------------------------------------
% function   printParametrosConv
% -------------------------------------------------------------------------
% Presenta parametros Práctica Tema 3
% -------------------------------------------------------------------------
% variables usadas
%    M   número de símbolos del alfabeto M-QAM
%    indicePerforado   índice del patrón de perforado
%    Fs  Frecuencia de símbolo
%    Ts  Intervalo de símbolo
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 31-5-2016  José Tomás Entrambasaguas
% 1-5-2020 Modificación: de script se pasa a función. 
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
