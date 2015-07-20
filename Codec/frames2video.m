function frames2video(frames)

writer = VideoWriter('awesome.avi');  
writer.FrameRate = 5; % frame per sek
open(writer); 
for i = 1:30 % Frame by frame..
    writeVideo(writer,uint8(frames{i}));  % 
end
close(writer);

end