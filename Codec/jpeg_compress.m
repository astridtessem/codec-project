function jpeg = jpeg_compress(img_in)
bs = 8; %Block size
tic;

Q_luma_80 = [
    6 4 4 6 10 16 20 24;
    5 5 6 8 10 23 24 22;
    6 5 6 10 16 23 28 22;
    6 7 9 12 20 35 32 25;
    7 9 15 22 27 44 41 31;
    10 14 22 26 32 42 45 37;
    20 26 31 35 41 48 48 40;
    29 37 38 39 45 40 41 40;
];

%8x8 Quantization matrix for Luma
Q_luma = [
    16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 99;
    ];
%8x8 Quantization matrix for Chroma
Q_chroma = [
    17 18 24 47 99 99 99 99;
    18 21 26 66 99 99 99 99;
    24 26 56 99 99 99 99 99;
    47 66 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    99 99 99 99 99 99 99 99;
    ];



%Normalize quantizations matrices
%Q_luma = Q_luma./double(intmax('uint8'));
%Q_chroma = Q_chroma./double(intmax('uint8'));
dim = size(img_in);
channels = 1;
if length(dim) == 3
    channels = 3;
end
if channels == 3
    %Convert from RGB color space to YCbCr color space
    ycbcr_img = conv_rgb2ycbcr(img_in);
    
    %Downsample using 4:2:0 subsampling,
    %removing half the elements of Cb and Cr
    [Y, CbCr] = subsample(ycbcr_img,4,2,0);
    %Upsample to get same dimensions on y, cr and cb matrices.
    ycbcr = upsample(Y,CbCr,4,2,0);
else
    ycbcr = img_in;
end

if max(max(max(ycbcr))) <= 1
    %Zero centering
    ycbcr = ycbcr-0.5;
    %Scale back up to int8
    ycbcr = ycbcr.*255;
else 
    ycbcr = ycbcr - 128;
end

%DCT 8x8
dim = size(ycbcr); %Dimension of image, y_max = dim(1), x_max = dim(2)


nblocks = (dim(1)*dim(2))/(bs^2);
totblocks = channels*nblocks;

dctblock = dctmtx(8);
dctblock_t = dctblock';


for p = 1:channels
    
    n = 1;
    k = 1;
    dc = zeros(nblocks,3);
    ac = zeros(63*nblocks,3);
    
    
    if p == 1
        Q = Q_luma;
    else
        Q = Q_chroma;
    end
    
    
    for y = 1:bs:dim(1)
        for x = 1:bs:dim(2)
            
            
            %if mod(k,totblocks/8) == 0
                %fprintf('JPEG Encoding - block %6d of %6d\n',nblocks*(p-1)+k-1,totblocks);
            %end
            
            ac_range = (k-1)*64+(2-k):(k-1)*64+(64-k);
            
            quantized = dct2(ycbcr(y:y+bs-1,x:x+bs-1,p)) ./ Q;
            zigzag = zigzagify(round(quantized));
            dc(k,p) = zigzag(1);
            ac(ac_range,p) = zigzag(2:64);
            
            
            runlength = 0;
            for elmt = 1:63              %Next element in block
            
                if ac(elmt,p) == 0   %Count zeros
                    runlength = runlength + 1;
                else                     %Non zero, add codeword
                    amplitude = ac(elmt,p);

                    bits = ceil(log2(abs(amplitude)+1));
                    %encoded(p).data(n,:) = [bitor(bitshift(runlength,4), bits), amplitude];
                    encoded(p).data(n,:) = [runlength, amplitude];
                    n = n + 1;
                    runlength = 0;
                end

                if runlength == 15        %Max consequtive zeros reached, adding (15<<4,0) codeword.
                    %encoded(p).data(n,:) = [bitor(bitshift(runlength,4), 0), 0];
                    encoded(p).data(n,:) = [runlength, 0];
                    n = n+1;
                    runlength = 0;
                end
            
            end
            encoded(p).data(n,:) = [0, 0]; % End of block codeword.
            n = n + 1;
            k = k + 1;
            
            
            
        end
        
    end
    
    %fprintf('JPEG Encoding - Huffman encoding\n');
    
    data = double(encoded(p).data)';
    [prob,symb] = hist(data(:),unique(data(:)));
    prob = prob./length(data(:));
    
    encoded(p).dict = huffmandict(symb,prob);
    encoded(p).enco = huffmanenco(data(:),encoded(p).dict);
    
    encoded(p).dc = [dc(1,p) diff(dc(:,p))'];
    encoded(p).dim = dim;
    
end

time = toc;


fprintf('JPEG Encoding - Completed in %f sec\n',time);




jpeg = encoded;


end


function zigzagged =  zigzagify(block)

zigzagged = [   block(1,1) block(1,2) block(2,1) block(3,1) block(2,2) ...
    block(1,3) block(1,4) block(2,3) block(3,2) block(4,1) ...
    block(5,1) block(4,2) block(3,3) block(2,4) block(1,5) ...
    block(1,6) block(2,5) block(3,4) block(4,3) block(5,2) ...
    block(6,1) block(7,1) block(6,2) block(5,3) block(4,4) ...
    block(3,5) block(2,6) block(1,7) block(1,8) block(2,7) ...
    block(3,6) block(4,5) block(5,4) block(6,3) block(7,2) ...
    block(8,1) block(8,2) block(7,3) block(6,4) block(5,5) ...
    block(4,6) block(3,7) block(2,8) block(3,8) block(4,7) ...
    block(5,6) block(6,5) block(7,4) block(8,3) block(8,4) ...
    block(7,5) block(6,6) block(5,7) block(4,8) block(5,8) ...
    block(6,7) block(7,6) block(8,5) block(8,6) block(7,7) ...
    block(6,8) block(7,8) block(8,7) block(8,8)];
end
