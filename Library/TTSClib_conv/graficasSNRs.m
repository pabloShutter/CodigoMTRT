% function hf = graficasSNRs(ssnrdB, bber_c, bber_m, hf, linea, leyenda)
% ---------------------------------------------------------------------
% Dibuja gr�ficas de BER de bits codificados y sin codificar 
%   SNR referida a la energia por simbolo (log2(M) bits)
% ---------------------------------------------------------------------
% variables usadas
%    bber_m   vector de valores de BER de bits de mensaje
%    bber_c   vector de valores de BER de bits codificados
%    ssnrdB   vector de valores de SNR (dB)
%    hf       Manejador de una figura. Par�metro opcional. Si no est�
%             presente se crea una figura nueva. 
%    linea    Descriptor de l�nea de la figura. Array de celda de dos
%             elementos. Par�metro opcional.
%    leyenda  Cadena de caracteres que se a�ade a las leyendas de 'bber_m'
%             y 'bber_c'            
% ---------------------------------------------------------------------

% --------------------------------------------------------
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 9-6-2015      Jos� Tom�s Entrambasaguas
% 2-5-2020      Modificaci�n. Cambio a funci�n. 
% 21-5-2020     Se a�aden par�metros hf, linea y leyenda
% --------------------------------------------------------
function hf = graficasSNRs(ssnrdB, bber_c, bber_m,     hf, linea, leyenda)

if nargin < 4
    linea{1} = 'b';
    linea{2} = 'r--';
    hf = figure; 
    leyenda = '';
end

figure(hf);
semilogy(ssnrdB, bber_m, linea{1}, 'DisplayName', ['bber_m ' leyenda]); 
hold on;
semilogy(ssnrdB, bber_c, linea{2}, 'DisplayName', ['bber_c ' leyenda]);

ylabel('BER'); xlabel('SNRs (dB)'); grid on; legend('show')







