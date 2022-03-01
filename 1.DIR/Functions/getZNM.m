function NM = getZNM(K)
NM = zeros(0,2);
for n = 0:K
    for m = 0:n
        if mod(n-abs(m),2)==0,
            NM = cat(1, NM , [n m]);
        end
    end
end
end