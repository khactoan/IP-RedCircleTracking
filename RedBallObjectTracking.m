function RedBallObjectTracking() 
    warning off;
    global KEY_IS_PRESSED;
    KEY_IS_PRESSED = 0;
    gcf;
    set(gcf, 'KeyPressFcn', @myKeyPressFcn);
    
    camera = imaqhwinfo;
    [camera_name, camera_id, format] = getCameraInfo(camera);
    
    vid = videoinput(camera_name, camera_id, format);
    set(vid, 'FramesPerTrigger', Inf);
    set(vid, 'ReturnedColorspace', 'rgb');
    vid.FrameGrabInterval = 5;
    start(vid)

    while ~KEY_IS_PRESSED
        data = getsnapshot(vid);
        diff_im = imsubtract(data(:,:,1), rgb2gray(data));
        diff_im = medfilt2(diff_im, [3 3]);
        diff_im = im2bw(diff_im,0.18);
        Rmin = 10;
        Rmax = 100;
        [centersBright, radiiBright] = imfindcircles(diff_im,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.75);
%         viscircles(centersBright, radiiBright,'Color','b');
        [m n] = size(radiiBright);
        if m == 0 && n == 0
            imshow(data);
        else
            overlayImage = data;
           % imageSize = size(overlayImage);
            [r c b] = size(data);
            for a=1:m
               down = centersBright(a,2) - radiiBright(a,1) - 5;
               top = centersBright(a,2)+ radiiBright(a,1) + 5;
               left = centersBright(a,1) - radiiBright(a,1) - 5;
               right = centersBright(a,1) + radiiBright(a,1) + 5;

               if left < 1
                    left = 1;
               end
               if right > c
                    right = c;
               end
               if down < 1
                    down = 1;
               end
               if top > r
                    top = r;
               end
               for i=1:3   
                    window = overlayImage(down:top,left:right,i);
                    H = fspecial('disk',50);
                    window = imfilter(window,H,'replicate'); 
                    overlayImage(down:top,left:right,i) = window;
               end 
            end
            
            imshow(overlayImage);
        end
    end

    stop(vid);
    flushdata(vid);
end

function myKeyPressFcn(hObject, event)
    global KEY_IS_PRESSED;
    KEY_IS_PRESSED = 1;
end