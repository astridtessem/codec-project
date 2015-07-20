# Codec - Project in ECE160 Multimedia Systems.

This program is a video encoder and decoder, called codec. It uses JPEG compression and motion compensation. The encoder returns a bit stream and the decoder takes in that bitstream and return frames


#####main.m
The function that encodes and decodes the videoframes. 
Reads in the directories of images, and resizes them and make them grayscale. 
Encodes and decodes every I frame with JPEG compression algorithms. Computes P and B frames predictions and motionvectors. Use JPEG to Encodes the difference between the prediction and actual frame. Use Huffman to encode the motionVectors. Decodes the difference frames and the motion vector and use these to restore P and B frames. 

#####addCaptions.m
This function takes in the decoded frames. It than reads in a caption.csv file. It adds the captions to the different frames and return them. 

#####captionEncoding.m
This function encodes the caption text using MathWorks huffman function and returns a bitstream.


#####captionDecoding.m
Takes in a bitstream and use decodes with Mathworks huffman function and returns the caption text.


#####write2file.m
Takes in a cell with frames and write them to file as jpg pictures. 

#####EncodeHuffman.m
Reshape the motionvectors and use MathWorks huffman functions to encode the vectors. 

#####jpeg_compress.m
This function takes in an image an compress it into jpeg and returns a bitstrem.


#####jpeg_decompress.m
Takes in a bitstream and decodes it and returns a decompressed image.

#####subsample.m
Does chroma sub-sampling on a image.

#####upsample.m
Upsample the image so that Y, Cb and Cr matrices has the same dimensions.

#####frames2video.m
Stores to decodes frames as an avi video file.

#####write2file.m
Saves the decoded images to file.

#####conv_ycbcr2rgb.m conv_rgb2ycbcr.m
convert images from YCbCr to rgb image. An converts rgb to YCbCr image.

#####costFuncMAD.m compPredictionFrame.m compMotionVectors.m minCost.m
Code from Aroh Barjatya. Functions for block matching in motion compensation.
http://www.mathworks.com/matlabcentral/fileexchange/8761-block-matching-algorithms-for-motion-estimation

#####huffmandict.m huffmanenco.m huffmandeco.m 
Code from Mathworks 2015a. 
Use huffmandict to generates a Huffman code dictionary for the motionvectors. Use huffmanenco to to encode the motionvectors into a binary stream. Use huffmandeco to decodes a binary stream into motionvectors. 
http://www.mathworks.com/help/comm/ref/huffmandict.html







