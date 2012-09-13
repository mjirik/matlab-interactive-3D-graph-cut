function [img] = zvyrazni(imgI, lb)
    [r,s] = size(imgI);
    img = cat(3, imgI, imgI, imgI);
    for(i = 1:r)
        for(j = 1:s)
            if(lb(i,j))
                img(i,j,1) = 0.5*img(i,j,1) + 0.5;
            end
        end
    end
end