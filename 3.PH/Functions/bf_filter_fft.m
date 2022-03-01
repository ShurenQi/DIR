function y = bf_filter_fft(x,fft_x,bfdata)

    len = size(bfdata,3);
    bf = flip(flip(conj(bfdata),1),2);
    pbf = single(zeros([size(x),len]));
    pbf(1:size(bf,1),1:size(bf,2),:) = bf;
    y = ifft2(fft2(pbf).*fft_x);
    y = y(size(bf,1):end,size(bf,2):end,:);

end
    
    
    
