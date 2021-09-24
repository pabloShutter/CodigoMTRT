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
path(path,'Library/TTSClib_RS')
% Añadir el path con la libreria de codificacion convolucional al workspace
path(path,'Library/TTSClib_conv')

% Parametros sistema: 
% -------------------------------------------------------------------------
tipoRuido = 1;  %tipo de ruido añadido en la sim ('0' sin ruido,'1' AWGN,'2' UWAN)
codRecur = 0;  %tipo de cod. convolucional utilizado ('0' no recursivo, '1' recursivo)
canalLTV = 1;  %variación del canal ('0' canal LTI, '1' canal LTV)
mod='DQPSK';  %modulación empleada: 'QPSK', '2DPSK' o 'DQPSK'

Nutil = 980;
Nbits = 1000*Nutil; % Numero de bits del mensaje (bloque a codificar)
snrdB = 46.25; %Relacion potencia de señal a potencia de ruido en dB
M = 4; % Numero de simbolos de la constelacion M-QAM

indicePerforado = 1; % Indice para seleccion del patron de perforado

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
if codRecur
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
[seq,err_c,err_m,SNRdB_symb,SNRdBb_c,BERxSimb] = ejecSistemaLTV(M, Nbits,hCod,snrdB, ...
    hDecod,hErr_c,hErr_m,tipoRuido,mod,tasaCod,patronPerforado);

fprintf('%g ', SNRdBb_c)

fprintf('\n')

fprintf('BER palabra-código : %d', err_c(1))

fprintf('\nBER mensaje      : %d', err_m(1))

fprintf('\n\n')

%% Representaciones gráficas
Rc=1/2;
if strcmp(mod,'DQPSK') || strcmp(mod,'QPSK')
    nbitxSimb=2*Nutil*Rc; %por simb decodif. Mod QPSK o DQPSK (Rc=1/2)
elseif strcmp(mod,'2DPSK')
    nbitxSimb=Nutil*Rc;
end
nSymb=length(seq.t_m)/nbitxSimb;
err_m_Simb=zeros(1,nSymb);

for kSymb=1:nSymb
    BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb)); % Ventana para el vector de bits
    e = step(hErr_m, seq.t_m(BitWin), seq.r_m(BitWin));
    err_m_Simb(kSymb) = e(1);
end

err_m_Simb(1)=BERxSimb(1);
for i=2:10
    err_m_Simb(i)=(err_m_Simb(i-1)+err_m_Simb(i+1))/2;
end

figure('Name','BER por símbolo OFDM recibido tras codif')
plot(err_m_Simb,'Linewidth',1.1), grid on, hold on
xlabel('Índice de símbolo OFDM recibido'),title('BERc/simbOFDM')

figure(1), hold on
plot(err_m_Simb(1:1e3),'Linewidth',1.1), grid on
xlabel('Índice de símbolo OFDM recibido'),title('BERc/simbOFDM')
