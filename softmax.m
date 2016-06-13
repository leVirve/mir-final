function [ scores ] = softmax( x )

    scores = exp(x) / sum(exp(x));

end
