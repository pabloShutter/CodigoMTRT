% -------------------------------------------------------------------------
% function [hCod  ,hDecod, retardoDecod] = iniCodificacion(trellisEnc, ...
% codterminado, patronPerforado)
% -------------------------------------------------------------------------
% Crea los objetos de codificaci�n y decodificaci�n de canal:
%     Codificacion convolucional con perforado
%     Decodificacion con algoritmo de viterbi
% -------------------------------------------------------------------------
% Entradas
%    trellisEnc        descriptor del codificador convolucional
%                      (ver ayuda de 'defineCodigoConvolucional'
%    patronPerforado   vector binario con patron de perforado
%                      [si se omite no se hace perforado]  
%    codterminado      true -> indica que el c�digo es terminado, el estado
%                      final y el inicial es conocido (estado S0)
%                      false (o par�metro no presente) -> modo continuo, 
%                      el estado final no es conocido, y por tanto la 
%                      decisi�n sobre el bit n, se toma retardoDecod 
%                      instantes despu�s (retardo en decodificaci�n)
% -------------------------------------------------------------------------
% Salidas
%    hCod          objeto codificador convolucional
%    hDecod        objeto decodificador de Viterbi
%    retardoDecod  retardo del decodificador de Viterbi
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 9-6-2015  Jos� Tom�s Entrambasaguas
% 1-5-2020  Modificaci�n: Se a�ade la opci�n de definit c�digos terminados
% -------------------------------------------------------------------------

function [hCod  ,hDecod, retardoDecod] = iniCodificacion(trellisEnc, ...
    codterminado, patronPerforado)

hCod     = comm.ConvolutionalEncoder (trellisEnc);
hDecod   = comm.ViterbiDecoder       (trellisEnc);

set(hDecod, 'InputFormat','Hard');  % decodificaci�n dura

% Nota: Los objetos de librer�a comm no soportan estar perforados y con
% terminaci�n de trellis. Si codterminado == true, no se perfora. Habr�a
% que perforar despues de codificar si se quiere c�digo terminado y
% perforado. 
aplicarCodTerminado = (nargin > 1) && (codterminado);

if aplicarCodTerminado
    set(hCod, 'TerminationMethod', 'Terminated');
    set(hDecod, 'TerminationMethod', 'Terminated');
    retardoDecod = 0;
else
    % Calculo retardo decodificacion
    MM = hDecod.TrellisStructure.numInputSymbols;
    bitSimbolo = log2(MM);
    retardoDecod = hDecod.TracebackDepth * bitSimbolo;  % retardo Viterbi
end

if (nargin > 2)  % perforado 
    if (~aplicarCodTerminado)
       set(hCod,   'PuncturePatternSource','Property');
       set(hDecod, 'PuncturePatternSource','Property');
       set(hCod,   'PuncturePattern', patronPerforado);
       set(hDecod, 'PuncturePattern', patronPerforado);   
    else
        warning(['La librer�a comm no soporta configurar c�digos '...
            'terminados y perforados.']);
    end
end






