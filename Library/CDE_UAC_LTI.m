% -----------------------------------------------------------
% Autor: Pablo Cobacho
% -----------------------------------------------------------
% SimUAC.m
% Script que simula un sistema de comunicaciones digitales
% en el que se transmite una secuencia de símbolos OFDM 
% utilizando codificación QPSK y modulación DMT
% -----------------------------------------------------------
% ENTRADAS:
%   t_c:         vector de bits de entrada al CDE
%   snrdB_in:    valor SNR para el cálculo del ruido del canal (sin FEQ)
%   tipoRuido:   tipo de ruido aditivo ('0' sin ruido,'1' AWGN,'2' UWAN)
% SALIDAS:
%   r_c:         vector de bits de salida tras pasar por el CDE
%   SNRdB_symb:  SNR por símbolo de la señal recibida
%   SNRdB_c:     SNR referida a la energía de bit codificado

function [r_c,SNRdB_symb, SNRdBb_c] = CDE_UAC_LTI(t_c,snrdB_in,tipoRuido)

%% Configuración del simulador
canalUAC=true;  %'1' canal UAC, '0' canal ideal

paramSimulacionUAC

% PARÁMETROS OFDM
N=4096;          % Número de puntos de la FFT
M=N*1/2;         % Número de muestras del prefijo cíclico
Nutil=784;       % Numero de portadoras útiles

nbitxSimb=Nutil*2;           % # de bits por simb OFDM
nSymb=length(t_c)/nbitxSimb; % # de simb OFDM
nbit=nbitxSimb*nSymb;        % # total de bits
nSymbQPSK=Nutil*nSymb;       % # total de simb QPSK

T=(N+M)*nSymb/fs;      % Duracion de la simulacion
t=0:Tm:T-Tm;     % eje de tiempos
Fsimb=1/T;       % Frec de símbolo
Df=fs/N;             % Separación entre portadoras
f=-fs/2:Df:fs/2-Df;  % eje de frecuencia OFDM

%% ************ Respuesta del canal UAC ********************
[H,h]=RespuestaUAC(fmin,fmax,100,wTx,wRx,w,pmax, dib);
ret=length(h)-1;

% Estimación del FEQ e índice retardo inicial respuesta impulsiva (sincro)
if canalUAC
    sincro=energyTrigger(h,20);
    h_FEQ=h(sincro:end);
    H_FEQ=fft(h_FEQ,N);
    FEQ=1./(H_FEQ+eps);
else
    sincro=1;
    FEQ=1;
end

%% **************  MODULADOR DIGITAL *******************

tx=zeros(1,(N+M)*nSymb);     % Inicializamos el vector de la señal OFDM
AA=zeros(1,nSymbQPSK);       % Vector de símbolos QPSK que se van a transmitir

iFc=freqIndex(fc,fs,Df);     %índice matlab de frec portadora banda útil
iFcH=freqIndex(-fc,fs,Df);   %índice matlab frec portadora banda hermítica

for kSymb=1:nSymb
   BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb)); % Ventana para el vector de bits
   b=t_c(BitWin);
   
   A=CodSimbQPSK(b,d);                 % Se codifican los bits en símbolos QPSK
   QPSKwin=(kSymb-1)*Nutil+(1:Nutil);  % Ventana para el vector de símbolos QPSK
   AA(QPSKwin)=A;      % Se añaden los Nutil símbolos QPSK al vector de 
                       % símbolos QPSK a transmitir                          
   s=TxOFDM(A,N,M,Nutil,iFc,iFcH);    % Se modulan los símbolos QPSK en un símbolo OFDM
   OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); % Ventana para el vector de símbolos OFDM
   tx(OFDMwin)=s;                     % escribe un bloque de señal
end

%% ********************  CANAL *************************
% Filtrado respuesta al impulso h[n]
if canalUAC
    sf=conv(h,tx);
else
    sf=tx;
end

% Ruido aditivo

    % a. Cálculo de la DEP de ruido a partir de la SNR
SNR=10^(snrdB_in/10);
senyal=FEQyQuitaCP(sf,N,M,Nutil,FEQ,nSymb,iFc,iFcH);
Er=sum(abs(senyal).^2)*Tm/nSymbQPSK;
Eb=Er/2;
N0_2=Eb/(2*SNR);

    % b. Vector temporal de la señal tras la convolucion del canal
if canalUAC
    Tn=((N+M)*nSymb+ret)/fs; % Duracion de la señal de ruido
    tn=0:Tm:Tn-Tm;
else
    tn=t;
end

    % c. Inclusión del vector de ruido a la señal
if tipoRuido==1
    n=Ruido(tn,N0_2);        % muestras de ruido AWGN
    yy=sf+n;                % Señal filtrada con ruido AWG
elseif tipoRuido==2
    n=RuidoUWAN(tn,N0_2*390,dib); %Factor 390 para N0_2 media en la banda útil sea aprox 10^-3 W/Hz
    yy=sf+n;
else
    yy=sf;
end

%% *************  DEMODULADOR DIGITAL ******************
QQ=zeros(1,nSymbQPSK);  %Símbolos QPSK recibidos
AAest=QQ;               %Símbolos QPSK decididos
r_c=zeros(1,nbit); % 2 bits/symb QPSK

rr=yy(sincro:end); %Desprecio el retardo introducido por el filtro

for kSymb=1:nSymb
    OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); %Ventana para recibir el símbolo OFDM
    r=rr(OFDMwin);
    
    ro=r((1+M):(N+M));  % Desprecia CP
    Q=RxOFDM(ro,FEQ,Nutil, iFc);  % escribe un bloque de señal
    
    QPSKwin=(kSymb-1)*Nutil+(1:Nutil);
    QQ(QPSKwin)=Q;
    [aest,best]=DecisorQPSK(Q,d);  % Decisor QPSK y bits
    AAest(QPSKwin)=aest;         % Vector de símbolos QPSK decididos
    
    BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb));
    r_c(BitWin)=best;          % Vector de bits decididos
end

r_c=r_c.';

%% ****************  PRESTACIONES  *********************
% 1. Probabilidad de error de símbolo y de bit simuladas
errsim=abs(AAest-AA);     % secuencia de errores de simbolo
errbit=abs(r_c-t_c);     % secuencia de errores de bits
 
PM=nnz(errsim)/nSymbQPSK;     % probabilidad de error de simbolo
Pb=nnz(errbit)/nbit;  % probabilidad de error de bit


% Cálculo de la SNR rx después de la igualación
if tipoRuido~=0
    ruido=FEQyQuitaCP(n,N,M,Nutil,FEQ,nSymb,iFc,iFcH);
    ruidoDEP=EstimaDEP(ruido,N,fs,'b');
    nDEP=[ruidoDEP(iFc-Nutil/2:iFc-1) ruidoDEP(iFc+1:iFc+Nutil/2)];
    N0_22=mean(nDEP);
    SNRdBb_c=10*log10(Eb/(2*N0_22));
    SNRdB_symb=10*log10(Er/(2*N0_22));
else
    SNRdBb_c=inf;
    SNRdB_symb=inf;
end
