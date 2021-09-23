% -------------------------------------------------------------------------
%% Descripcion: 
% Esta funcion genera un mensaje en bits que codifica acorde a un codigo
% convolucional, modula, hace pasar por un canal aditivo gaussiano, 
% demodula y decodifica.
% -------------------------------------------------------------------------
%% Entradas:
% M: Tamaño de la modulacion. Numero de simbolos de la constelacion. 
% Nbits: Numero de bits del mensaje (bloque a codificar)
% hCod: Objeto para codificar 
% hMod: Objetdo para modular. 
% hCanalAWGN: Objeto que modela un canal que suma ruido blanco gaussiano
% hDemod: Objeto para demodular. Pasa de simbolos M-QAM recibidos con ruido
% y reescalados en potencia a bits (del mensaje codificado). 
% hDecod: Objeto para decodificar
% hErr_c: Objeto de medida de errores en palabra-código
% hErr_m: Objeto de medida de errores en mensaje

% (Cambiar Entradas a partir del apartado 3.3.1c)

%% Salidas
% seq.t_m: Secuencia transmitida de bits del mensaje
% seq.t_c: Secuencia transmitida de bits codificados (trama o bloque 
% codificado)
% seq.r_c: Seq. de bits demodulada
% seq.r_m: Seq. de bits del mensaje decodificada

% err_c: tasa de error de bit de palabra-código
% err_m: tasa de error de bit de mensaje

% (Cambiar Salidas a partir del apartado 3.3.1c) 

% -------------------------------------------------------------------------
function [seq,err_c,err_m, SNRdB_rx] = ...
    ejecSistemaSNRs(M, Nbits, hCod, SNRsdB, hDecod, hErr_c, hErr_m)

%% Ajuste del tamaño de trama
if nargin > 9
    % Esta linea se ejecuta a partir del apartado 3.4.1
    % Ajuste de Nbits para numero entero de simbolos QAM y periodos de perforado
    NbitsRM = rateMatching(Nbits, M, tasaCod, patronPerforado);
else
    NbitsRM = Nbits;
end

%% Transmision
% Generacion de un mensaje bits aleatorios de longitud de NbitsRM
t_m = randi([0 1], NbitsRM, 1);

% Codificacion convolucional
t_c = step(hCod,t_m);

%% Canal discreto equivalente (CDE)
% r_c = CDE_FIR(t_c);
[r_c,SNRdB_rx] = CDE_UAC(t_c,SNRsdB);

%% Recepcion
% Decodificacion
r_m = step(hDecod,r_c);

%% Agrupa señales en estructura
seq.t_m = t_m;
seq.t_c = t_c;
seq.r_c = r_c;
seq.r_m = r_m;

% Completar para calcular salidas despues en apartado 3.3.1c
% Medida de errores
if nargin > 5
    err_c = step(hErr_c, t_c, r_c);
    err_m = step(hErr_m, t_m, r_m);
end



end

