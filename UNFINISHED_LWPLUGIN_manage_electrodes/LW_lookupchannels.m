function [outheader] = LW_lookupchannels(header,location_filename)
% LW_LookupChannelLocations
% Assign default channel locations according to channel label (spherical)
%
% Inputs
% - header (LW5 header)
% - location_filename : EEGLAB locs textfile
%
% Outputs
% - outheader (LW5 header)
%
% Dependencies : readlocs (EEGLAB); see help readlocs for details.
%
% Author : 
% André Mouraux
% Institute of Neurosciences (IONS)
% Université catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 5
% See http://nocions.webnode.com/letswave for additional information



outheader=header;
%read location_filename
disp(['reading ',location_filename]);
locs=readlocs(location_filename);
%assign locations to channels with matched labels
for chanpos=1:length(header.chanlocs);
    for locpos=1:length(locs);
        if strcmpi(header.chanlocs(chanpos).labels,locs(locpos).labels);
            outheader.chanlocs(chanpos).theta=locs(locpos).theta;
            outheader.chanlocs(chanpos).radius=locs(locpos).radius;
            outheader.chanlocs(chanpos).sph_theta=locs(locpos).sph_theta;
            outheader.chanlocs(chanpos).sph_phi=locs(locpos).sph_phi;
            outheader.chanlocs(chanpos).sph_theta_besa=locs(locpos).sph_theta_besa;
            outheader.chanlocs(chanpos).sph_phi_besa=locs(locpos).sph_phi_besa;
            outheader.chanlocs(chanpos).X=locs(locpos).X;
            outheader.chanlocs(chanpos).Y=locs(locpos).Y;
            outheader.chanlocs(chanpos).Z=locs(locpos).Z;
            outheader.chanlocs(chanpos).topo_enabled=1;
        end;
    end;
end;

%add history
i=length(outheader.history)+1;
outheader.history(i).description='LW_lookupchannels';
outheader.history(i).date=date;
outheader.history(i).index=location_filename;