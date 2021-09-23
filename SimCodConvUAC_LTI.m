% -------------------------------------------------------------------------
% Descripcion
% -------------------------------------------------------------------------
% transmision con codificacion convolucional

% Inicio entorno
% -------------------------------------------------------------------------
% Liberar memoria, borrar variables del workspace
clear
% Cierra todas las figuras abiertas
close all; 
% Limpia la patalla
clc
path(path,'Library')
% Añadir el path con la libreria de Reed-Solomon al workspace
path(path,'../TTSClib_RS')
% Añadir el path con la libreria de codificacion convolucional al workspace
path(path,'../TTSClib_conv')
% Añadir el path con la librería de la rutina commcnv_plotnextstates para
% diagrama de trellis
addpath 'C:\Users\pablo\Documents\MATLAB\Examples\R2019b\comm\CreateUserDefinedTrellisStructureExample'

% Parametros sistema: 
% -------------------------------------------------------------------------
tipoRuido = 1;  %tipo de ruido añadido en la sim ('0' sin ruido,'1' AWGN,'2' UWAN)
recursivo = 0;  %tipo de cod. convolucional utilizado ('0' no recursivo, '1' recursivo)

Nutil = 784;
Nbits = 300*Nutil; % Numero de bits del mensaje (bloque a codificar)
ssnrdB = (44.25:2:56.25); % Vector valores de SNR en dB
M = 4; % Numero de simbolos de la constelacion M-QAM. 

indicePerforado = 2; % Indice para seleccion del patron de perforado

codterminado = false; % A true, indica que el codigo es terminado (los 
% estados de inicio y de fin son conocidos) o si el codigo es continuo. 
% El estado de inicio de cada bloque a codificar es el ultimo del bloque 
% anterior. Si el codigo es terminado, se añaden K-1 bits de cola para que 
% el codigo retorne al estado cero. Si el codigo es continuo, hay un 
% retardo en la decodificacion igual a la profundidad de los recorridos 
% hacia atras. 

% Imprime los parametros de entrada a la llamada de la funcion 
% printParametrosConv(M, ssnrdB, indicePerforado);

% Devuelve los descriptores de un codigo convolucional predeterminado. 
% Se usan para crear e inicializar los objetos codificador y decodif.
if recursivo
    [trellisEnc, tasaMadre] = defineCodigoConvolucional_PDSCH_RSC_LTE();
else
    [trellisEnc, tasaMadre] = defineCodigoConvolucional(); 
end

% Obtiene 6 patrones de perforado predefinidos con sus respectivas tasas de
% perforacion
[patronesPerforado, tasasPerforado] = definePatronesPerforado();

% Calcula la tasa de codificacion de cada codigo derivado del mismo codigo
% madre al que se le aplica distinto patron de perforamiento
tasasCod = tasaMadre./tasasPerforado;

bber_m = zeros(size(ssnrdB));
bber_c = zeros(size(ssnrdB));
ssnrdB_c = zeros(size(ssnrdB));
ssnrdB_symb = zeros(size(ssnrdB));

fprintf('\nSNR = ')

for kSnr = 1:length(ssnrdB)
    snrdB=ssnrdB(kSnr); %fprintf('%g ', snrdB)       
    
    % Creacion objetos sistema: 
    % -------------------------------------------------------------------------
    % Selecion del patron perforado a partir del indice a usar
    patronPerforado = patronesPerforado{indicePerforado};

    % Selecion de la tasa de codificacion a partir del indice de perforacion
    tasaCod = tasasCod(indicePerforado);
    
    % Crea e inicializa los objetos cod. y decod. convolucionales
    [hCod, hDecod, retardoDecod] = iniCodificacion(trellisEnc, ...
        codterminado,patronPerforado);

    % Creacion de objetos de medida de errores:
    [hErr_c, hErr_m] = iniMedidaBER(retardoDecod);

    %% Simulacion del sistema:
    % Ejecuta el sistema y devuelve las secuencias del mensaje, del mensaje
    % codificado, de la señal modulada (M-QAM) y de la señal escalada
    [seq,err_c,err_m,SNRdB_symb,SNRdBb_c] = ejecSistemaLTI(M, Nbits,hCod,snrdB, ...
        hDecod,hErr_c,hErr_m,tipoRuido,tasaCod,patronPerforado);
    
    fprintf('%g ', SNRdBb_c)
    
    bber_m(kSnr) = err_m(1);
    bber_c(kSnr) = err_c(1);
    ssnrdB_c(kSnr) = SNRdBb_c;
    ssnrdB_symb(kSnr) = SNRdB_symb;
end

fprintf('\n')

fprintf('BER palabra-código :')
for j=1:length(bber_c)
    fprintf(' %d',bber_c(j))
end

fprintf('\nBER mensaje        :')
for k=1:length(bber_m)
    fprintf(' %d',bber_m(k))
end

fprintf('\n\n')

%% Representaciones gráficas
if tipoRuido~=0 && length(ssnrdB)>1
    tasaCoddB = 10*log10(tasaCod);
    ssnr_b_m = ssnrdB_c - tasaCoddB;
    
    figure
    % A. Crea graficas de BER sobre bits codificados y decodificados vs SNR por
    % bit codificado
    semilogy(ssnrdB_c, bber_m, ssnrdB_c, bber_c, '--','Linewidth',1.5); hold on;
    % B. Crea graficas de BER sobre bits codificados y decodificados vs SNR por
    % bit del mensaje
    semilogy(ssnr_b_m, bber_m,'Linewidth',1.5); hold on; 

    ylabel('BER'); xlabel('SNR (dB)'); grid on;
    legend('bber_m - SNRb_c','bber_c - SNRb_c', ...
        'bber_m - SNRb')
end

if recursivo
   % Representacion diagrama de trellis
    commcnv_plotnextstates(trellisEnc.nextStates) 
end

