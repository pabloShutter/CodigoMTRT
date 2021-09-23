% -----------------------------------------------------------
% Modelo de canal subacu�tico
%
% Devuelve la respuesta en frecuencia y la respuesta al 
% impulso de un canal subacu�tico (UAC) realista con fondo arenoso
% -----------------------------------------------------------
% function [H,h]=RespuestaUAC(fmin,fmax,d0,wTx,wRx,w,pmax, dib)
% -----------------------------------------------------------
% Entrada/s:
%   fmin
%   fmax
%   d0      distancia TX-RX en m
%   wTx     profundidad del transmisor hasta el fondo
%   wRx     profundidad del receptor hasta el fondo
%   w       profundidad del agua
%   pmax    n�mero m�ximo de rayos significativos considerados
%   dib     representaci�n respuesta del canal: '0'->No, '1'->S�
% Salida/s:
%   H(f)    respuesta en frecuencia, presi�n RX / presi�n a 1m en TX
%   h(t)    respuesta al impulso
%   h_ef(t) respuesta al impulso efectiva
% -----------------------------------------------------------

function [H,h]=RespuestaUAC(fmin,fmax,d0,wTx,wRx,w,pmax, dib)

%Par�metros iniciales
fs=500e3;     % frecuencia de muestreo (debe cumplir Nyquist: fs>2fmax)
Df=5;         % paso en frecuencia (resoluci�n)

if fmin<0 || fmax>(fs/2) || fmin>fmax
    disp('ERROR:'),disp('Revise las frecuencias fmin y fmax')
else
    %Par�metros del modelo
    f=fmin:Df:fmax;   % frecuencia en Hz
    aTX=[0,0.75*pi];  % apertura vertical del diag. polar del TX en rad -> aTX=[aTX1 aTX2]
    aRX=[0,0.75*pi];  % apertura vertical del diag. polar del RX en rad -> aRX=[aRX1 aRX2]
    cb=1300;          % velocidad de propagaci�n del sonido en el fondo (m/s)
    rhob=1800;        % densidad volum�trica del fondo (kg/m3)    
%     cb=1500;    %Suelo poco rocoso
%     rhob=2100;  %Suelo poco rocoso
    modelo='m&s';     % modelo de atenuaci�n dependiente de la frecuencia
                      % puede ser 'thorp' (Thorp, 100Hz-3kHz),
                      % 'm&s' (Marsh & Schulkin, 3kHz-500kHz),
                      % o 'bi' thorp y m&s por tramos
    S=38; % salinidad del agua en tanto por mil, para modelo 'm&s' (g/L aprox igual a tanto por mil)
    T=15; % temperatura del agua en �C, para modelo 'm&s'

    % 1. Genero la respuesta en frecuencia del modelo
    Hc=[ zeros(1,length(0:Df:(fmin-Df))) UAC_LTI_H(f,d0,wTx,wRx,w,aTX,aRX,cb,rhob,pmax,modelo,S,T) zeros(1,length((fmax+Df):Df:fs/2))];
    Hc=[ Hc conj(Hc(end-1:-1:2)) ]; %Respuesta en frecuencia (simetr�a herm�tica)

    % 2. Calculo su respuesta al impulso
    hc=ifft(Hc);

    % 3. Dise�o de canal FIR paso banda [32,135] KHz
    hpb=fir1(48,[(2*25e3)/fs (2*135e3)/fs]);

    % 4. Filtro realista
        %4.1 Respuesta al impulso
    h=conv(hc,hpb);
    h=h(25:length(h)-24); %Compensacion retardo introducido por filtro FIR
        %4.2 Respuesta en frecuencia
    H=fft(h);   % Respuesta en frecuencia
    
    %% Representaci�n gr�fica
    if dib
        Df=fs/length(H);
        freq=-fs/2:Df:fs/2-Df;      % eje de frecuencia (Hz)
        t=((0:(length(hc)-1))/fs)*1000;  % eje de tiempo (ms)

%         figure('Name', 'Modelado respuesta UAC'), subplot(2,2,1)
%         plot(freq/1e3, abs(fftshift(Hc))), grid on
%         xlabel('f (KHz)'), ylabel('|H(f)|'), title('Respuesta en frecuencia')
%         subplot(2,2,2)
%         plot(t, abs(hc)), grid on
%         xlabel('\tau(ms)'), ylabel('|h(\tau)|'), title('Respuesta al impulso')
% 
%         subplot(2,2,3), plot(freq/1e3, abs(fftshift(H))), grid on
%         xlabel('f (KHz)'), ylabel('|H(f)|'), title('Respuesta en frecuencia realista')
%         subplot(2,2,4)
%         plot(t, abs(h)), grid on
%         xlabel('\tau(ms)'), ylabel('|h(\tau)|'), title('Respuesta al impulso realista')

        figure, plot(t, abs(h)), grid on
        xlabel('\tau(ms)'), ylabel('|h(\tau)|'), title('Respuesta al impulso realista')
        
        str=sprintf('d=%dm, prof Tx-Rx=%dm, prof fondo=%dm',d0,wTx,w);
        figure('Name',str), subplot(2,1,1), plot(abs(h)), grid on
        xlabel('Muestras'), ylabel('|h(m)|'), title('Respuesta al impulso realista')
        subplot(2,1,2), plot(freq/1e3, abs(fftshift(H))), grid on
        xlabel('f (KHz)'), ylabel('|H(f)|'), title('Respuesta en frecuencia realista')
    end
end

% C�lculo del BW de coherencia de la resp en frecuencia realista
% [aut_H,lag]=xcorr(fftshift(H));
% Df2=2*fs/length(aut_H);
% freq2=-fs:Df2:fs-Df2;
% figure('Name','BW coh #1'), subplot(2,1,1), plot(freq/1e3, abs(fftshift(H)))
% grid on, title('Rspuesta en frecuencia'), xlabel('f (KHz)')
% subplot(2,1,2),plot(freq2,aut_H/max(aut_H))
% grid on, xlabel('f (Hz)'), title('Autocorrelaci�n')
% 
% Hs=UAC_LTI_H(f,d0,wTx,wRx,w,aTX,aRX,cb,rhob,pmax,modelo,S,T);
% figure('Name','BW coh #2'), subplot(2,1,1), plot(f/1e3,abs(Hs)), grid on
% xlabel('f(KHz)'),title('Respuesta en frecuencia')
% [aut_Hs,lags]=xcorr(Hs,'normalized');
% subplot(2,1,2), plot(lags,aut_Hs), grid on
% title('Autocorrelaci�n'),xlabel('lags')