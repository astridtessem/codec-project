
function frames = main(caption)

close all;

%Directory with the video frames
dir='High5_PNG';

MBsize=8;
p=9;

NFrames = 30;
FrameCount = 1;

originalFrames{30} = []; % Container for the original frames
IBPBFrames{30} = []; % Contianer for the new IBPB frames 


%%Encode Caption
[captBitstream, captDict] = captionEncoding('High5_PNG/caption.csv');


%% Read all frames from file and add them in the originalFrames cell
for i=1:NFrames
    fprintf('Loading frame %3d of %3d\n',i,NFrames);
    filename = sprintf('%s/FRAME%03i.png',dir,i);
    
    %Resize the frames and make them gray 
    originalFrames{i}= double(rgb2gray(imresize(  imread(filename) , 0.5))) ;
end



%% Copy over all the I frames, every 4th image

%----------- IMPORT I FRAMES ----------% 


%Copy every 4th frame and number 30
for i = 1 : 4 : NFrames-3
     fprintf('Processing frame %3d of %3d - I Frame\n',FrameCount,NFrames);
     FrameCount = FrameCount + 1;
     
     %----------- ENCODE I FRAMES ----------%
      
     jpeg = jpeg_compress(originalFrames{i}./255);
     
     %----------- DECODE I FRAMES ----------% 
     
     decodedIFrame = jpeg_decompress(jpeg).*255;
     
      %----------- STORE I FRAMES ----------% 
      
      IBPBFrames{i} = decodedIFrame;


end
for i = 1:mod(NFrames,4) %Add IFrames if number of frames not a factor of 4
    fprintf('Processing frame %3d of %3d - I Frame supplemental\n',FrameCount,NFrames);
    FrameCount = FrameCount + 1;
    jpeg = jpeg_compress(originalFrames{NFrames-(i-1)}./255);
    IBPBFrames{NFrames-(i-1)} = jpeg_decompress(jpeg)*255;
end







%% Calculate P frames. IBPB is the frame sequence

%----------- IMPORT P FRAMES ----------% 

for i = 1 : 4 : NFrames-3

    
    tic;
    
    
    Iframe = originalFrames{i};
    Pframe = originalFrames{i+2};
    
    
   %----------- ENCODING P FRAMES ----------%  
    
    % Motion vector between I -> P
    motionVect  = compMotionVectors(Iframe, Pframe, MBsize, p);
    % Encode motion vector
    [code, dictionary, vectorSize] = encodeHuffman(motionVect);
    
    % Compensated image between I -> P
    imgComp = compPredictionFrame(Iframe, motionVect, MBsize);
    
    
    %Subtract prediction frame from original image
    imageError = Pframe - imgComp;
    
    jpeg = jpeg_compress(imageError./255);
    
    % -------- DECODING P FRAMES ---------%
    
    
    decodedImageError = jpeg_decompress(jpeg).*255;
   
    decodedMotionvector = huffmandeco(code, dictionary);
    decodedMotionvector = reshape(decodedMotionvector, vectorSize(1,1), vectorSize(1,2));
    
    % -------- STORING P FRAMES ---------- %
    
    IBPBFrames{i+2} = compPredictionFrame(IBPBFrames{i}, decodedMotionvector, MBsize) + decodedImageError; %imageError skal være decoded!!
    
    time = toc;
    fprintf('Processed frame %3d of %3d - P Frame - in %f seconds\n',FrameCount,NFrames, time);
    FrameCount = FrameCount + 1;

end


