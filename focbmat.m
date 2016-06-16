function cbmat = focbmat(seq)

nconds = max(seq(:)); % assumes conditions are 1:max(seq(:))

if ~isequal(unique(seq(:))', 1:nconds)
    error('Bad input sequence');
end

x = seq(2:end,:);
y = seq(1:end-1,:);
inds = sub2ind([nconds nconds],x(:),y(:));

cbmat = zeros(nconds);
for j = 1:length(inds)
    cbmat(inds(j)) = cbmat(inds(j))+1;
end

% fprintf('\nFirt Order Counterbalancing Matrix: \n\n');
% disp(cbmat);

