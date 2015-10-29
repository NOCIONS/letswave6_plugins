function out = stretch(in,minmax)

%
% Usage:
% out = stretch(in,minmax);
%
% OUT = STRETCH(IN) scales IN to [0 1].
% OUT = STRETCH(IN,MINMAX) scales IN to [minmax(1) minmax(2)]. MINMAX is  2
% element vector between which IN should be scaled.
%
%
% Originally writen by Frederic Gosselin
%
% Edited by Corentin Jacques (added MINMAX option), oct 2011.
%

% stretch(X)
%out = (in-min(in(:))) / (max(in(:)) - min(in(:)));
if nargin == 1
    minmax = [0 1];
end

if any(diff(in(:))); % if the values in the vector are not all the same
    
    %scale to [0 1]
    in=double(in);
    out = (in-min(in(:))) / (max(in(:)) - min(in(:)));
    
    %scale to minmax
    out = (out * (minmax(2) - minmax(1)) ) + minmax(1);
else
    out = ones(size(in));
end