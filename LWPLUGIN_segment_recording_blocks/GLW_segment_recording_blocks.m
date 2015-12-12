function varargout = GLW_segment_recording_blocks(varargin)
% GLW_SEGMENT_RECORDING_BLOCKS M-file for GLW_segment_recording_blocks.fig
%      GLW_SEGMENT_RECORDING_BLOCKS, by itself, creates a new GLW_SEGMENT_RECORDING_BLOCKS or raises the existing
%      singleton*.
%
%      H = GLW_SEGMENT_RECORDING_BLOCKS returns the handle to a new GLW_SEGMENT_RECORDING_BLOCKS or the handle to
%      the existing singleton*.
%
%      GLW_SEGMENT_RECORDING_BLOCKS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_SEGMENT_RECORDING_BLOCKS.M with the given input arguments.
%
%      GLW_SEGMENT_RECORDING_BLOCKS('Property','Value',...) creates a new GLW_SEGMENT_RECORDING_BLOCKS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_segment_recording_blocks_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_segment_recording_blocks_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_segment_recording_blocks

% Last Modified by GUIDE v2.5 12-Dec-2015 07:36:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_segment_recording_blocks_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_segment_recording_blocks_OutputFcn, ...
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


% --- Executes just before GLW_segment_recording_blocks is made visible.
function GLW_segment_recording_blocks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_segment_recording_blocks (see VARARGIN)

% Choose default command line output for GLW_segment_recording_blocks
handles.output = hObject;
CLW_set_GUI_parameters(handles);

% Update handles structure
guidata(hObject, handles);

% Fill listbox with inputfiles
set(handles.filebox,'String',varargin{2});
% Fill eventmenu with event codes
%load header
inputfiles=get(handles.filebox,'String');
header=LW_load_header(inputfiles{1});
eventstring=searchevents(handles,header);
set(handles.eventmenu,'String',eventstring);

% UIWAIT makes GLW_segment_recording_blocks wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function eventstring=searchevents(handles,header);
eventpos3=1;
eventstring={};
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    found=0;
    if length(eventstring)>0;
        for eventpos2=1:length(eventstring);
            if strcmpi(eventstring{eventpos2},code);
                found=1;
            end;
        end;
    end;
    if found==0;
        eventstring{eventpos3}=code;
        eventpos3=eventpos3+1;
    end;
end;


% --- Outputs from this function are returned to the command line.
function varargout = GLW_segment_recording_blocks_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in eventmenu.
function eventmenu_Callback(hObject, eventdata, handles)
% hObject    handle to eventmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns eventmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventmenu


% --- Executes during object creation, after setting all properties.
function eventmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filebox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filebox


% --- Executes during object creation, after setting all properties.
function filebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processbutton.
function processbutton_Callback(hObject, eventdata, handles)
% hObject    handle to processbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=get(handles.filebox,'String');
disp('*** Starting.');
%loop through files
for filepos=1:length(inputfiles);
    %load header, data
    [header,data]=LW_load(inputfiles{filepos});
    %currently only works with a single epoch
    if size(data,1) > 1;
        msgbox('Function currently only works for files with a single epoch!');
        return;
    end
    %eventcodes
    eventstring=get(handles.eventmenu,'String');
    eventvalue=get(handles.eventmenu,'Value');
    if length(eventvalue)==0;
        msgbox('No events selected!');
        return;
    elseif length(eventvalue)> 1
        msgbox('Select only 1 type of event!');
        return;
    elseif length(eventvalue)== 1
        eventcodes{1}=eventstring{eventvalue(1)};
    end;
    %find location and latency of the event
    allEvents = {header.events(:).code}';
    blockEventInd = 1:length(allEvents);
    blockEventInd(cellfun(@isempty,strfind(allEvents, eventcodes{1}))) = [];
    allEventEpoch = [header.events(:).epoch]';
    blockEventEpoch = allEventEpoch(blockEventInd);
    allEventLatency = [header.events(:).latency]';
    blockEventLat = allEventLatency(blockEventInd);
    %remove epoch mark if appears at recording onset (0.5 sec)
    blockEventInd(blockEventLat<0.5) = [];
    blockEventEpoch(blockEventLat<0.5) = [];
    blockEventLat(blockEventLat<0.5) = [];
    %which event belongs to which epoch
    uniqueEpochEvent = unique(blockEventEpoch);
    for u = 1:length(uniqueEpochEvent)
        epochEventInd{u} = find(blockEventEpoch == uniqueEpochEvent(u));
    end
    %transfer header to outheader
    out_header=header;
    %intitialize outdata
    out_data = zeros(size(data));
    lastBinLat = header.xstart + (size(data,6) .* header.xstep);
    addOneEvent =0;
    blockEventInd = [blockEventInd 0];
    if round(header.events(blockEventInd(end-1)).latency) < round(lastBinLat);
        addOneEvent = 1;
        blockEventInd(end) = size(data,6);
    end
    dxend = 0;
    previousBlockVolt = data(1,:,:,:,:,1);
    voltDiff = zeros(1,size(data,2));
    for eventpos=1:length(blockEventInd);
        if eventpos == length(blockEventInd)
            if addOneEvent
                %         currentevent=header.events(blockEventInd(eventpos));
                %         epochpos=currentevent.epoch;
                dxstart= dxend+1;
                dxend=blockEventInd(eventpos);
            else
                break;
            end
        else
            currentevent=header.events(blockEventInd(eventpos));
            epochpos=currentevent.epoch;
            dxstart= dxend+1;
            dxend=fix((currentevent.latency-header.xstart)/header.xstep)-1;
        end       
%         
%         figure; hold on
%         %     plot(dxstart-10:dxstart+10,bsxfun(@minus,squeeze(data(1,3,1,1,1,dxstart-10:dxstart+10)),mean(squeeze(data(1,3,1,1,1,dxstart-10:dxstart+10)),2)));
%         plot(dxstart-10:dxstart+10,squeeze(data(1,3,1,1,1,dxstart-10:dxstart+10)));
%         plot(dxstart,mean(squeeze(data(1,3,1,1,1,dxstart-10:dxstart+10))),'ro');
        
        %voltage difference
        voltAtStart = data(epochpos,:,:,:,:,dxstart);
        voltDiff = previousBlockVolt - voltAtStart;
        for chanpos = 1:size(data,2);
            for indexpos=1:size(data,3);
                for dz=1:size(data,4);
                    for dy=1:size(data,5);
                        out_data(epochpos,chanpos,indexpos,dz,dy,dxstart:dxend) = data(epochpos,chanpos,indexpos,dz,dy,dxstart:dxend) + voltDiff(epochpos,chanpos,indexpos,dz,dy,:);
                    end
                end
            end
        end        
        %store last voltage of current block
        previousBlockVolt = out_data(epochpos,:,:,:,:,dxend);        
    end    
    %save header,data
    LW_save(inputfiles{filepos},get(handles.prefixtext,'String'),out_header,out_data);
end;
disp('*** Finished.');


function prefixtext_Callback(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefixtext as text
%        str2double(get(hObject,'String')) returns contents of prefixtext as a double


% --- Executes during object creation, after setting all properties.
function prefixtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startedit_Callback(hObject, eventdata, handles)
% hObject    handle to startedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startedit as text
%        str2double(get(hObject,'String')) returns contents of startedit as a double


% --- Executes during object creation, after setting all properties.
function startedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endedit_Callback(hObject, eventdata, handles)
% hObject    handle to endedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endedit as text
%        str2double(get(hObject,'String')) returns contents of endedit as a double


% --- Executes during object creation, after setting all properties.
function endedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
