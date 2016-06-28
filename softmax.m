function [scores] = softmax(x)
    x = x(x > 0);
    scores = exp(x) / sum(exp(x));
end
