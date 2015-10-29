function varargout = GLW_multiview_table(varargin)
% GLW_MULTIVIEW_TABLE MATLAB code for GLW_multiview_table.fig
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
%



% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_multiview_table_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_multiview_table_OutputFcn, ...
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




% --- Executes just before GLW_multiview_table is made visible.
function GLW_multiview_table_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_multiview_table (see VARARGIN)
% Choose default command line output for GLW_multiview_table
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GLW_multiview_table wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% INSERTED THINGS
% setup Data
tabledata=varargin{1};
set(handles.uitable,'Data',tabledata);
% setup ColumnNames
global colnames;
colnames=varargin{2};
set(handles.uitable,'ColumnName',colnames);
%setup sortpopup
set(handles.sortpopup,'String',colnames);





% --- Outputs from this function are returned to the command line.
function varargout = GLW_multiview_table_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function wsedit_Callback(hObject, eventdata, handles)
% hObject    handle to wsedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of wsedit as text
%        str2double(get(hObject,'String')) returns contents of wsedit as a double


% --- Executes during object creation, after setting all properties.
function wsedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wsedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tabledata=get(handles.uitable,'Data');
assignin('base',get(handles.wsedit,'String'),tabledata);


% --- Executes on button press in sortbutton.
function sortbutton_Callback(hObject, eventdata, handles)
% hObject    handle to sortbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colidx=get(handles.sortpopup,'Value');
table=get(handles.uitable,'Data');
tp=table(:,colidx);
[b,idx]=sort(tp);
if get(handles.sortorderpopup,'Value')==2;
    idx=flipud(idx);
end;
table=table(idx,:);

set(handles.uitable,'Data',table);


% --- Executes on selection change in sortpopup.
function sortpopup_Callback(hObject, eventdata, handles)
% hObject    handle to sortpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sortpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sortpopup


% --- Executes during object creation, after setting all properties.
function sortpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sortpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sortorderpopup.
function sortorderpopup_Callback(hObject, eventdata, handles)
% hObject    handle to sortorderpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sortorderpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sortorderpopup


% --- Executes during object creation, after setting all properties.
function sortorderpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sortorderpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
