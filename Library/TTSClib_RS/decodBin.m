% --------------------------------------------------------
%  Codifica un vector binario en un vector de enteros
%  agrupan cada m bit en un entero de valor 0-2^m-1 
% --------------------------------------------------------
% function msgBin =decodBin(msg_m,m)
% --------------------------------------------------------
%  m numero de bits de cada entero
%  msgBin   vector binario  (su longitud debe ser multiplo de m)
%  msg_m    vector de enteros
% --------------------------------------------------------

% --------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 20-3-2015  José Tomás Entrambasaguas
% --------------------------------------------------------

function msgBin =decodBin(msg_m,m)
msgBin=zeros(1,m*length(msg_m));
for  ksimb=1:length(msg_m),
   simbBin=de2bi(msg_m(ksimb),m);
   for kInd=1:m,
      msgBin(m*(ksimb-1)+kInd)=simbBin(kInd);
   end
end

