% --------------------------------------------------------
%  Codifica un vector binario en un vector de enteros
%  agrupan cada m bit en un entero de valor 0-2^m-1 
% --------------------------------------------------------
% function msg_m =codBin(msgBin,m)
% --------------------------------------------------------
%  m  numero de bits de cada entero
%  msgBin  vector binario  (su longitud debe ser multiplo de m)
%  msg_m   vector de enteros
% --------------------------------------------------------

% --------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 20-3-2015  José Tomás Entrambasaguas
% --------------------------------------------------------

function msg_m =codBin(msgBin,m)
msg_m=[];
if rem(length(msgBin),m)~=0, error('long msgBin debe ser multiplo de m'), end
for  ksimb=1:length(msgBin)/m,
    simbBin=msgBin(m*(ksimb-1)+(1:m));
    msg_m(ksimb)=bi2de(simbBin);
end
