function varargout = GLW_peakPreview(varargin)
% GLW_PEAKPREVIEW M-file for GLW_peakPreview.fig
%      GLW_PEAKPREVIEW, by itself, creates a new GLW_PEAKPREVIEW or raises the existing
%      singleton*.
%
%      H = GLW_PEAKPREVIEW returns the handle to a new GLW_PEAKPREVIEW or the handle to
%      the existing singleton*.
%
%      GLW_PEAKPREVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_PEAKPREVIEW.M with the given input arguments.
%
%      GLW_PEAKPREVIEW('Property','Value',...) creates a new GLW_PEAKPREVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_peakPreview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_peakPreview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_peakPreview

% Last Modified by GUIDE v2.5 12-Aug-2013 11:38:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_peakPreview_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_peakPreview_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GLW_peakPreview is made visible.
function GLW_peakPreview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_peakPreview (see VARARGIN)

% Choose default command line output for GLW_peakPreview
handles.output = hObject;
% Update handles structure
inputfiles=varargin{2};
set(handles.fileList, 'UserData', inputfiles);
fileNames = cell(size(inputfiles));
for i=1:length(inputfiles);
    [p,n,e]=fileparts(inputfiles{i});
    fileNames{i} = n;
end
set(handles.fileList, 'String', fileNames);
set(handles.fileList, 'Value', 1:numel(inputfiles));

%load first header
header=LW_load_header(inputfiles{1});
channels = {};
for chan = header.chanlocs
    channels = [channels, char(chan.labels)];
end
set(handles.channelList, 'String', channels');
set(handles.channelList, 'Value', 1:numel(channels));

% preload all data 
alldata = cell(1,length(inputfiles));
for i=1:length(inputfiles);
    [header,data]=LW_load(inputfiles{i});
    alldata{i} = data;
end    
set(handles.channelList, 'UserData', alldata);


updateGraph(hObject, eventdata, handles)
guidata(hObject, handles);

% UIWAIT makes GLW_peakPreview wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function updateGraph(hObject, eventdata, handles)
freq = str2num(get(handles.baseFreq, 'String')) / str2num(get(handles.freqOfInterestFact, 'String'));
% numOfharmonics = str2num(get(handles.numOfHarmonics, 'String'));
% harmonics = (1:numOfharmonics) .* freq;
harmonics = get(handles.numOfHarmonics, 'Value').* freq;

allfiles = get(handles.fileList, 'UserData');
fileNrs = get(handles.fileList, 'Value');
inputfiles = allfiles(fileNrs);
showAvg = get(handles.showAvg, 'Value');

%load first header
header=LW_load_header(inputfiles{1});

% get the rigth bins
bins = floor(harmonics/header.xstep) +1;
if showAvg
    bins = {bins};
else
    bins = num2cell(bins);
end

% make legend of frequencies
if showAvg
    legendEntry = ['avg('];
    for harm = harmonics
        legendEntry = [legendEntry, num2str(harm), 'Hz, '];
    end
    legendEntry = [legendEntry(1:end-2), ')'];
    freqsLegend = {legendEntry};
else
    freqsLegend = {};
    for harm = harmonics
        freqsLegend = [freqsLegend; [num2str(harm), ' Hz' ]];
    end
end


% get all the channel labels
channels = {};
for chan = header.chanlocs
    channels = [channels, char(chan.labels)];
end
%     chanNrs = 1:length(channels);
chanNrs = get(handles.channelList, 'Value');
channels = get(handles.channelList, 'String');
channels = channels(chanNrs)';
chanOrder = 1:numel(chanNrs);
colors = {'r*', 'b*', 'g*', 'm*', 'c*', 'y*'};

if numel(findobj(0,'Name', 'harmonicsPlot')) < 1
    figure();
    set(gcf, 'Name','harmonicsPlot','numbertitle','off');
end
figure(findobj(0,'Name', 'harmonicsPlot'));
clf
alldata = get(handles.channelList, 'UserData');

plottedData = cell(length(inputfiles) * numel(bins) * numel(channels), 4);
lineNr = 1;
for i=1:length(inputfiles);
    [p,n,e]=fileparts(inputfiles{i});
%     st=[p,filesep,n,'.mat'];
%     load(st,'-MAT');
    data = alldata{fileNrs(i)};
    subplot(length(inputfiles), 1, i);
    hold on;
    for binNr = 1:numel(bins)
        dataline = mean(data(1,chanNrs,1,1,1,bins{binNr}), 6);
        plot(chanOrder, dataline, colors{binNr});
        bigPeaks = chanOrder(dataline > 2.1);
        for chanNr = bigPeaks
            text('Position',[chanNr,dataline(chanNr)],'String',channels{chanNr}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'c', 'FontSize',6);
        end
        for chanNr = chanOrder
%             a = {n, channels{chanNr}, freqsLegend{i}, dataline(chanNr)}
            plottedData(lineNr, :) = {n, channels{chanNr}, freqsLegend{binNr}, dataline(chanNr)};
            lineNr = lineNr+1;
        end

    end
    xlim([0, numel(chanNrs)+1]);
    title(n,'interpreter','none');
    set(gca,'XTick',1:length(channels))
    set(gca,'XTickLabel',channels,'FontSize', 6);
    %         set(gca,'Rotation', 270);
    legend(freqsLegend,'Location','EastOutside');
    line([1, numel(channels)], [2, 2], 'Color', 'r', 'LineStyle', '-');
end;
set(handles.baseFreq, 'UserData', plottedData);
hold off;



% --- Outputs from this function are returned to the command line.
function varargout = GLW_peakPreview_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on selection change in fileList.
function fileList_Callback(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateGraph(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function fileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channelList.
function channelList_Callback(hObject, eventdata, handles)
% hObject    handle to channelList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateGraph(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function channelList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseFreq_Callback(hObject, eventdata, handles)
% hObject    handle to baseFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateGraph(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function baseFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freqOfInterestFact_Callback(hObject, eventdata, handles)
% hObject    handle to freqOfInterestFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateGraph(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function freqOfInterestFact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqOfInterestFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numOfHarmonics_Callback(hObject, eventdata, handles)
% hObject    handle to numOfHarmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateGraph(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function numOfHarmonics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numOfHarmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exportData.
function exportData_Callback(hObject, eventdata, handles)
% hObject    handle to exportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plottedData = get(handles.baseFreq, 'UserData');
assignin('base','plottedData',plottedData);


% --- Executes on button press in showAvg.
function showAvg_Callback(hObject, eventdata, handles)
% hObject    handle to showAvg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateGraph(hObject, eventdata, handles)
