% ---------------------------------------------------------------------
% function [hCanal] = iniCanalAWGN(snrdB)
% ---------------------------------------------------------------------
% Crea el objeto de canal AWGN
% ---------------------------------------------------------------------
%  snrdB   SNR a la entrada del demodulador (dB)
%  hCanal  objeto Canal AWGN
% ---------------------------------------------------------------------

% --------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 8-6-2015  José Tomás Entrambasaguas
% --------------------------------------------------------

function [hCanal] = iniCanalAWGN(snrdB)

hCanal   = comm.AWGNChannel ();
set(hCanal, 'NoiseMethod','Signal to noise ratio (SNR)');
set(hCanal, 'SNR',snrdB);
