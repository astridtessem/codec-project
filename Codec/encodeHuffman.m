function [code, dictionary, vectorSize] = encodeHuffman(motionVector)

    
    % Reshape motionvectores into one row 
    binaryStream = reshape(motionVector, 1,[]);
    %Returns the data in A without any repititions
    uniqueBinaryStream = unique(binaryStream); 
    % histc counts the number of each value in uniqueBinaryStream
    probability = histc(binaryStream, uniqueBinaryStream) / length(binaryStream);
    % Create huffmandirectory for motionVector
    [dictionary, ~] = huffmandict(uniqueBinaryStream,probability);  
    %Encode the binaryStream using the huffman dictionary
    code = huffmanenco(binaryStream, dictionary);

    vectorSize = size(motionVector);
    
end