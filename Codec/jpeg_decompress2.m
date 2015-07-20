function img = jpeg_decompress(jpeg_in)
    bs = 8;
    %8x8 Quantization matrix for Luma 
    
    Q_luma_80 = [
        6 4 4 6 10 16 20 24;
        5 5 6 8 10 23 24 22;
        6 5 6 10 16 23 28 22;
        6 7 9 12 20 35 32 25;
        7 9 15 22 27 44 41 31;
        10 14 22 26 32 42 45 37;
        20 26 31 35 41 48 48 40;
        29 37 38 39 45 40 41 40;
    ]./3;
    
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
    
    
    channels = 1;
    if length(jpeg_in) == 3
        channels = 3;
    end

        
    %Normalize quantizations matrices
    %Q_luma = Q_luma./double(intmax('uint8'));
    %Q_chroma = Q_chroma./double(intmax('uint8'));

    
    img = zeros(jpeg_in(1).dim(1),jpeg_in(1).dim(2),channels);
    
    dctblock = dctmtx(8);
    dctblock_t = dctblock';
    
    for p = 1:channels
        
        dc = [0 cumsum(jpeg_in(p).dc(2:end))] + jpeg_in(p).dc(1);
        
        fprintf('JPEG Decoding - Huffman decoding\n');
        decode = huffmandeco(jpeg_in(p).enco, jpeg_in(p).dict);
        decode = [decode(1:2:end) decode(2:2:end)];    

        block = cell(jpeg_in(1).dim(1)/bs,jpeg_in(1).dim(2)/bs);
        
        k = 1;
        
        
        for blk_count_y = 1:jpeg_in(1).dim(1)/bs;
            for blk_count_x = 1:jpeg_in(1).dim(2)/bs;
            
                %if mod((blk_count_y-1)*8+blk_count_x,1) == 0
                    %fprintf('JPEG Decoding - block %6d of %6d\n',(blk_count_y-1)*8+blk_count_x,length(dc));
                %end


                blk = zeros(1,64);
                blk(1) = dc((blk_count_y-1)*8+blk_count_x);

                el = 2;
                while(k < length(decode))

                    %runlength = bitshift(uint8(decode(k,1)),-4);
                    runlength = decode(k,1) ;
                    amp = decode(k,2);

                    if (runlength == 0 && amp == 0)
                        k = k+1;
                        break;
                    end
                    if (runlength == 15 && amp == 0)
                        el = el + runlength;
                    else
                        el = el + runlength;
                        blk(el) = amp;
                        el = el + 1;
                    end

                    k = k + 1;



                end
                %fprintf('Block %d, non-zero: %d, cumnonzero: %d, decoded %d\n',blk_count,nonzer,nonzera,k);

                block{blk_count_y,blk_count_x} = unzigzag(blk);
            
            
            
            
            end
        end
        
        size(block)
       
        img(:,:,p) = cell2mat(block);
        
        if p == 1
            Q = Q_luma;
        else 
            Q = Q_chroma;
        end
        func = @(block_struct) ( round((dctblock_t .* (block_struct.data.*Q) .* dctblock)));
        img(:,:,p) = blockproc(img(:,:,p),[bs bs], func);
        
    end
    
 
    %Undo zero centering
    %img = img + 128;
    
    %Normalize
    %YCbCr = YCbCr./255;
    
    if channels == 3
        img = conv_ycbcr2rgb(img);
    end
       
    fprintf('JPEG Decoding - Complete\n');
    end

    function block = unzigzag(zig) 
        block = [
                zig( 1) zig( 2) zig( 6) zig( 7) zig(15) zig(16) zig(28) zig(29);
            
                zig( 3) zig( 5) zig( 8) zig(14) zig(17) zig(27) zig(30) zig(43);
                
                zig( 4) zig( 9) zig(13) zig(18) zig(26) zig(31) zig(42) zig(44);
                
                zig(10) zig(12) zig(19) zig(25) zig(32) zig(41) zig(45) zig(54);
                
                zig(11) zig(20) zig(24) zig(33) zig(40) zig(46) zig(53) zig(55);
                
                zig(21) zig(23) zig(34) zig(39) zig(47) zig(52) zig(56) zig(61);
                
                zig(22) zig(35) zig(38) zig(48) zig(51) zig(57) zig(60) zig(62);
                
                zig(36) zig(37) zig(49) zig(50) zig(58) zig(59) zig(63) zig(64);
                ];
                
    end
