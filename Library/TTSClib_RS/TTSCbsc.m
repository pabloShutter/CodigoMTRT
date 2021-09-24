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
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 20-3-2015  Jos� Tom�s Entrambasaguas
% --------------------------------------------------------

function y = TTSCbsc(x,p)
errores=max(0,sign(p-rand(size(x))));
y=double(xor(x,errores));
