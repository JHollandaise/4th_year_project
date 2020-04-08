function mata = parameterise_profile(profile_mesh,n_tracks,y_start, y_end)
x_mesh = profile_mesh.x_mesh;
y_mesh = profile_mesh.y_mesh;
z_mesh = profile_mesh.z_mesh;

% next, we show the user the first profile line and request they
% select the troughs
x = x_mesh(y_start,:)';
z = z_mesh(y_start,:)';
scatter(x,z);
g = ginput(n_tracks+1);
D = pdist2([x z],g);
[~,t_i] = min(D)               % indices
hold on
plot(x_mesh(1,ix),z_mesh(1,ix),'or')
hold off


% now we loop through all of the profiles and find the parameters
for i=y_start:y_end
    % find new local minimum for all trough locations
    [~,t_i] = min(z_mesh(i,
end
end
