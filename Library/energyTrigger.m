% -----------------------------------------------------------
% energyTrigger.m
%
% Devuelve el �ndice a partir del cual comienza la respuesta
% al impulso del canal eliminando el retardo inicial. Se determina
% el �ndice mediante el c�lculo de la energ�a compredida en una
% ventana m�vil de tama�o wSize.
% -----------------------------------------------------------
% function index=delayTrigger(h)
% -----------------------------------------------------------
% Entrada/s:
%   h: Respuesta al impulso completa del canal
%   wSize: Tama�o de la ventana de c�lculo de energ�a
% -----------------------------------------------------------
function index=energyTrigger(h,wSize)

tam=length(h);  %long resp al impulso
e_h=h*h';     %energia de la resp al impulso completa

e=zeros(1,tam-wSize);
for i=1:tam-wSize
    vent=h(i:i+wSize);  %ventana
    e_vent=vent*vent';  %energ�a de la ventana
    e(i)=e_vent/e_h;    %porcentaje frente a la energ�a total
end

index=find(e>0.001,1); %Condici�n: se dispara cuando la energ�a supera el umbral del 0.5%

% figure, subplot(2,1,1), plot(abs(h)), grid on, title('Respuesta al impulso')
% subplot(2,1,2), plot(e), grid on