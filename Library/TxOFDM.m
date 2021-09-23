% -----------------------------------------------------------
% Transmisor OFDM
%
% Coloca simbolos en portadoras utiles ordenadamente
% desde la frecuencia m�s negativa hasta la m�s positiva
% En ambos extremos deja a cero las frecuencias "de guarda"
% Deja tambi�n a cero a la portadora cero (DC)
% Calcula el s�mbolo en el dominio del tiempo mediante IFFT
% e inserci�n del prefijo c�clico
% -----------------------------------------------------------
% function s=TxOFDM(A,N,M,dib)
% -----------------------------------------------------------
% s: simbolo de salida (longitud: N+M)
% A: vector de s�mbolos de entrada (longitud: Nutil)
% N: Numero de puntos de la FFT
% M: Numero de muestras del prefijo c�clico
% dib: 1: dibujar gr�ficas, 0: no dibujar
% -----------------------------------------------------------

function s=TxOFDM(A,N,M,Nutil,iFc,iFcH)

A_conj=conj(A);

% 1. Coloca los s�mbolos en portadoras �tiles (simetr�a herm�tica)
Ao=zeros(1,N);
Ao(iFc-Nutil/2:iFc-1)=A(1:Nutil/2);
Ao(iFc+1:iFc+Nutil/2)=A(Nutil/2+1:Nutil);

Ao(iFcH+Nutil/2:-1:iFcH+1)=A_conj(1:Nutil/2);
Ao(iFcH-1:-1:iFcH-Nutil/2)=A_conj(Nutil/2+1:Nutil);

% 2. Se�al en dominio del tiempo e inserci�n del CP
s0=ifft(Ao);            % IFFT
s=[s0((N-M+1):N) s0];   % Inserci�n del CP