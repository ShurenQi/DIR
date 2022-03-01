function NM = getSNM(K)
NM = zeros(0,2);
for n = 1:K
    for m = 0:K
        NM = cat(1, NM , [n m]);
    end
end
end