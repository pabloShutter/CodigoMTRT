% -----------------------------------------------------------
% Codificador QPSK
% Codificaci�n de bits como s�mbolos QPSK
% -----------------------------------------------------------
% function y=CodSimbQPSK(x)
% -----------------------------------------------------------
% x:  Secuencia de bits {0,1}
% y:  Secuencia de s�mbolos complejos {+-1,+-j}
% -----------------------------------------------------------

function y=CodSimbQPSK(x,d)
N=length(x);
xx=reshape(x,N/2,2); % Organizamos los bits en 2 columnas
y=[]; %Creamos vac�a la secuencia de s�mbolos QPSK

for i=1:N/2
    if xx(i,:)==[1,0]
        y(i)=d/2-(d/2)*j;
    elseif xx(i,:)==[0,0]
        y(i)=-d/2-(d/2)*j;
    elseif xx(i,:)==[0,1]
        y(i)=-d/2+(d/2)*j;
    elseif xx(i,:)==[1,1]
        y(i)=d/2+(d/2)*j;
    end
end