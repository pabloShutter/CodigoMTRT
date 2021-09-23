% -----------------------------------------------------------
% Autor: Pablo Cobacho
% -----------------------------------------------------------
% SistLTI_CanalLTV.m
% Script que simula un sistema de comunicaciones digitales 
% dise�ado para trabajar con un canal UAC LTI en el que se 
% transmite una secuencia de s�mbolos OFDM utilizando 
% codificaci�n QPSK y modulaci�n DMT a trav�s de un canal
% UAC medido y variante con el tiempo (LTV). Este script
% intenta probar la tolerancia de un sistema LTI a un canal
% LTV 
% -----------------------------------------------------------

function [r_c,SNRdB_symb, SNRdBb_c,BERxSimb] = CDE_UAC_LTV(t_c,snrdB_in,tipoRuido,mod)

path(path,'Library')

paramSimUAC_LTV

canalUAC=1;   %tipo de canal: '1' canal UAC, '0' canal ideal

%Par�metros OFDM
N=4096*2;          % N�mero de puntos de la FFT
M=N*3/4;          % N�mero de muestras del prefijo c�clico
Nutil=784*5/4;      % Numero de portadoras �tiles

if strcmp(mod,'BPSK') || strcmp(mod,'2DPSK')
    nbitxSimb=Nutil*1;     %n� de bits por simb OFDM
elseif strcmp(mod,'QPSK') || strcmp(mod,'DQPSK')
    nbitxSimb=Nutil*2;
end

nSymb=length(t_c)/nbitxSimb;
nbit=nbitxSimb*nSymb;        %n� total de bits
nSymbQPSK=Nutil*nSymb;       %n� total de simb QPSK

Df=fs/N;             % Separaci�n entre portadoras

%% Estimaci�n del FEQ
pos=1;  % �ndice de la resp al imp de la que se parte
hi=h(pos,:); % Resp imp. i-�sima
sincro=energyTrigger(hi,20);
hi_sincro=[ hi(sincro:end) zeros(1,N-length(hi(sincro:end)))];

if canalUAC
    h_FEQ=hi_sincro(1:N);
    H_FEQ=fft(h_FEQ,N);
    FEQ=1./H_FEQ; %Igualador ZF
else
    FEQ=1;
end

%% **************  MODULADOR DIGITAL *******************
% Generador de bits
tx=zeros(1,(N+M)*nSymb);     % Inicializamos el vector de la se�al OFDM
AA=zeros(1,nSymbQPSK);       % Vector de s�mbolos QPSK que se van a transmitir

iFc=freqIndex(fc,fs,Df);     %�ndice matlab de frec portadora banda �til
iFcH=freqIndex(-fc,fs,Df);   %�ndice matlab frec portadora banda herm�tica

for kSymb=1:nSymb
   BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb)); % Ventana para el vector de bits
   b=t_c(BitWin);  % Secuencia de bits aleatorios equiprobables de cada s�mbolo OFDMx
   
   if strcmp(mod,'BPSK')
       b(1)=1;
       A=CodSimbBPSK(b,d);
   elseif strcmp(mod,'2DPSK')
       b(1)=1;
       A=CodSimb2DPSK(b,d);    % Se codifican los bits en s�mbolos BPSK
   elseif strcmp(mod,'QPSK')
       b(1)=1; b(length(b)/2+1)=1;  % El primer s�mbolo QPSK lo mandamos de referencia para DQPSK (1,1)
       A=CodSimbQPSK(b,d);    % Se codifican los bits en s�mbolos QPSK
   elseif strcmp(mod,'DQPSK')
        dqpskmod = comm.DQPSKModulator('BitInput',true,'SymbolMapping','Binary');
        dqpskdemod = comm.DQPSKDemodulator('BitOutput',true,'SymbolMapping','Binary');
        A = dqpskmod(b);
   end
      
   QPSKwin=(kSymb-1)*Nutil+(1:Nutil);  % Ventana para el vector de s�mbolos QPSK
   AA(QPSKwin)=A;      % Se a�aden los Nutil s�mbolos QPSK al vector de 
                       % s�mbolos QPSK a transmitir
   s=TxOFDM(A,N,M,Nutil,iFc,iFcH);    % Se modulan los s�mbolos QPSK en un s�mbolo OFDM
   
   if canalUAC==1
       sf=CanalLTV(s,h,kSymb+(pos-1));  % Aplica una resp imp a cada s�mb OFDM tx
   else
       sf=s;
   end
   
   OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); % Ventana para el vector de s�mbolos OFDM
   tx(OFDMwin)=sf;                     % escribe un bloque de se�al
