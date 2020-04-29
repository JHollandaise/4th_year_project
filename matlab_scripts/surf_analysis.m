%% initialise globals
scan_name = FBN_01_03_2;
save_name = "FBN_01_03_0";

%% plot simple scatter3 of scan
% NOTE: columns: (x_pos, y_pos, z_pos, x_offset)
scatter3(scan_name(1:20:end,1)+scan_name(1:20:end,4),scan_name(1:20:end,2),scan_name(1:20:end,3),1,scan_name(1:20:end,3));
% xlim([-40 20]);
% ylim([53 90]);
% zlim

%% mesh interpolate the data
[x_mesh,y_mesh] = meshgrid(min(scan_name(:,1)+scan_name(:,4)):0.1:max(scan_name(:,1)+scan_name(:,4)), min(scan_name(:,2)):0.5:max(scan_name(:,2)));
z_mesh = griddata(scan_name(:,1)+scan_name(:,4),scan_name(:,2),scan_name(:,3),x_mesh,y_mesh,'nearest');

%% median filter the mesh interpolation
z_mesh = medfilt3(z_mesh, [501 31 201]);

%% correct for laser rotation
theta = deg2rad(0.507);

scan_name(:,1) = scan_name(:,1)*cos(theta) + scan_name(:,3)*sin(theta);
scan_name(:,3) = scan_name(:,3)*cos(theta) - scan_name(:,1)*sin(theta);


%% display the mesh
figure();
mesh(x_mesh, y_mesh, z_mesh,'FaceAlpha','0.5');
% ylim([50 max(scan_name(:,2))])
% zlim([45 55])