function [ rgb ] = conv_ycbcr2rgb( ycbcr )
    
    
    if max(max(max(ycbcr))) <= 1
        center = 0.5;
    else
        center = 128;
    end
    
    rgb = zeros(size(ycbcr));

    rgb(:,:,1) = ycbcr(:,:,1) + 1.402.*(ycbcr(:,:,3) - center);
    rgb(:,:,2) = ycbcr(:,:,1) - 0.34414.*(ycbcr(:,:,2) - center) - 0.71414.*(ycbcr(:,:,3) - center);
    rgb(:,:,3) = ycbcr(:,:,1) + 1.772.*(ycbcr(:,:,2) - center);
    

end

