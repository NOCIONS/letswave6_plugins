function varargout = GLW_interpolate_channels_of1epoch(varargin)
% GLW_interpolate_channels MATLAB code for GLW_butterhigh.fig
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
%




% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_interpolate_channels_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_interpolate_channels_OutputFcn, ...
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


% --- Executes just before GLW_averageepochs is made visible.
function GLW_interpolate_channels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_averageepochs (see VARARGIN)
% Choose default command line output for GLW_averageepochs
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
CLW_set_GUI_parameters(handles);
% %fill listbox with inputfiles
inputfiles=varargin{2};
% set(handles.filebox,'String',inputfiles);
%filebox
set(handles.filebox,'String',inputfiles);
% set(handles.filesToUseBox,'String',inputfiles);
% inputfiles=get(handles.filesToUseBox,'String');
for filepos=1:length(inputfiles);
    [p,n,e]=fileparts(inputfiles{filepos});
    inputfiles{filepos}=[n,e];
end;
set(handles.filesToUseBox,'String',inputfiles);

%load header of first inputfile
inputfiles=get(handles.filebox,'String');
header=LW_load_header(inputfiles{1});
%chanstring
for i=1:length(header.chanlocs);
    chanstring{i}=header.chanlocs(i).labels;
end;
set(handles.chanbox1,'UserData',header);
set(handles.chanbox1,'String',chanstring);
set(handles.chanbox2,'String',chanstring);
%set epochBox
for epochpos=1:header.datasize(1);
    epochstring{epochpos}=num2str(epochpos);
end;
set(handles.epochBox,'String',epochstring);
set(handles.epochBox,'Value',1);




% --- Outputs from this function are returned to the command line.
function varargout = GLW_interpolate_channels_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function filebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in processbutton.
function processbutton_Callback(hObject, eventdata, handles)
% hObject    handle to processbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
inputfiles=get(handles.filebox,'String');

filesToUseNr=get(handles.filesToUseBox,'Value');
% % %list of selected channels
% % channels=get(handles.chanbox,'Value');
%list of selected epochs
epochs=get(handles.epochBox,'Value');
%
badchan=get(handles.chanbox1,'Value');
interpchans=get(handles.chanbox2,'Value');
disp('*** Starting.');
%loop through files
disp('*** Computing interpolation');
for filepos=filesToUseNr % 1:length(inputfiles);
    [header,data]=LW_load(inputfiles{filepos});
    %process
    [header,data]=LW_interpolate_channels_selectedepochs(header,data,badchan,interpchans,epochs);
    LW_save(inputfiles{filepos},get(handles.prefixtext,'String'),header,data);
end
disp('*** Finished.');


% --- Executes on selection change in chanbox1.
function chanbox1_Callback(hObject, eventdata, handles)
% hObject    handle to chanbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function chanbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chanbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in chanbox2.
function chanbox2_Callback(hObject, eventdata, handles)
% hObject    handle to chanbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function chanbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chanbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in findbutton.
function findbutton_Callback(hObject, eventdata, handles)
% hObject    handle to findbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%header
header=get(handles.chanbox1,'UserData');
%selected channel
badchan=get(handles.chanbox1,'Value');
%numchans
numchans=str2num(get(handles.numedit,'String'));
%distances
dist=[];
if header.chanlocs(badchan).topo_enabled==1;
    for i=1:length(header.chanlocs);
        if header.chanlocs(i).topo_enabled==1;
            dist(i)=sqrt((header.chanlocs(i).X-header.chanlocs(badchan).X)^2+(header.chanlocs(i).Y-header.chanlocs(badchan).Y)^2+(header.chanlocs(i).Z-header.chanlocs(badchan).Z)^2);
        else
            dist(i)=-1;
        end;
        if i==badchan;
            dist(i)=-1;
        end;
    end;
    dist(find(dist==-1))=max(dist);
    [tpv,tpi]=sort(dist);
    closest_channels=tpi(1:numchans);
    set(handles.chanbox2,'Value',closest_channels);
end;
    
  





function numedit_Callback(hObject, eventdata, handles)
% hObject    handle to numedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function numedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filesToUseBox.
function filesToUseBox_Callback(hObject, eventdata, handles)
% hObject    handle to filesToUseBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filesToUseBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filesToUseBox


% --- Executes during object creation, after setting all properties.
function filesToUseBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filesToUseBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in epochBox.
function epochBox_Callback(hObject, eventdata, handles)
% hObject    handle to epochBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns epochBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from epochBox


% --- Executes during object creation, after setting all properties.
function epochBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
