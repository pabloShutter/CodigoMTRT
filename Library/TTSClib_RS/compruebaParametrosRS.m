function compruebaParametrosRS(q, m, k, m0, k0)

if nargin > 3
    if m0 ~= 2^q-1
        error ('m0 no es igual a 2^q-1')
    end
else
   if m ~= 2^q-1
       error ('m no es igual a 2^q-1')
   end
end

if nargin > 3
    if m0-k0 ~= (m-k)
        error ('(m-k) no es igual a(m0-k0)')
    end
end

if k >= m
   error ('k no es menor que m')
end

if fix((m-k)/2) ~= (m-k)/2
   error ('(m-k) no es par')
end

end

