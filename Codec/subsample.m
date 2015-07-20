function [luma,chroma] = subsample(ycbcr,J,a,b)

    %ycbcr - image in YCbCr color space.
    %J     - N horizontal samples
    %a     - Number of chomatic samples in 
    %b     - changes between rows

    luma = ycbcr(:,:,1);
    step = 2-b/a;
    chroma(:,:,1) = ycbcr(1:step:end,1:a:end,2);
    chroma(:,:,2) = ycbcr(1:step:end,1:a:end,3);
end