cal_img = underfill_cal;
kernal_width = 0;

% threshold calibration image
cal_img = double( cal_img(:,:,2) - cal_img(:,:,1));

% values for height location of mean laser line
mean_img = zeros(size(cal_img,2),1);

for j=1+kernal_width:size(cal_img,2)-kernal_width
    total_weight = 0;
    for k=-kernal_width:kernal_width
        for i=1:size(cal_img,1)
            mean_img(j) = mean_img(j) + i*cal_img(i,j+k);
            total_weight = total_weight + cal_img(i,j+k);
        end
    end
    mean_img(j) = mean_img(j)/total_weight;
end
imagesc(cal_img);
hold on;
plot(mean_img,'r');
hold on;

% line fit parameters
a = 0.006269;
b = 273.5;
x = 1:size(cal_img,2);
y = a*x + b;
plot(x,y);
        