function p = compute_probability(model, observations, observation_window, tracks)
%COMPUTE_PROBABILITY estimate log likelihood of some provided model against
% given observations.
%   model              - a cell array containing the relevant probability distributions
%                        asscociated with the model 
%   obervations        - observed values corresponing to the generating functions
%                        provided in model
%   observation_window - a rolling window along the profile direction. zero
%                        indicates the entire length
%   tracks             - how many of the sample stitch tracks to lump into a
%                        single likelihood. zero indicates all tracks.

if tracks == 0
    tracks = size(observations{1},1);
end
if observation_window == 0
   observation_window = size(observations{1},2);
end

p = zeros([size(observations{1},1)-(tracks-1) size(observations{1},2)-(observation_window-1)]);
% iterate over track windows (we have to assume all data in observations is
% consistent)
for i = 1:(size(observations{1},1)-(tracks-1))
    % iterate over profiles, again assuming consistency
    for j = 1:(size(observations{1},2)-(observation_window-1))
        % iterate over models
        for k = 1:length(model)
            % add log probability to relevant location in p
            p(i,j) = p(i,j) + sum(log(pdf(model{k},observations{k}(i:i+(tracks-1),j:j+(observation_window-1)))),'all');
        end
    end
end

end

