function [ycbcr] = upsample(luma,chroma,J,a,b)

    %ycbcr - image in YCbCr color space.
    %J     - N horizontal samples
    %a     - Number of chomatic samples in 
    %b     - changes between rows

    
    cb = chroma(:,:,1);
    cr = chroma(:,:,2);
    
    ycbcr(:,:,1) = luma;
    ycbcr(:,:,2) = kron(cb,ones(2-b/a,a));
    ycbcr(:,:,3) = kron(cr,ones(2-b/a,a));
    %ycbcr(:,:,2) = reshape(repmat(cb(:).',a,1),dim(2),[])';
    %ycbcr(:,:,3) = reshape(repmat(cr(:).',a,1),dim(2),[])';
    
end