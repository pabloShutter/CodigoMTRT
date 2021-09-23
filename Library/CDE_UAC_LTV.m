% -----------------------------------------------------------
% Autor: Pablo Cobacho
% -----------------------------------------------------------
% SistLTI_CanalLTV.m
% Script que simula un sistema de comunicaciones digitales 
% diseñado para trabajar con un canal UAC LTI en el que se 
% transmite una secuencia de símbolos OFDM utilizando 
% codificación QPSK y modulación DMT a través de un canal
% UAC medido y variante con el tiempo (LTV). Este script
% intenta probar la tolerancia de un sistema LTI a un canal
% LTV 
% -----------------------------------------------------------

function [r_c,SNRdB_symb, SNRdBb_c,BERxSimb] = CDE_UAC_LTV(t_c,snrdB_in,tipoRuido,mod)

path(path,'Library')

paramSimUAC_LTV

canalUAC=1;   %tipo de canal: '1' canal UAC, '0' canal ideal

%Parámetros OFDM
N=4096*2;          % Número de puntos de la FFT
M=N*3/4;          % Número de muestras del prefijo cíclico
Nutil=784*5/4;      % Numero de portadoras útiles

if strcmp(mod,'BPSK') || strcmp(mod,'2DPSK')
    nbitxSimb=Nutil*1;     %nº de bits por simb OFDM
elseif strcmp(mod,'QPSK') || strcmp(mod,'DQPSK')
    nbitxSimb=Nutil*2;
end

nSymb=length(t_c)/nbitxSimb;
nbit=nbitxSimb*nSymb;        %nº total de bits
nSymbQPSK=Nutil*nSymb;       %nº total de simb QPSK

Df=fs/N;             % Separación entre portadoras

%% Estimación del FEQ
pos=1;  % Índice de la resp al imp de la que se parte
hi=h(pos,:); % Resp imp. i-ésima
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
tx=zeros(1,(N+M)*nSymb);     % Inicializamos el vector de la señal OFDM
AA=zeros(1,nSymbQPSK);       % Vector de símbolos QPSK que se van a transmitir

iFc=freqIndex(fc,fs,Df);     %índice matlab de frec portadora banda útil
iFcH=freqIndex(-fc,fs,Df);   %índice matlab frec portadora banda hermítica

for kSymb=1:nSymb
   BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb)); % Ventana para el vector de bits
   b=t_c(BitWin);  % Secuencia de bits aleatorios equiprobables de cada símbolo OFDMx
   
   if strcmp(mod,'BPSK')
       b(1)=1;
       A=CodSimbBPSK(b,d);
   elseif strcmp(mod,'2DPSK')
       b(1)=1;
       A=CodSimb2DPSK(b,d);    % Se codifican los bits en símbolos BPSK
   elseif strcmp(mod,'QPSK')
       b(1)=1; b(length(b)/2+1)=1;  % El primer símbolo QPSK lo mandamos de referencia para DQPSK (1,1)
       A=CodSimbQPSK(b,d);    % Se codifican los bits en símbolos QPSK
   elseif strcmp(mod,'DQPSK')
        dqpskmod = comm.DQPSKModulator('BitInput',true,'SymbolMapping','Binary');
        dqpskdemod = comm.DQPSKDemodulator('BitOutput',true,'SymbolMapping','Binary');
        A = dqpskmod(b);
   end
      
   QPSKwin=(kSymb-1)*Nutil+(1:Nutil);  % Ventana para el vector de símbolos QPSK
   AA(QPSKwin)=A;      % Se añaden los Nutil símbolos QPSK al vector de 
                       % símbolos QPSK a transmitir
   s=TxOFDM(A,N,M,Nutil,iFc,iFcH);    % Se modulan los símbolos QPSK en un símbolo OFDM
   
   if canalUAC==1
       sf=CanalLTV(s,h,kSymb+(pos-1));  % Aplica una resp imp a cada símb OFDM tx
   else
       sf=s;
   end
   
   OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); % Ventana para el vector de símbolos OFDM
   tx(OFDMwin)=sf;                     % escribe un bloque de señal
