% function hf = graficasSNRb(ssnrdB, M, tasaCod, bber_m, bber_c, hf)
% -------------------------------------------------------------------------
% Dibuja gr�ficas de BER de bits codificados y sin codificar 
%   SNR referida a la energia empleada en cada bit
% -------------------------------------------------------------------------
% variables usadas
%    bber_m   vector de valores de BER de bits de mensaje
%    bber_c   vector de valores de BER de bits codificados
%    ssnrdB   vector de valores de SNR (dB)
% parametros usados
%    M        numero de simbolos del alfabeto M-QAM
%    tasaCod  tasa de codificacion
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 9-6-2015  Jos� Tom�s Entrambasaguas
% 2-5-2020  Modificac�n. De script a funci�n
% -------------------------------------------------------------------------

function hf = graficasSNRb(ssnrdB, M, tasaCod, bber_m, bber_c, hf)

nivModdB = 10*log10(log2(M));
ssnr_b_c = ssnrdB - nivModdB;
tasaCoddB = 10*log10(tasaCod);
ssnr_b_m = ssnr_b_c - tasaCoddB;


if nargin < 6
    hf = figure; 
else
    figure(hf)
end

semilogy(ssnr_b_m, bber_m, ssnr_b_c, bber_c, '--'); hold on; 
ylabel('BER'); xlabel('SNRb(dB)'); legend('bber_m','bber_c'); grid on;






