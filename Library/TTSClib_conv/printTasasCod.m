% -------------------------------------------------------------------------
% script   printTasasCod
% -------------------------------------------------------------------------
% Presenta parametros. Todas las tasas de perforado
% -------------------------------------------------------------------------
% variables usadas
%    tasaMadre   tasa de l codificador sin perforado
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Universidad de M�laga. Dpto. Ingenier�a de Comunicaciones 
% 9-6-2015  Jos� Tom�s Entrambasaguas
% -------------------------------------------------------------------------

[patronesPerforado, tasasPerforado] = definePatronesPerforado;
nPerf=length(patronesPerforado); % numero de patrones de perforado
tasasCod=tasaMadre./tasasPerforado;

fprintf('\nTasas de codificaci�n:')
for kP = 1:nPerf
   fprintf('\n   tasaPerf: %5.3g tasaCod: %5.3g', ...
       tasasPerforado(kP), tasasCod(kP))
end
fprintf('\n')