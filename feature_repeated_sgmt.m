function [score_i] = feature_repeated_sgmt( sgmt_array, index,labels )

    rpa = zeros(length(labels),1);
    for i = 1:length(sgmt_array)
        
        for j = 1:length(labels)
            if(strcmp(sgmt_array{i}.label, labels{j}))
                rpa(j) = rpa(j) + 1;
                break;
            end
        end
        
    end

        
%     ave =  sum(rpa) / length(labels);
    score = rpa./length(sgmt_array);
%     score
    score_i = 0;
    for j = 1:length(labels)
        if(strcmp(sgmt_array{index}.label, labels{j}))
            score_i = score(j);
            break;
        end
    end
    
%     score1
%     score2 = softmax(score1);
%     score2
% ave
%     for j = 1:length(labels)
%         if(rpa(j) > ave)
%              rpa(j) * 
%         end
%     end 
%     weighted_labels  = softmax(labels);
%     score = weighted_labels(sgmt_array{index}.label - 'A' + 1);
end

