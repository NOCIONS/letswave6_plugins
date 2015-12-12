function [out_header,out_data,message_string]=LW_interpolate_channels_selectedepochs(header,data,channel_to_interpolate,channels_to_average, epochs_to_interpolate);
%RLW_interpolate_channels
%
%Interpolate channels
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%


%init message_string
message_string={};
message_string{1}='Interpolate channels';

%prepare out_header
out_header=header;

%init out_data
out_data=data;

%channel_labels
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;

%badchan_idx
a=find(strcmpi(channel_to_interpolate,channel_labels));
if isempty(a);
    message_string{end+1}='*** Electrode label not found. Exit.';
    return;
else
    badchan_idx=a(1);
end;
message_string{end+1}=['Index of channel to interpolate : ' num2str(badchan_idx)];

%avgchan_idx
avgchan_idx=[];
for i=1:length(channels_to_average);
    a=find(strcmpi(channels_to_average{i},channel_labels));
    avgchan_idx=[avgchan_idx a];
end;
if isempty(avgchan_idx);
    message_string{end+1}='*** Electrode labels not found. Exit.';
    return;
end;
message_string{end+1}=['Index of channels to average : ' num2str(avgchan_idx)];

%interpolate
out_data(epochs_to_interpolate,badchan_idx,:,:,:,:)=mean(data(epochs_to_interpolate,avgchan_idx,:,:,:,:),2);