%% Calculate the first Bframe. IBPB is the frame sequence
for i = 2 : 4 : NFrames-2
    
    Iframe   = originalFrames{i - 1}; % This I is behind the B frame
    Bframe   = originalFrames{i};
    Pframe   = originalFrames{i+1};% This P is in front of the B frame


    %----------- ENCODING B FRAMES ----------%  
    
    % Motion vectors between I -> B && P -> B
    motionVectIB = compMotionVectors(Iframe, Bframe,8, p);
    motionVectPB = compMotionVectors(Pframe, Bframe, 8, p);
    [codeIB, dictionaryIB, vectorSize] = encodeHuffman(motionVectIB);
    [codePB, dictionaryPB, vectorSize] = encodeHuffman(motionVectPB);
    
    % Compensated images between I -> B && P -> B
    imgCompIB = compPredictionFrame(Iframe, motionVectIB, 8);
    imgCompPB = compPredictionFrame(Pframe, motionVectPB, 8);

    % Average the two compensated images to get
    imgComp = (imgCompIB + imgCompPB) / 2;
 
    %Subtract prediction frame from original image
    imageError=Bframe - imgComp;
    
    jpeg = jpeg_compress(imageError./255);
       
    %ENCODE IMAGEERROR
    
    %----------- DECODING B FRAMES ----------%  
    
    decodedImageError = jpeg_decompress(jpeg).*255;
    
    decodedMotionvectorIB = huffmandeco(codeIB, dictionaryIB);
    decodedMotionvectorIB = reshape(decodedMotionvectorIB, vectorSize(1,1), vectorSize(1,2));
    
    decodedMotionvectorPB = huffmandeco(codePB, dictionaryPB);
    decodedMotionvectorPB = reshape(decodedMotionvectorPB, vectorSize(1,1), vectorSize(1,2));
    
    % -------- STORING B FRAMES ---------- %
    
    temp1 = compPredictionFrame(IBPBFrames{i - 1}, decodedMotionvectorIB, MBsize);
    temp2 = compPredictionFrame(IBPBFrames{i + 1}, decodedMotionvectorPB, MBsize);
    
    IBPBFrames{i}=(temp1 + temp2)/2 + decodedImageError;
    
    time = toc;
    fprintf('Processing frame %3d of %3d - B Frame 1 - in %f seconds \n',FrameCount,NFrames,time);
    FrameCount = FrameCount + 1;

end

%% Calculate second B frame
for i = 4 : 4 : NFrames-2
    
    
    
    Iframe   = originalFrames{i + 1}; % This I is behind the B frame

    Bframe   = originalFrames{i};

    Pframe   = originalFrames{i-1};% This P is in front of the B frame



    %----------- ENCODING B FRAMES ----------%  
    
    % Motion vectors between I -> B && P -> B
    tic;
    motionVectIB = compMotionVectors(Iframe, Bframe,8, p);
    time = toc;
    fprintf('B2: MotionVectIB took %f seconds\n',time);
    tic;
    motionVectPB = compMotionVectors(Pframe, Bframe, 8, p);
    time = toc;
    fprintf('B2: MotionVectPB took %f seconds\n',time);
    [codeIB, dictionaryIB, vectorSize] = encodeHuffman(motionVectIB);
    [codePB, dictionaryPB, vectorSize] = encodeHuffman(motionVectPB);
    
    % Compensated images between I -> B && P -> B
    imgCompIB = compPredictionFrame(Iframe, motionVectIB, 8);
    imgCompPB = compPredictionFrame(Pframe, motionVectPB, 8);

    % Average the two compensated images to get
    imgComp = (imgCompIB + imgCompPB) / 2;
 
    %Subtract prediction frame from original image
    imageError = Bframe - imgComp;
    
       
    jpeg = jpeg_compress(imageError./255);
    
    %----------- DECODING B FRAMES ----------%  x
    
    decodedImageError = jpeg_decompress(jpeg).*255;
    
    decodedMotionvectorIB = huffmandeco(codeIB, dictionaryIB);
    decodedMotionvectorIB = reshape(decodedMotionvectorIB, vectorSize(1,1), vectorSize(1,2));
    
    decodedMotionvectorPB = huffmandeco(codePB, dictionaryPB);
    decodedMotionvectorPB = reshape(decodedMotionvectorPB, vectorSize(1,1), vectorSize(1,2));
    
    % -------- STORING B FRAMES ---------- %
    
    temp1 = compPredictionFrame(IBPBFrames{i - 1}, decodedMotionvectorPB, MBsize);
    temp2 = compPredictionFrame(IBPBFrames{i + 1}, decodedMotionvectorIB, MBsize);
    
    IBPBFrames{i}=(temp1 + temp2)/2 + decodedImageError;
    
    fprintf('Processed frame %3d of %3d - B Frame 2\n',FrameCount,NFrames);
    FrameCount = FrameCount + 1;
        
end

close all;

%% Add captions

 
 if caption==true
     caption = captionDecoding(captBitstream,captDict);
     IBPBFrames=addCaptions(IBPBFrames,caption);
 end

frames = IBPBFrames;
%% Write decoded images to file

write2file(IBPBFrames);

%% Make video file

frames2video(IBPBFrames);
end