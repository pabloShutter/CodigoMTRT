% function [trellisEnc,tasaMadre] = defineCodigoConvolucional
% -------------------------------------------------------------------------
% Define la estructura de datos 'trellisEnc' que necesitan los
% codificadores y decodificadores convolucionales de MATLAB
%
% Se define un codificador no sistemático de tasa 1/2 no recursivo con K=7
% Cada bit de salida se calcula como una paridad del valor actual y valores 
% anteriores del bit de entrada
% out1Bin y out2Bin definen las ecuaciones de cálculo de las paridades
%   c1[n]= d1[n] + d1[n-1] + d1[n-2] + d1[n-3] +                d1[n-6]  
%   c2[n]= d1[n] +           d1[n-2] + d1[n-3] +      d1[n-5] + d1[n-6]  
% -------------------------------------------------------------------------
%    trellisEnc  descriptor del codificador convolucional
%    tasaCod   tasa de codificacion
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 8-5-2015  José Tomás Entrambasaguas
% -------------------------------------------------------------------------

function [trellisEnc,tasaCod] = defineCodigoConvolucional_PDSCH_RSC_LTE

K = 4; % longitud de restricción
out1Bin = '1000';
out2Bin = '1101';
feedback = '1011';
tasaCod = 1/2;
out1 = str2num(dec2base(bin2dec(out1Bin),8));
out2 = str2num(dec2base(bin2dec(out2Bin),8));
feedB = str2num(dec2base(bin2dec(feedback),8));
trellisEnc = poly2trellis(K, [out1 out2],feedB);

