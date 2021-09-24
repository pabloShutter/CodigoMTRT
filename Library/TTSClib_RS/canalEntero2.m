% --------------------------------------------------------
% Canal de enteros con probabilidad de error 
% --------------------------------------------------------
% function y = canalEntero2(x,q,p)
% --------------------------------------------------------
%  x = vector entero entrada
%  y = vector entero de salida
%  q = numero de bits de los enteros (valores 0 a 2^q-1) 
%  p = probabilidad de entero erroneo 
% --------------------------------------------------------

% --------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 6-5-2015  José Tomás Entrambasaguas
% --------------------------------------------------------

function y = canalEntero2(x,q,p)
Ne=2^q;
errores=max(0,sign(p-rand(size(x))));
valorError=max(1,fix(rand(size(x))*Ne));
y=rem(x+errores.*valorError,Ne);
