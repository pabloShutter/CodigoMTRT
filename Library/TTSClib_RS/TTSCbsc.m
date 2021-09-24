% --------------------------------------------------------
% Canal binario simetrico
% --------------------------------------------------------
% function y = TTSCbsc(x,p)
% --------------------------------------------------------
%  x = vector binario de entrada
%  y = vector binario de salida
%  p = probabilidad de error
% --------------------------------------------------------

% --------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 20-3-2015  José Tomás Entrambasaguas
% --------------------------------------------------------

function y = TTSCbsc(x,p)
errores=max(0,sign(p-rand(size(x))));
y=double(xor(x,errores));
