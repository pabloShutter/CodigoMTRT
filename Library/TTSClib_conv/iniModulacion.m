% -------------------------------------------------------------------------
% function  [hMod, hDemod] = iniModulacion(M)
% -------------------------------------------------------------------------
% Crea objetos de modulacion y demodulacion QAM
% -------------------------------------------------------------------------
% Entradas
%    M        numero de simbolos del alfabeto M-QAM
% -------------------------------------------------------------------------
% Salidas
%    hMod     objeto modulador M-QAM cuadrado
%    hDemod   objeto demodulador M-QAM cuadrado                                  
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 28-5-2015  José Tomás Entrambasaguas
% -------------------------------------------------------------------------

function  [hMod, hDemod] = iniModulacion(M)
hMod     = comm.RectangularQAMModulator   (M);
hDemod   = comm.RectangularQAMDemodulator (M);
set(hMod,   'BitInput' ,true);
set(hDemod, 'BitOutput',true);                                  
