% -------------------------------------------------------------------------
% function [hCod  ,hDecod, retardoDecod] = iniCodificacion(trellisEnc, ...
% codterminado, patronPerforado)
% -------------------------------------------------------------------------
% Crea los objetos de codificación y decodificación de canal:
%     Codificacion convolucional con perforado
%     Decodificacion con algoritmo de viterbi
% -------------------------------------------------------------------------
% Entradas
%    trellisEnc        descriptor del codificador convolucional
%                      (ver ayuda de 'defineCodigoConvolucional'
%    patronPerforado   vector binario con patron de perforado
%                      [si se omite no se hace perforado]  
%    codterminado      true -> indica que el código es terminado, el estado
%                      final y el inicial es conocido (estado S0)
%                      false (o parámetro no presente) -> modo continuo, 
%                      el estado final no es conocido, y por tanto la 
%                      decisión sobre el bit n, se toma retardoDecod 
%                      instantes después (retardo en decodificación)
% -------------------------------------------------------------------------
% Salidas
%    hCod          objeto codificador convolucional
%    hDecod        objeto decodificador de Viterbi
%    retardoDecod  retardo del decodificador de Viterbi
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 9-6-2015  José Tomás Entrambasaguas
% 1-5-2020  Modificación: Se añade la opción de definit códigos terminados
% -------------------------------------------------------------------------

function [hCod  ,hDecod, retardoDecod] = iniCodificacion(trellisEnc, ...
    codterminado, patronPerforado)

hCod     = comm.ConvolutionalEncoder (trellisEnc);
hDecod   = comm.ViterbiDecoder       (trellisEnc);

set(hDecod, 'InputFormat','Hard');  % decodificación dura

% Nota: Los objetos de librería comm no soportan estar perforados y con
% terminación de trellis. Si codterminado == true, no se perfora. Habría
% que perforar despues de codificar si se quiere código terminado y
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
        warning(['La librería comm no soporta configurar códigos '...
            'terminados y perforados.']);
    end
end






