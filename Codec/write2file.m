function write2file(IBPBFrames)

dir='High5_JPG';

for i=1:length(IBPBFrames)
    
    filename = sprintf('%s/FRAME0%i.jpg',dir,i);
    imwrite(uint8(IBPBFrames{i}),filename)
end



end

