% -------------------------------------------------------------------------
% function [hErr_c,hErr_m] = iniMedidaBER(retardoDecod)
% -------------------------------------------------------------------------
% Crea dos objetos de medida de tasa binaria de errores
% -------------------------------------------------------------------------
% Entradas
%    retardoDecod   retardo del decodificador de Viterbi
% -------------------------------------------------------------------------
% Salidas
%    hErr_c   objeto medidor de BER
%    hErr_m   objeto medidor de BER
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 28-5-2015  Jos� Tom�s Entrambasaguas
% -------------------------------------------------------------------------

function [hErr_c,hErr_m] = iniMedidaBER(retardoDecod)

hErr_c = comm.ErrorRate('ComputationDelay',6); % no contar errores al principio
hErr_m = comm.ErrorRate('ReceiveDelay',retardoDecod); % retardo Viterbi


