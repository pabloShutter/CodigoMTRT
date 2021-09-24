% -----------------------------------------------------------
% Autor: Pablo Cobacho
% -----------------------------------------------------------
% SimUAC.m
% Script que simula un sistema de comunicaciones digitales
% en el que se transmite una secuencia de s�mbolos OFDM 
% utilizando codificaci�n QPSK y modulaci�n DMT
% -----------------------------------------------------------
% ENTRADAS:
%   t_c:         vector de bits de entrada al CDE
%   snrdB_in:    valor SNR para el c�lculo del ruido del canal (sin FEQ)
%   tipoRuido:   tipo de ruido aditivo ('0' sin ruido,'1' AWGN,'2' UWAN)
% SALIDAS:
%   r_c:         vector de bits de salida tras pasar por el CDE
%   SNRdB_symb:  SNR por s�mbolo de la se�al recibida
%   SNRdB_c:     SNR referida a la energ�a de bit codificado

function [r_c,SNRdB_symb, SNRdBb_c] = CDE_UAC_LTI(t_c,snrdB_in,tipoRuido)

%% Configuraci�n del simulador
canalUAC=true;  %'1' canal UAC, '0' canal ideal

paramSimulacionUAC

% PAR�METROS OFDM
N=4096;          % N�mero de puntos de la FFT
M=N*1/2;         % N�mero de muestras del prefijo c�clico
Nutil=784;       % Numero de portadoras �tiles

nbitxSimb=Nutil*2;           % # de bits por simb OFDM
nSymb=length(t_c)/nbitxSimb; % # de simb OFDM
nbit=nbitxSimb*nSymb;        % # total de bits
nSymbQPSK=Nutil*nSymb;       % # total de simb QPSK

T=(N+M)*nSymb/fs;      % Duracion de la simulacion
t=0:Tm:T-Tm;     % eje de tiempos
Fsimb=1/T;       % Frec de s�mbolo
Df=fs/N;             % Separaci�n entre portadoras
f=-fs/2:Df:fs/2-Df;  % eje de frecuencia OFDM

%% ************ Respuesta del canal UAC ********************
[H,h]=RespuestaUAC(fmin,fmax,100,wTx,wRx,w,pmax, dib);
ret=length(h)-1;

% Estimaci�n del FEQ e �ndice retardo inicial respuesta impulsiva (sincro)
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

tx=zeros(1,(N+M)*nSymb);     % Inicializamos el vector de la se�al OFDM
AA=zeros(1,nSymbQPSK);       % Vector de s�mbolos QPSK que se van a transmitir

iFc=freqIndex(fc,fs,Df);     %�ndice matlab de frec portadora banda �til
iFcH=freqIndex(-fc,fs,Df);   %�ndice matlab frec portadora banda herm�tica

for kSymb=1:nSymb
   BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb)); % Ventana para el vector de bits
   b=t_c(BitWin);
   
   A=CodSimbQPSK(b,d);                 % Se codifican los bits en s�mbolos QPSK
   QPSKwin=(kSymb-1)*Nutil+(1:Nutil);  % Ventana para el vector de s�mbolos QPSK
   AA(QPSKwin)=A;      % Se a�aden los Nutil s�mbolos QPSK al vector de 
                       % s�mbolos QPSK a transmitir                          
   s=TxOFDM(A,N,M,Nutil,iFc,iFcH);    % Se modulan los s�mbolos QPSK en un s�mbolo OFDM
   OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); % Ventana para el vector de s�mbolos OFDM
   tx(OFDMwin)=s;                     % escribe un bloque de se�al
end

%% ********************  CANAL *************************
% Filtrado respuesta al impulso h[n]
if canalUAC
    sf=conv(h,tx);
else
    sf=tx;
end

% Ruido aditivo

    % a. C�lculo de la DEP de ruido a partir de la SNR
SNR=10^(snrdB_in/10);
senyal=FEQyQuitaCP(sf,N,M,Nutil,FEQ,nSymb,iFc,iFcH);
Er=sum(abs(senyal).^2)*Tm/nSymbQPSK;
Eb=Er/2;
N0_2=Eb/(2*SNR);

    % b. Vector temporal de la se�al tras la convolucion del canal
if canalUAC
    Tn=((N+M)*nSymb+ret)/fs; % Duracion de la se�al de ruido
    tn=0:Tm:Tn-Tm;
else
    tn=t;
end

    % c. Inclusi�n del vector de ruido a la se�al
if tipoRuido==1
    n=Ruido(tn,N0_2);        % muestras de ruido AWGN
    yy=sf+n;                % Se�al filtrada con ruido AWG
elseif tipoRuido==2
    n=RuidoUWAN(tn,N0_2*390,dib); %Factor 390 para N0_2 media en la banda �til sea aprox 10^-3 W/Hz
    yy=sf+n;
else
    yy=sf;
end

%% *************  DEMODULADOR DIGITAL ******************
QQ=zeros(1,nSymbQPSK);  %S�mbolos QPSK recibidos
AAest=QQ;               %S�mbolos QPSK decididos
r_c=zeros(1,nbit); % 2 bits/symb QPSK

rr=yy(sincro:end); %Desprecio el retardo introducido por el filtro

for kSymb=1:nSymb
    OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); %Ventana para recibir el s�mbolo OFDM
    r=rr(OFDMwin);
    
    ro=r((1+M):(N+M));  % Desprecia CP
    Q=RxOFDM(ro,FEQ,Nutil, iFc);  % escribe un bloque de se�al
    
    QPSKwin=(kSymb-1)*Nutil+(1:Nutil);
    QQ(QPSKwin)=Q;
    [aest,best]=DecisorQPSK(Q,d);  % Decisor QPSK y bits
    AAest(QPSKwin)=aest;         % Vector de s�mbolos QPSK decididos
    
    BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb));
    r_c(BitWin)=best;          % Vector de bits decididos
end

r_c=r_c.';

%% ****************  PRESTACIONES  *********************
% 1. Probabilidad de error de s�mbolo y de bit simuladas
errsim=abs(AAest-AA);     % secuencia de errores de simbolo
errbit=abs(r_c-t_c);     % secuencia de errores de bits
 
PM=nnz(errsim)/nSymbQPSK;     % probabilidad de error de simbolo
Pb=nnz(errbit)/nbit;  % probabilidad de error de bit


% C�lculo de la SNR rx despu�s de la igualaci�n
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
