% -----------------------------------------------------------
% Canal LTV
%
% Toma como par�metro de entrada un s�mbolo OFDM y lo convoluciona con el
% canal
% -----------------------------------------------------------
% function s=TxOFDM(A,N,M,dib)
% -----------------------------------------------------------
% s: s�mbolo OFDM a transmitir (longitud: N+M)
% h: respuesta impulsiva variante del canal
% i: �ndice del s�mbolo OFDM en la se�al completa
% -----------------------------------------------------------

function [sf,zf]=CanalLTV(s,h,i)

hi=h(i,:); % Resp imp. i-�sima
sincro=energyTrigger(hi,20);
hi_sincro=hi(sincro:end);
sf=filter(hi_sincro,1,s);