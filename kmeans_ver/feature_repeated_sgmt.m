function [score] = feature_repeated_sgmt( sgmt_array, index )

    labels = zeros(1,26);
    
    for i = 1:length(sgmt_array)
        sg_l(i) = sgmt_array{i}.label;
        labels(sgmt_array{i}.label - 'A' + 1) =  labels(sgmt_array{i}.label - 'A' +1)+1;
    end
%     labels
%     sg_l
    weighted_labels  = softmax(labels);
    score = weighted_labels(sgmt_array{index}.label - 'A' + 1);
end

