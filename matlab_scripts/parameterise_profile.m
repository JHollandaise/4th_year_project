function profile_parameters = parameterise_profile(profile_mesh,n,i_start,i_end,y_space,y_offset,plot_res)
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
hl = [];
hr = [];
% trough difference r_ij
r = [];
% parabola idenifier pp_ij
pli = [];
plx = [];
plz = [];
% parabola parameters
pp = [];
% parameter peak location
phx = [];
phz = [];
% parabola estimated height
ph = [];
% location of the profile in y
y = (i_start:(i_end-1))*y_space+y_offset;

%% user provided trough location initialisation
% we show the user the first valid profile, and they select the relevant 
% trough locations
x = x_mesh(i_start,:)';
z = z_mesh(i_start,:)';
figure();
plot(x,z);
title('Select Trough Locations');
[x_d, z_d] = ginput(n+1);
D = pdist2([x/10 z],[x_d/10 z_d]);
[~, ti(:,1)] = min(D);               % indices

%% user provided parabola identification
% we show the user the first valid profile, and they select the relevant 
% parabola identification locations
title('Select Parabola Locations');
[x_d, z_d] = ginput(n);
close();
D = pdist2([x/10 z],[x_d/10 z_d]);
[~, pli(:,1)] = min(D);               % indices


