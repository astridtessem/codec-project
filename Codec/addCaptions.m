function frames = addCaptions(frames,caption)
    
    %Takes in the caption csv file a make it in to 1x3 cells with
    %startframe, duration, captiontext
    
    close all;
    
    
    captions = {};
    for i=2:length(caption)
        str = char(caption(i));
        str = strsplit(str,',');
        if length(str) > 3
            str(3) = strcat(str(3),str(4));
            str(4) = [];
        end
        %combines the 1x3 cells
        captions{i-1} = str;

    end

    for i=1:30
        Image = frames{i};
        
        %Determine which caption text is on which image
        if  i < str2double(captions{1}{2})+str2double(captions{1}{1})   
           
            ctext = captions{1}{3};
        elseif i  < str2double(captions{2}{2})+str2double(captions{2}{1} ) & i >= str2double(captions{2}{1})
  
            ctext = captions{2}{3};
        elseif i <= str2double(captions{3}{2})+str2double(captions{3}{1}) & i >= str2double(captions{3}{1})

            ctext = captions{3}{3};
        else
            
            ctext='';
%         elseif i <= str2double(captions{4}{2})+str2double(captions{4}{1}) & i >= str2double(captions{4}{1})
%             i
%             ctext = captions{4}{3}
        end
    
     figure;
     imshow(Image,[0 255]);
    %add text to the image
    hText = text(100,800,ctext,'Color',[1 0 0],'FontSize',20);
    pause(0.01);
    %saves the image with caption to file
    hFrame = getframe(gca);
   
    
    frames{i}=hFrame.cdata;
    %imwrite(hFrame.cdata,'captionImage' i '.png','png')
    
    
    
    end


end