end

%% ********************  CANAL *************************
% Ruido aditivo
    % a. C�lculo de la DEP de ruido a partir de la SNR
SNR=10^(snrdB_in/10);
senyal=FEQyQuitaCP(tx,N,M,Nutil,FEQ,nSymb,iFc,iFcH);
Er=sum(abs(senyal).^2)*Tm/nSymbQPSK;
Eb=Er/2;
N0_2=Eb/(2*SNR);

    % b. Vector temporal de la se�al tras la convolucion del canal
Tn=((N+M)*nSymb)/fs; % Duracion de la se�al de ruido
tn=0:Tm:Tn-Tm;

    % c. Inclusi�n del vector de ruido a la se�al
if tipoRuido==1
    n=Ruido(tn,N0_2);        % muestras de ruido AWGN
    rr=tx+n;                % Se�al filtrada con ruido AWG
elseif tipoRuido==2
    n=RuidoUWAN(tn,N0_2*390,0);
    rr=tx+n;
else
    rr=tx;
end

%% *************  DEMODULADOR DIGITAL ******************
QQ=zeros(1,nSymbQPSK);  %S�mbolos QPSK recibidos
AAest=QQ;               %S�mbolos QPSK decididos
r_c=zeros(1,nbit); % 2 bits/symb QPSK

errsim=zeros(nSymb,Nutil);
errbit=zeros(nSymb,nbitxSimb);
PM=zeros(1,nSymb);
BERxSimb=zeros(1,nSymb);
SDR_vector=zeros(nSymb,Nutil);
SDR=zeros(1,nSymb);
SDRdB=zeros(1,nSymb);

for kSymb=1:nSymb
    OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); %Ventana para recibir el s�mbolo OFDM
    r=rr(OFDMwin);

    ro=r((1+M):(N+M));  % Desprecia CP
    Q=RxOFDM(ro,FEQ,Nutil, iFc);  % escribe un bloque de se�al        

    QPSKwin=(kSymb-1)*Nutil+(1:Nutil);
    QQ(QPSKwin)=Q;
    
    if strcmp(mod,'BPSK')
        [aest,best]=DecisorBPSK(Q,d);        
    elseif strcmp(mod,'2DPSK')
        [aest,best]=Decisor2DPSK(Q,d);  % Decisor QPSK y bits
    elseif strcmp(mod,'QPSK')
        [aest,best]=DecisorQPSK(Q,d);  % Decisor QPSK y bits
    elseif strcmp(mod,'DQPSK')
        best = dqpskdemod(Q.').';
        aest=zeros(1,Nutil);
    end

    AAest(QPSKwin)=aest;         % Vector de s�mbolos QPSK decididos

    BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb));
    r_c(BitWin)=best;          % Vector de bits decididos
    
    % Calculo y almaceno la PM y la Pb del s�mbolo k-�simo
    errsim(kSymb,:)=abs(aest-AA((kSymb-1)*Nutil+(1:Nutil)));
    errbit(kSymb,:)=abs(best-t_c((kSymb-1)*nbitxSimb+(1:(nbitxSimb))).');
    
    PM(kSymb)=nnz(errsim(kSymb,:))/Nutil;     % probabilidad de error de simbolo
    BERxSimb(kSymb)=nnz(errbit(kSymb,:))/nbitxSimb;          % probabilidad de error de bit

end

r_c=r_c.';

%% ****************  PRESTACIONES  *********************
% 1. Probabilidad de error de s�mbolo y de bit simuladas
Pb_mean=mean(BERxSimb);
PM_mean=mean(PM);

% 2. C�lculo de la SNR rx despu�s de la igualaci�n
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
        
%% **********  REPRESENTACIONES GR�FICAS  **************
% Probabilidad de error de bit por s�mbolo OFDM recibido
figure('Name','BER por s�mbolo OFDM recibido')
plot(BERxSimb, 'Linewidth',1.1), grid on, hold on%, plot(BERxSimb,'r.')%, ylim([0 1])
xlabel('�ndice de s�mbolo OFDM recibido'),title('BER/simbOFDM')

%Comprobaci�n de la recepci�n
if dib
    figure('Name','Comprobacion de recepcion')
    plot(real(QQ),imag(QQ),'.'), hold on, title('Constelaci�n recibida')
    plot(real(AA),imag(AA),'o','Linewidth',1.2), hold off, grid on%,l=real(AA(1))*2.5; axis([-l l -l l])
    xlabel('Real\{a_k\}'), ylabel('Imag\{a_k\}'), axis square
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
end
