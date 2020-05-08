function mesh = extract_raw_profile(src,thresh,init_vert,delta,horiz)
%Input src folder of raw surface images, will output a mesh corresponding
%to the raw laser location
%src: directory containing images named IMG_0001.jpg, IMG_0002.jpg, ...
%thresh: minimum intensity threshold to be considered laser light
%init_vert: initial [bottom top] search row for laser light in each column
%delta: extension of search region from found light each frame
%horiz: [left right] boundaries for line search


% take first image to get image meta-data
jpgFileName = strcat(src, 'IMG_','0001', '.jpg');
	if exist(jpgFileName, 'file')
		imageData = imread(jpgFileName);
	else
		fprintf('File %s does not exist.\n', jpgFileName);
    end

height = size(imageData,1);
width = size(imageData,2);

num_img = length(dir(src))-2;

% initialise search window
vert_min = zeros(1,width);
vert_min(:) = init_vert(1);
vert_max = zeros(1,width);
vert_max(:) = init_vert(2);

left = horiz(1);
right = horiz(2);

%initialise measured height matrix
mean_height = zeros(num_img,width);
    

% iterate through all of the 
for k = 1:length(dir(src))-2
	
	% Create an image filename, and read it in to a variable called imageData.
	jpgFileName = strcat(src, 'IMG_', num2str(k,'%04.f'), '.jpg');
	if exist(jpgFileName, 'file')
		img_data = imread(jpgFileName);
	else
		fprintf('File %s does not exist.\n', jpgFileName);
    end
    
    % take the green channel sub red channel as the laser light
    frame = img_data(:,:,2) - img_data(:,:,1);
    
    % compute the profile from the frame data
    for x=left:right
       total_weight = 0;
       % reset as is only set once
       y_min = 0;
       y_max = 0;
       
       for y=vert_min(x):vert_max(x)
           value = double(frame(y,x));
           if value > thresh
               if y_min == 0
                  y_min = y;
               end
               y_max = y;
               mean_height(k,x) = mean_height(k,x) + y*value;
               total_weight = total_weight + value;
           end
       end
       if total_weight > 0
           mean_height(k,x) = mean_height(k,x)/total_weight;
           y_est = floor(mean_height(k,x));
%            img_data(y_est-2:y_est+2,x,1) = 255;
%            img_data(y_est-2:y_est+2,x,2) = 0;
%            
%            img_data(y_est-delta-2:y_est-delta+2,x,1) = 0;
%            img_data(y_est-delta-2:y_est-delta+2,x,2) = 0;
%            img_data(y_est-delta-2:y_est-delta+2,x,3) = 255;
%            
%            img_data(y_est+delta-2:y_est+delta+2,x,1) = 0;
%            img_data(y_est+delta-2:y_est+delta+2,x,2) = 0;
%            img_data(y_est+delta-2:y_est+delta+2,x,3) = 255;
           % update vertical search region
           vert_min(x) = y_est-delta;
           vert_max(x) = y_est+delta;
       % didn't find the laser, use prev value
       elseif k>1
           mean_height(k,x) = mean_height(k-1,x);
       % we just keep it as zero otherwise (consider changing this as it
       % muddies results significantly
       end
    end
    imshow(img_data(init_vert(1):init_vert(2),left:right,:));
    waitforbuttonpress;
    
    mesh=mean_height;
    
    
    
end

