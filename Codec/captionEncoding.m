function [ bitstream, dict ] = captionEncoding( filename )
    
    csv = importdata(filename);
    
    str = double(char(csv(2)));
    for k = 3:length(csv)
        str = [str 10 double(char(csv(k)))];
    end

    [H,X] = hist(str,unique(str));
    dict = huffmandict(X,H/length(str));
    
    bitstream = huffmanenco(str,dict);
    

end

