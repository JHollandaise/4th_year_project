function profile_parameters = parameterise_profile(profile_mesh, n, y_start, y_end)
% rename mesh input to cleanup
x_mesh = profile_mesh.x_mesh;
y_mesh = profile_mesh.y_mesh;
z_mesh = profile_mesh.z_mesh;

%% profile parameter matricies 
% for filled bump i (x direction) and profile j (y (or time) direction)
% trough locations t_ij
ti = [];
tx = [];
tz = [];
% peak locations p_ij
pi = [];
px = [];
pz = [];
% horizontal location d_ij
d = [];
% vertical location v_ij
v = [];
% width w_ij
wi = [];
w = [];
% height h_ij
h = [];
h = [];
% trough difference r_ij
r = [];
r= [];

%% user provided trough location initialisation
% we show the user the first valid profile, and they select the relevant 
% trough locations
x = x_mesh(y_start,:)';
z = z_mesh(y_start,:)';
hold off;
plot(x,z);
[x_d z_d] = ginput(n+1);
D = pdist2([x/10 z],[x_d/10 z_d]);
[~,ti(:,1)] = min(D);               % indices



%% main computation loop
for j=1:y_end-y_start
    %% from trough indicies get trough locations
    tx(:,j) = x_mesh(j+y_start-1,ti(:,j));
    tz(:,j) = z_mesh(j+y_start-1,ti(:,j));
    %% compute peak location estimates p_ij
    pi(:,j) = floor((ti(1:end-1,j)+ti(2:end,j))/2);
    px(:,j) = x_mesh(j+y_start-1,pi(:,j));
    pz(:,j) = z_mesh(j+y_start-1,pi(:,j));
    
    %% compute parameter estimates
    d(:,j) = tx(1:end-1,j);
    v(:,j) = tz(1:end-1,j);
    wi(:,j) = ti(2:end,j) - ti(1:end-1,j);
    w(:,j) = tx(2:end,j) - tx(1:end-1,j);
    h(:,j) = pz(:,j) - (tz(2:end,j)+tz(1:end-1,j))/2;
    r(:,j) = tz(2:end,j)-tz(1:end-1,j);
    
    %% update trough location estimate
    % updated width mean (index)
    mu(j) = mean(wi,'all');
%     mu(j)=71.5313;
    % updated width s.d (index)
    sd(j) = std(wi,1,'all');
%     sd(j)=3.4076;
    % width difference weighting
    w_d_temp = zeros([length(wi(:,j))+1 1]);
    w_d_temp(1) = (wi(1,j) - mu(j))/4;
    w_d_temp(2:end-1) = (wi(2:end,j)-wi(1:end-1,j))/4;
    w_d_temp(end) = (mu(j) - wi(end,j))/4;
    w_d(:,j) = w_d_temp;
    % search region lower
    s_l(:,j) = round(ti(:,j) + w_d(:,j) - sd(j));
    % search region upper
    s_u(:,j) = round(ti(:,j) + w_d(:,j) + sd(j));
    % update trough estimate
    for i=1:n+1
        % temporary const for r imbalance
        r_lim = 1;
        % temparary const for h imbalance
        h_min = 0.3;
        
        
        % r left positive and r right negative variables
        r_rn = false;
        r_lp = false;
            if i==1 && (h(i,j) < h_min)
                r_rn = r(i,j) < r_lim;
                r_lp = ~r_rn;
            elseif i==n+1 && (h(i-1,j) < h_min)
                r_lp = r(i-1,j) > r_lim;
                r_rn = ~r_lp;
            elseif i~=1 && i~=n+1 && (h(i-1,j) < h_min) && (h(i,j) < h_min)
                r_lp = r(i-1,j) > r_lim;
                r_rn = r(i,j) < r_lim;
            end
        
        if and(r_lp,r_rn)
            [~,I] = max(z_mesh(j+y_start,s_l(i,j):s_u(i,j)));
        elseif xor(r_lp,r_rn)
            I = round(ti(i,j) + w_d(i,j)) - s_l(i,j)+1;
        else
            [~,I] = min(z_mesh(j+y_start,s_l(i,j):s_u(i,j)));
        end
        ti(i,j+1) = I+s_l(i,j)-1;
    end
    
    %% draw parameter estimates
    hold off
    plot(x_mesh(j+y_start-1,:)',z_mesh(j+y_start-1,:)');
    hold on
    % trough locations
    plot(tx(:,j),tz(:,j),'or');
%     waitforbuttonpress;
    % peak locations
    plot(px(:,j),pz(:,j),'ob');
%     waitforbuttonpress;
    
    % width
    plot([d(:,j)'; d(:,j)'+w(:,j)'],[v(:,j)'; v(:,j)'],'r');
%     waitforbuttonpress;
    % height
    x_loc = (tx(2:end,j)+tx(1:end-1,j))/2;
    y_loc = (tz(2:end,j)+tz(1:end-1,j))/2;
    plot([ x_loc'; x_loc'], [y_loc' ; y_loc'+h(:,j)'],'b');
%     waitforbuttonpress;
    % trough difference
    plot([ tx(2:end,j)'; tx(2:end,j)'], [v(:,j)' ; v(:,j)'+r(:,j)'],'r:');
%     waitforbuttonpress;
    % search regions
    plot([x_mesh(j+y_start-1,s_l(:,j)); x_mesh(j+y_start-1,s_u(:,j))], [tz(:,j)'; tz(:,j)'],'k','linewidth',2);
    waitforbuttonpress;
    
    
end

%% transfer to output parameters
profile_parameters.d = d;
profile_parameters.v = v;
profile_parameters.wi = wi;
profile_parameters.w = w;
profile_parameters.h = h;
profile_parameters.r = r;
end
