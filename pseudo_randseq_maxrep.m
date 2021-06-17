function y = pseudo_randseq_maxrep(x, max_rep_allowed)

assert(isvector(x));
dims = size(x);
x = x(:);

while true
    
    % randomize
    x = x(randperm(length(x)));

    % number of repetitions
    dx = diff(x(:));
    max_rep = 0;
    count = 0;
    for i = 1:length(dx)
        if dx(i)==0
            count = count + 1;
        else
            count = 0;
        end
        max_rep = max(count, max_rep);
    end
    
    if max_rep <= max_rep_allowed
        break;
    end
    
end

y = reshape(x, dims);
