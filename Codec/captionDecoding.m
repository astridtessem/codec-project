function [ caption ] = captionDecoding( bitstream, dict )
    

    str = huffmandeco(bitstream,dict);
    
    line = 1;    
    spos = 1;
    epos = 1;
    for c = str
        if c == 10
            caption{line,1} = char(str(spos:epos-1));
            epos = epos + 1;
            spos = epos;
            line = line + 1;
        else
            epos = epos + 1;
        end
    end
    caption{line,1} = char(str(spos:end));
    

end

