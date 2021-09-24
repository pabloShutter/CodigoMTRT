% --------------------------------------------------------
%  Canal GF
%  Entrada y salida son vectores GF
%  Introduce errores con valores y posiciones aleatorios
% --------------------------------------------------------
%  function r_g = canalGF(t_g, numErrores)
% --------------------------------------------------------
%  t_g  vector GF de entrada
%  r_g  vector GF de salida
%  numErrores numero de errores a introducir
% --------------------------------------------------------

% --------------------------------------------------------
% Universidad de Málaga. Dpto. Ingeniería de Comunicaciones 
% 6-5-2015  José Tomás Entrambasaguas
% --------------------------------------------------------

function r_g = canalGF_errorAleat(t_g, numErrores)
N=length(t_g);
q=t_g.m; % GF(2^q)
errores = gf(zeros(1,N),q);
while sum(sign(errores.x)) < numErrores
    indiceError=1+fix(N*rand);
    valorError=max(1,fix(rand*2^q));
    errores(indiceError) = gf(valorError,q);
end
r_g = t_g + errores;
