function profile_mesh = mesh_profile(sample,calib, x_space, y_space, x_initial, y_initial)
% correct raw data for laser head rotation
theta = deg2rad(0.507);

sample(:,1) = sample(:,1)*cos(theta) + sample(:,3)*sin(theta);
sample(:,3) = sample(:,3)*cos(theta) - sample(:,1)*sin(theta);

calib(:,1) = calib(:,1)*cos(theta) + calib(:,3)*sin(theta);
calib(:,3) = calib(:,3)*cos(theta) - calib(:,1)*sin(theta);

% generate uniform mesh space
[profile_mesh.x_mesh,profile_mesh.y_mesh] = meshgrid(min(sample(:,1)+sample(:,4)+x_initial):x_space:max(sample(:,1)+sample(:,4)+x_initial),...
                            min(sample(:,2)+y_initial):y_space:max(sample(:,2)+y_initial));
% perform nearest neighbour griddata interpololation on sample                        
profile_mesh.z_mesh = griddata(sample(:,1)+sample(:,4)+x_initial,sample(:,2)+y_initial,sample(:,3),...
                                profile_mesh.x_mesh,profile_mesh.y_mesh,'nearest');
% and linear interpolation on the calibration surface
profile_mesh.z_calib = griddata(calib(:,1)+calib(:,4),calib(:,2),calib(:,3),...
                                profile_mesh.x_mesh,profile_mesh.y_mesh);
                            
profile_mesh.z_mesh = profile_mesh.z_mesh - profile_mesh.z_calib;
end