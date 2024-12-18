function [film,Imref,params]=readH5Video(fname,varargin)
% [film,params]=h5videoRead(fname,n0,nframes)

params = h5read(fname,'/params');
if nargin > 1;
    n0 = varargin{1};
    ncount = varargin{2};
else
    n0 = 1;
    ncount = params.total_nframes;
end
    
Imref = h5read(fname,'/Imref');

rows = size(Imref,1);
cols = size(Imref,2);

film=h5read(fname,'/Im',[1 1 n0],[rows cols ncount]);
