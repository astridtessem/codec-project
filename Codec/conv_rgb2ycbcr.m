function [ ycbcr ] = conv_rgb2ycbcr( rgb_in )
    
    Kb  = 0.114;
    Kr  = 0.299;
    Kg  = 1-Kr-Kb;
    
    if isa(rgb_in,'uint8');
        rgb = double(rgb_in)./255;
    end
    
    ycbcr = zeros(size(rgb));   
    ycbcr(:,:,1) = ( Kr .* rgb(:,:,1)) + ( Kg .* rgb(:,:,2)) + ( Kb .* rgb(:,:,3));
    ycbcr(:,:,2) = 0.5 + (( rgb(:,:,3) - ycbcr(:,:,1) ) ./ (2*(1-Kb)));
    ycbcr(:,:,3) = 0.5 + (( rgb(:,:,1) - ycbcr(:,:,1) ) ./ (2*(1-Kr)));
    
    if isa(rgb_in,'uint8');
        ycbcr = round(rgb.*255);
    end
    
    
end

