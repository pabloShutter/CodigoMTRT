% function hf = dibujaSenales(snrdB, M, retardoDecod, t_m, t_c, t_s, ...
%     t_s_p1, r_m, r_c, r_s, r_s_p1)
% -------------------------------------------------------------------------
% Dibuja senales de un sistema de transmisi�n M-QAM 
%     con codificacion convolucional
% -------------------------------------------------------------------------
%  (t_  transmitida  r_  recibida)
%  t_m     r_m     secuencias binarias de mensaje
%  t_c     r_c     secuencias binarias codificadas
%  t_s     r_s     secuencias de s�mbolos modulados
%  t_s_p1  r_s_p1  secuencias de s�mbolos escalados a potencia 1
% parametros usados
%  M      n�mero de s�mbolos del alfabeto M-QAM
%  snrdB  SNR a la entrada del demodulador (dB)
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 28-5-2015  Jos� Tom�s Entrambasaguas
% 1-5-2020 Modificaci�n: de script se pasa a funci�n. 
% -------------------------------------------------------------------------

function hf = dibujaSenales(snrdB, M, retardoDecod, t_m, t_c, t_s, ...
    t_s_p1, r_m, r_c, r_s, r_s_p1)

hf = figure('Name', 'Senales');

nn = 1:20; % muestras de se�al a dibujar
subplot(2,4,1), plot(t_m(nn),             '.-'), title('t\_m')
subplot(2,4,5), plot(r_m(nn+retardoDecod),'.-'), title('r\_m')
subplot(2,4,2), plot(t_c(nn),'.-'), title('t\_c')
subplot(2,4,6), plot(r_c(nn),'.-'), title('r\_c')

nn = 1:(M*M); % muestras de se�al a dibujar
A = 1 + round(sqrt(M));
ejes = [-A A -A A];
subplot(2,4,3), plot(t_s(nn),'o'), axis(ejes), axis square, title('t\_s');
grid on; subplot(2,4,7), plot(r_s(nn),'o'), axis(ejes), axis square;
title(['r\_s'  sprintf('  SNR:%gdB',snrdB)]), grid on;

A = 1.2;
ejes = [-A A -A A];
nn = 1:(M*M); % muestras de se�al a dibujar
subplot(2,4,4), plot(t_s_p1(nn),'o'), axis(ejes), axis square;
title('t\_s\_p1'), grid on; 
subplot(2,4,8), plot(r_s_p1(nn),'o'), axis(ejes), axis square;
title(['r\_s\_p1'  sprintf('  SNR:%gdB',snrdB)]), grid on;

