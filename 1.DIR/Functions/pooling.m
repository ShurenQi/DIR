function poolfeat = pooling(featcell,nof,nos)
%% avg. pooling
    poolfeat =  single(zeros(size(featcell{1})));
    for nf = 1:1:nof
        temp =  single(zeros(size(featcell{1},1),size(featcell{1},2)));
        for ns = 1:1:nos
            temp = temp + featcell{ns}(:,:,nf);
        end
        poolfeat(:,:,nf) = temp/nos;
    end
%% max pooling
%     poolfeat =  single(zeros(size(featcell{1})));
%     for nf = 1:1:nof
%         temp =  single(zeros(size(featcell{1},1),size(featcell{1},2),nos));
%         for ns = 1:1:nos
%             temp(:,:,ns) = featcell{ns}(:,:,nf);
%         end
%         poolfeat(:,:,nf) = max(temp,[],3);
%     end
end

