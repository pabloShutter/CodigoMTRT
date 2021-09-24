% --------------------------------------------------------
% Canal de enteros con numero de errores dado 
% --------------------------------------------------------
% function y = canalEntero1(x,q,numErr)
% --------------------------------------------------------
%  x = vector entero entrada
%  y = vector entero de salida
%  q = numero de bits de los enteros (valores 0 a 2^q-1) 
%  numErr = numero de errores que introduce
% --------------------------------------------------------

% --------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 6-5-2015  José Tomás Entrambasaguas
% --------------------------------------------------------

function y = canalEntero1(x, q, numErr)
N = length(x);
Ne = 2^q;
errores = zeros(N,1);
while sum(sign(errores)) < numErr
    indiceError = 1 + fix(N*rand);
    valorError = max(1, fix(rand*Ne));
    errores(indiceError) = valorError;
end
y = rem(x + errores,Ne);