for j=1:i_end-i_start
    % TODO: amalgamate all updates into a single for loop across all
    % profiles for efficiency (maybe even organise the data structure this
    % way). There is a lot to be done to optimise this but yeah that's
    % expected...
    
    %% from trough indicies get trough locations
    tx(:,j) = x_mesh(j+i_start-1,ti(:,j));
    tz(:,j) = z_mesh(j+i_start-1,ti(:,j));
    
    %% get parabola locator locations from parabola locator indicies
    plx(:,j) = x_mesh(j+i_start-1,pli(:,j));
    plz(:,j) = z_mesh(j+i_start-1,pli(:,j));
    
    %% compute peak location estimates p_ij
    pi(:,j) = floor((ti(1:end-1,j)+ti(2:end,j))/2);
    px(:,j) = x_mesh(j+i_start-1,pi(:,j));
    pz(:,j) = z_mesh(j+i_start-1,pi(:,j));
    
    %% compute parameters
    d(:,j) = tx(1:end-1,j);
    v(:,j) = tz(1:end-1,j);
    wi(:,j) = ti(2:end,j) - ti(1:end-1,j);
    w(:,j) = tx(2:end,j) - tx(1:end-1,j);
    h(:,j) = pz(:,j) - (tz(2:end,j)+tz(1:end-1,j))/2;
    hl(:,j) = pz(:,j) - tz(1:end-1,j);
    hr(:,j) = pz(:,j) - tz(2:end,j);
    r(:,j) = tz(2:end,j)-tz(1:end-1,j);
    
    % this is another loop that should definitely be amalgamated with the
    % others
    % compute bump parabola estimates
    % WARNING, the A matrix is POORLY CONDITIONED, need a recondition
    % number repair on that.
    for i=1:n
        A = [tx(i,j)^2 tx(i,j) 1;
            tx(i+1,j)^2 tx(i+1,j) 1;
            plx(i,j)^2 plx(i,j) 1];
        
        b = [tz(i,j); tz(i+1,j); plz(i,j)];
        
        % compute parameters
        pp(:,i,j) = A\b;
        
        % compute parabola peak location
        phx(i,j) = -pp(2,i,j)/(2*pp(1,i,j));
        phz(i,j) = [phx(i,j)^2 phx(i,j) 1]*pp(:,i,j);
    end
    ph(:,j) = phz(:,j) - (tz(2:end,j)+tz(1:end-1,j))/2;
    
    
    %% update parabola locator estimate (pli(:,j+1))
    % again, need to mash the loops to one
    % search region
    s = 0.4;
    ps_l(:,j) = round(ti(1:end-1,j)+wi(:,j)*(1-s)/2);
    ps_u(:,j) = round(ti(1:end-1,j)+wi(:,j)*(1+s)/2);
    for i=1:n
        % there's definitely more optimisation to be done here
        % get absolute z
        zabs = z_mesh(j+i_start,ps_l(i,j):ps_u(i,j));
        % get x range
        xabs = x_mesh(j+i_start,ps_l(i,j):ps_u(i,j));
        % parabola location
        zpara = pp(1,i,j)*xabs.^2 + pp(2,i,j)*xabs + pp(3,i,j);
        
        % min of relative
        [~,I] = min(zabs-zpara);
        pli(i,j+1) = I+ps_l(i,j)-1;
    end
  
    %% update trough location estimate
    % updated width mean (index)
    mu(j) = mean(wi,'all');
    % updated width s.d (index)
    sd(j) = std(wi,1,'all');
    % width difference weighting
    w_d_temp = zeros([length(wi(:,j))+1 1]);
    w_d_temp(1) = (wi(1,j) - mu(j))/4;
    w_d_temp(2:end-1) = (wi(2:end,j)-wi(1:end-1,j))/4;
    w_d_temp(end) = (mu(j) - wi(end,j))/4;
    w_d(:,j) = w_d_temp;
    % search region lower
    s_l(:,j) = max(min(round(ti(:,j) + w_d(:,j) - sd(j)),size(z_mesh,2)),1);
    % search region upper
    s_u(:,j) = max(min(round(ti(:,j) + w_d(:,j) + sd(j)),size(z_mesh,2)),1);
    % update trough estimate
    for i=1:n+1
        % hr of prev bump and hl of this bump
        hr_prev = 0;
        hl_this = 0;
        if i==1 % we don't know hr so assume diff (mean)
            hl_this = sign(hl(i,j));
            hr_prev = -hl_this;
        elseif i==n+1 % we don't know hl, so assume diff (mean)
            hr_prev = sign(hr(i-1,j));
            hl_this = -hr_prev;
        else
            hr_prev = sign(hr(i-1,j));
            hl_this = sign(hl(i,j));
        end
        
        if hr_prev+hl_this==2 % both positive heights so is minimum 
            [~,I] = min(z_mesh(j+i_start,s_l(i,j):s_u(i,j)));
        elseif hr_prev+hl_this==0 % opposites, so we just take the mean value 
            I = round(ti(i,j) + w_d(i,j)) - s_l(i,j)+1;
        else % otherwise both negative so maximum
            [~,I] = max(z_mesh(j+i_start,s_l(i,j):s_u(i,j)));
        end
        ti(i,j+1) = I+s_l(i,j)-1;
    end
    
    %% draw parameter estimates
    if mod(j,100) == 0
        hold off
        plot(x_mesh(j+i_start-1,:)',z_mesh(j+i_start-1,:)');
        hold on
        % trough locations
        plot(tx(:,j),tz(:,j),'or');
        if plot_res == 2; waitforbuttonpress; end
        % peak locations
        plot(px(:,j),pz(:,j),'ob');
        if plot_res == 2; waitforbuttonpress; end 
        % parabola peak locations
        plot(phx(:,j),phz(:,j),'ob');
        if plot_res == 2; waitforbuttonpress; end
        % width
        plot([d(:,j)'; d(:,j)'+w(:,j)'],[v(:,j)'; v(:,j)'],'r');
        if plot_res == 2; waitforbuttonpress; end
        % height
        x_loc = (tx(2:end,j)+tx(1:end-1,j))/2;
        y_loc = (tz(2:end,j)+tz(1:end-1,j))/2;
        plot([ x_loc'; x_loc'], [y_loc' ; y_loc'+h(:,j)'],'b');
        if plot_res == 2; waitforbuttonpress; end
        % trough difference
        plot([ tx(2:end,j)'; tx(2:end,j)'], [v(:,j)' ; v(:,j)'+r(:,j)'],'r:');
        if plot_res == 2; waitforbuttonpress; end
        % trough search regions
        plot([x_mesh(j+i_start-1,s_l(:,j)); x_mesh(j+i_start-1,s_u(:,j))], [tz(:,j)'; tz(:,j)'],'k','linewidth',2);
        % parabola estimates
        for i=1:n
           x_region = tx(i,j):0.1:(tx(i+1,j));
           plot(x_region, (pp(1,i,j)*x_region.^2 + pp(2,i,j)*x_region + pp(3,i,j)),'b');
        end
%         xlim([-160 -135]);
        waitforbuttonpress;
    end
    
end

%% transfer to output parameters
profile_parameters.tx = tx;
profile_parameters.tz = tz;
profile_parameters.px = px;
profile_parameters.pz = pz;
profile_parameters.w = w;
profile_parameters.h = h;
profile_parameters.hl = hl;
profile_parameters.hr = hr;
profile_parameters.r = r;
profile_parameters.y = y;
profile_parameters.ph = ph;

    %% draw final parameter estimates
    hold off
    plot(x_mesh(j+i_start-1,:)',z_mesh(j+i_start-1,:)');
    hold on
    % trough locations
    plot(tx(:,j),tz(:,j),'or');
    % peak locations
    plot(px(:,j),pz(:,j),'ob');
    % width
    plot([d(:,j)'; d(:,j)'+w(:,j)'],[v(:,j)'; v(:,j)'],'r');
    % height
    x_loc = (tx(2:end,j)+tx(1:end-1,j))/2;
    y_loc = (tz(2:end,j)+tz(1:end-1,j))/2;
    plot([ x_loc'; x_loc'], [y_loc' ; y_loc'+h(:,j)'],'b');
    % trough difference
    plot([ tx(2:end,j)'; tx(2:end,j)'], [v(:,j)' ; v(:,j)'+r(:,j)'],'r:');
    % trough search regions
    plot([x_mesh(j+i_start-1,s_l(:,j)); x_mesh(j+i_start-1,s_u(:,j))], [tz(:,j)'; tz(:,j)'],'k','linewidth',2);
    % parabola estimates
    for i=1:n
       x_region = tx(i,j):0.1:(tx(i+1,j));
       plot(x_region, (pp(1,i,j)*x_region.^2 + pp(2,i,j)*x_region + pp(3,i,j)),'b');
    end
end
