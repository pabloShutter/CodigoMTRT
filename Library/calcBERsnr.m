%--------------------------------------------------------------------------
% Descripcion: Ejecuta el sistema para varias tramas de bits
% Mide BER promediando entre las tramas
%--------------------------------------------------------------------------
% Entradas:
% ssnrdB: vector de valores de snrdB
% Ntramas: Numero de tramas (bloques) a codificar
% trellisEnc: Estructura con el diagrama de trellis del codigo. Usado para
% inicializar los objetos codificador y decodificador
% Salidas: 
% bber_m: medidas BER bits no codificados
% bber_c: medidas BER bits codificados
%--------------------------------------------------------------------------

function [bber_m, bber_c] = ...
    calcBERsnr(ssnrdB, Ntramas, Nbits, M, trellisEnc)

bber_m = zeros(size(ssnrdB));
bber_c = zeros(size(ssnrdB));
codterminado = false; % tipo de terminacion del codigo

fprintf('\nSNR = ');

for kSnr = 1:length(ssnrdB)
    snrdB = ssnrdB(kSnr); fprintf('%g ', snrdB)
    
    % Creacion objetos sistema:
    % -------------------------------------------------------------------------
    % Crea e inicializa los objetos cod. y decod. convolucionales
    [hCod, hDecod, retardoDecod] = iniCodificacion(trellisEnc, codterminado);
    
    % Creacion e inicializacion de objetos del modulador y demodulador M-QAM
    [hMod, hDemod] = iniModulacion(M);
    
    % Creacion e inic. del objeto que modela el canal AWGN
    hCanalAWGN = iniCanalAWGN(snrdB);
    
    % crea dos objetos para medida de tasa binaria de errores
    [hErr_c, hErr_m] = iniMedidaBER(retardoDecod);
    
    % Simulacion del sistema:
    % -------------------------------------------------------------------------
    % Ejecuta el sistema y devuelve las secuencias del mensaje, del mensaje
    % codificado, de la señal modulada (M-QAM) y de la señal escalada
    
    BER_m = zeros(1, Ntramas);
    BER_c = zeros(1, Ntramas);
    
    for contTrama = 1:Ntramas
        % Ejecuta el sistema 
        [seq, err_c, err_m] = ...
            ejecSistema(M, Nbits, hCod, hMod, hCanalAWGN, hDemod, hDecod, ...
            hErr_c, hErr_m);
        
        BER_m(contTrama) = err_m(1);
        BER_c(contTrama) = err_c(1);
    end
    
    bber_m(kSnr) = sum(BER_m)/Ntramas;
    bber_c(kSnr) = sum(BER_c)/Ntramas;
end
fprintf('\n');
