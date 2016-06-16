function best_condseqs = opt_pos_cb(condseq,nseq,nsearch,posweight,cbweight,varargin)

nconds = max(condseq);
ntrials = length(condseq);

if ~isequal(1:max(condseq),unique(condseq))
    error('Conditions not specified as an increasing list of non-zero numbers');
end

%%

% number of repetitions per condition
nreps_cond = zeros(1,nconds);
for i = 1:nconds
    nreps_cond(i) = sum(i==condseq);
end

% ideal counterbalancing matrix
ideal_cb = zeros(nconds);
for i = 1:nconds
    x = nreps_cond;
    x(i) = nreps_cond(i)-1;
    ideal_cb(i,:) = nreps_cond(i)*(x/sum(x));
end
ideal_cb_vec = ideal_cb(:);

% ideal position matrix
posgroup = 1;
if optInputs(varargin,'posgroup');
    posgroup = varargin{optInputs(varargin,'posgroup')+1};
end
ideal_pos = repmat(nreps_cond, ntrials/posgroup, 1)/(ntrials/posgroup);
ideal_pos_vec = ideal_pos(:);

%% matrix indices for random sequences

fprintf('Optimizing counterbalancing with greedy algorithm...\n')

if optInputs(varargin, 'nullorder')
    nullorder = varargin{optInputs(varargin, 'nullorder')+1};
    nullorder = nullorder(:);
    condseq_rand = nullorder * ones(1,nsearch) + 1;
    condseq_rand(condseq_rand > 1) = Shuffle(condseq(condseq > 1)' * ones(1,nsearch));
else
    condseq_rand = Shuffle(repmat(condseq',1,nsearch));
end

%%
% counterbalancing indices
a = condseq_rand(2:end,:);
b = condseq_rand(1:end-1,:);
cb_inds = reshape( sub2ind([nconds nconds],a(:),b(:)), ntrials-1, nsearch );
clear a b;

% position indices
order = repmat(ceil((1:ntrials)'/posgroup),1,nsearch);
pos_inds = reshape( sub2ind([ntrials/posgroup, nconds],order(:),condseq_rand(:)), ntrials, nsearch );
clear order;

% counterbalancing and position matrices
cb_counts = zeros(nconds^2, nsearch);
pos_counts = zeros(ntrials*nconds/posgroup, nsearch);

% initialize best sequence matrix, final output of algorithm
best_condseqs = nan(ntrials, nseq);

for i = 1:nseq
    
    fprintf('\nseq %d \n',i);
    nseq_left = nsearch - (i-1);
    
    % update counterbalancing matrix
    for j = 1:nseq_left;
        for k = 1:ntrials-1;
            cb_counts(cb_inds(k,j),j) = cb_counts(cb_inds(k,j),j)+1;
        end
    end
    
    for j = 1:nseq_left;
        for k = 1:ntrials;
            pos_counts(pos_inds(k,j),j) = pos_counts(pos_inds(k,j),j)+1;
        end
    end
    
    % differences from ideal
    cb_diff = cb_counts - repmat( ideal_cb_vec*i, 1, nseq_left );
    pos_diff = pos_counts - repmat( ideal_pos_vec*i, 1, nseq_left );
    
    % minimum cost
    cost = posweight*nansum( pos_diff.^2 ) + cbweight*nansum( cb_diff.^2 );
    [zz, bestseq] = min(cost); %#ok<*ASGLU>
    best_condseqs(:,i) = condseq_rand(:,bestseq);
    
    % remove best sequence
    cb_inds(:,bestseq) = [];
    pos_inds(:,bestseq) = [];
    condseq_rand(:,bestseq) = [];
    
    
    % replicate best cb and pos matrix
    cb_counts = repmat( cb_counts(:,bestseq(1)), 1, nseq_left-1 );
    pos_counts = repmat( pos_counts(:,bestseq(1)), 1, nseq_left-1 );
    
    if posweight > 0
        posmat(best_condseqs(:,1:i),varargin{:});
    end
    if cbweight > 0
        focbmat(best_condseqs(:,1:i));
    end
    
end