end

%% ********************  CANAL *************************
% Ruido aditivo
    % a. Cálculo de la DEP de ruido a partir de la SNR
SNR=10^(snrdB_in/10);
senyal=FEQyQuitaCP(tx,N,M,Nutil,FEQ,nSymb,iFc,iFcH);
Er=sum(abs(senyal).^2)*Tm/nSymbQPSK;
Eb=Er/2;
N0_2=Eb/(2*SNR);

    % b. Vector temporal de la señal tras la convolucion del canal
Tn=((N+M)*nSymb)/fs; % Duracion de la señal de ruido
tn=0:Tm:Tn-Tm;

    % c. Inclusión del vector de ruido a la señal
if tipoRuido==1
    n=Ruido(tn,N0_2);        % muestras de ruido AWGN
    rr=tx+n;                % Señal filtrada con ruido AWG
elseif tipoRuido==2
    n=RuidoUWAN(tn,N0_2*390,0);
    rr=tx+n;
else
    rr=tx;
end

%% *************  DEMODULADOR DIGITAL ******************
QQ=zeros(1,nSymbQPSK);  %Símbolos QPSK recibidos
AAest=QQ;               %Símbolos QPSK decididos
r_c=zeros(1,nbit); % 2 bits/symb QPSK

errsim=zeros(nSymb,Nutil);
errbit=zeros(nSymb,nbitxSimb);
PM=zeros(1,nSymb);
BERxSimb=zeros(1,nSymb);
SDR_vector=zeros(nSymb,Nutil);
SDR=zeros(1,nSymb);
SDRdB=zeros(1,nSymb);

for kSymb=1:nSymb
    OFDMwin=(kSymb-1)*(N+M)+(1:(N+M)); %Ventana para recibir el símbolo OFDM
    r=rr(OFDMwin);

    ro=r((1+M):(N+M));  % Desprecia CP
    Q=RxOFDM(ro,FEQ,Nutil, iFc);  % escribe un bloque de señal        

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

    AAest(QPSKwin)=aest;         % Vector de símbolos QPSK decididos

    BitWin=(kSymb-1)*nbitxSimb+(1:(nbitxSimb));
    r_c(BitWin)=best;          % Vector de bits decididos
    
    % Calculo y almaceno la PM y la Pb del símbolo k-ésimo
    errsim(kSymb,:)=abs(aest-AA((kSymb-1)*Nutil+(1:Nutil)));
    errbit(kSymb,:)=abs(best-t_c((kSymb-1)*nbitxSimb+(1:(nbitxSimb))).');
    
    PM(kSymb)=nnz(errsim(kSymb,:))/Nutil;     % probabilidad de error de simbolo
    BERxSimb(kSymb)=nnz(errbit(kSymb,:))/nbitxSimb;          % probabilidad de error de bit

end

r_c=r_c.';

%% ****************  PRESTACIONES  *********************
% 1. Probabilidad de error de símbolo y de bit simuladas
Pb_mean=mean(BERxSimb);
PM_mean=mean(PM);

% 2. Cálculo de la SNR rx después de la igualación
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
        
%% **********  REPRESENTACIONES GRÁFICAS  **************
% Probabilidad de error de bit por símbolo OFDM recibido
figure('Name','BER por símbolo OFDM recibido')
plot(BERxSimb, 'Linewidth',1.1), grid on, hold on%, plot(BERxSimb,'r.')%, ylim([0 1])
xlabel('Índice de símbolo OFDM recibido'),title('BER/simbOFDM')

%Comprobación de la recepción
if dib
    figure('Name','Comprobacion de recepcion')
    plot(real(QQ),imag(QQ),'.'), hold on, title('Constelación recibida')
    plot(real(AA),imag(AA),'o','Linewidth',1.2), hold off, grid on%,l=real(AA(1))*2.5; axis([-l l -l l])
    xlabel('Real\{a_k\}'), ylabel('Imag\{a_k\}'), axis square
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
end
