function RedBallObjectTracking() 
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
        imshow(data);
        Rmin = 20;
        Rmax = 80;
        [centersBright, radiiBright] = imfindcircles(diff_im,[Rmin Rmax],'ObjectPolarity','bright');
        viscircles(centersBright, radiiBright,'Color','b');
    end

    stop(vid);
    flushdata(vid);
end

function myKeyPressFcn(hObject, event)
    global KEY_IS_PRESSED;
    KEY_IS_PRESSED = 1;
end