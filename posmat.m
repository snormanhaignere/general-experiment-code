function pmat = posmat(seq,varargin)

nconds = max(seq(:)); % assumes conditions are 1:max(seq(:))

if ~isequal(unique(seq(:))', 1:nconds)
    error('Bad input sequence');
end

posgroup = 1;
if optInputs(varargin,'posgroup');
    posgroup = varargin{optInputs(varargin,'posgroup')+1};
end

npos = size(seq,1);
order = repmat(ceil((1:npos)'/posgroup),1,size(seq,2));
inds = sub2ind([npos/posgroup, nconds],order(:),seq(:));

pmat = zeros(npos/posgroup,nconds);
for j = 1:length(inds)
    pmat(inds(j)) = pmat(inds(j))+1;
end

% fprintf('\nPosition Matrix: \n\n');
% disp(pmat);

