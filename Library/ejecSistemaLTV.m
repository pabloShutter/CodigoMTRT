% -------------------------------------------------------------------------
%% Descripcion: 
% Esta funcion genera un mensaje en bits que codifica acorde a un codigo
% convolucional, modula, hace pasar por un canal aditivo gaussiano, 
% demodula y decodifica.
% -------------------------------------------------------------------------
%% Entradas:
% M:      Tama�o de la modulacion. Numero de simbolos de la constelacion. 
% Nbits:  Numero de bits del mensaje (bloque a codificar)
% hCod:   Objeto para codificar 
% SNRdB:  Relacion potencia de se�al a potencia de ruido en dB
% hDecod: Objeto para decodificar
% hErr_c: Objeto de medida de errores en palabra-c�digo
% hErr_m: Objeto de medida de errores en mensaje

%% Salidas
% seq.t_m: Secuencia transmitida de bits del mensaje
% seq.t_c: Secuencia transmitida de bits codificados (trama o bloque 
% codificado)
% seq.r_c: Seq. de bits demodulada
% seq.r_m: Seq. de bits del mensaje decodificada

% err_c: tasa de error de bit de palabra-c�digo
% err_m: tasa de error de bit de mensaje
% SNRdB_symb: SNR por s�mbolo de la se�al recibida
% SNRdBb_c: SNR referida a la energ�a de bit codificado
% BERxSimb: BER por cada s�mbolo OFDM recibido


% -------------------------------------------------------------------------
function [seq, err_c, err_m, SNRdB_symb, SNRdBb_c,BERxSimb] = ...
    ejecSistemaLTV(M, Nbits, hCod, SNRdB, hDecod, hErr_c, hErr_m, ...
    tipoRuido,mod,tasaCod, patronPerforado)

%% Ajuste del tama�o de trama
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

%% Canal Discreto Equivalente (CDE)
[r_c,SNRdB_symb,SNRdBb_c,BERxSimb] = CDE_UAC_LTV(t_c,SNRdB,tipoRuido,mod);
%% Recepci�n

% Decodificacion
r_m = step(hDecod,r_c);

%% Agrupa se�ales en estructura
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

