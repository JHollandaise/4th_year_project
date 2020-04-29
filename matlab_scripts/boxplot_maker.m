function boxplot_maker(parameters,p_names,joined)
data = [];
groups = [];

% convert each matrix
for i=1:length(parameters)
    for j=1:size(parameters{i},1)
        data = [data; parameters{i}(j,:)'];
        if not(joined)
            groups = [groups; repmat({[p_names{i} '-' int2str(j)]},[size(parameters{i},2) 1])];
        else
            groups = [groups; repmat(p_names(i),[size(parameters{i},2) 1])];
        end
    end
end
figure;
boxplot(data,groups);
xtickangle(90);
end
