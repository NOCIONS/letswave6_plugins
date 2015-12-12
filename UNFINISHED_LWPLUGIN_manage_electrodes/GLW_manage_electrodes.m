function varargout = GLW_manage_electrodes(varargin)
% GLW_MANAGE_ELECTRODES M-file for GLW_manage_electrodes.fig
%      GLW_MANAGE_ELECTRODES, by itself, creates a new GLW_MANAGE_ELECTRODES or raises the existing
%      singleton*.
%
%      H = GLW_MANAGE_ELECTRODES returns the handle to a new GLW_MANAGE_ELECTRODES or the handle to
%      the existing singleton*.
%
%      GLW_MANAGE_ELECTRODES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_MANAGE_ELECTRODES.M with the given input arguments.
%
%      GLW_MANAGE_ELECTRODES('Property','Value',...) creates a new GLW_MANAGE_ELECTRODES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_manage_electrodes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_manage_electrodes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_manage_electrodes

% Last Modified by GUIDE v2.5 30-Oct-2013 17:37:21

% Author : 
% Gilles Vertongen
% Institute of Neurosciences (IONS)
% Universite Catholique de Louvain (UCL)
% Belgium

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_manage_electrodes_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_manage_electrodes_OutputFcn, ...
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


% --- Executes just before GLW_manage_electrodes is made visible.
function GLW_manage_electrodes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_manage_electrodes (see VARARGIN)

% Choose default command line output for GLW_manage_electrodes
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
set(handles.filebox, 'String', varargin{2});

% default electrode location file
location_letswave = which('letswave');
[directory_letswave, n, e] = fileparts(location_letswave);
directory_spherical_location = [directory_letswave '/resources/electrodes/spherical_locations/'];
filename_spherical_location  = 'biosemi_locations_128.xyz';
set(handles.electrodesfile, 'String', filename_spherical_location);
set(handles.electrodesfile, 'UserData', [directory_spherical_location, filename_spherical_location]);
filename_spline              = 'biosemi_spline_128.spl';
set(handles.splinefile, 'String', filename_spline);
set(handles.splinefile, 'UserData', [directory_spherical_location, filename_spline]);
%fprintf('%s \n', [directory_spherical_location, filename_spherical_location]); 

% UIWAIT makes GLW_manage_electrodes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_manage_electrodes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in processButton.
function processButton_Callback(hObject, eventdata, handles)
% hObject    handle to processButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=get(handles.filebox,'String');

% checks flags
flag_assign_location = 0;
flag_bio_to_1020 = 0;
flag_1020_to_bio = 0;
if get(handles.checkbox_assign_location,'value') flag_assign_location = 1; end
if get(handles.checkbox_bio_to_1020,'value') flag_bio_to_1020 = 1; end
if get(handles.checkbox_1020_to_bio,'value') flag_1020_to_bio = 1; end

location_letswave = which('letswave');
[directory_letswave, n, e] = fileparts(location_letswave);
directory_spherical_location = [directory_letswave '/resources/electrodes/spherical_locations/'];

%loop through files
for filepos=1:length(inputfiles);
    %load header
    [header,data]=LW_load(inputfiles{filepos});
    %process
    if(flag_assign_location)
        filename = get(handles.electrodesfile, 'UserData');
        disp('*** Assigning channel locations');
        [header] = LW_lookupchannels(header,filename);
    end
    
    if(flag_bio_to_1020 || flag_1020_to_bio)
        disp('*** Switching labels');
        [header, data] = LW_switch_electrodes(header, data, flag_bio_to_1020, flag_1020_to_bio);
    end
    %output filename
    st=[p,filesep, n,'.lw6'];
    %save
    LW_save(st,get(handles.prefixtext),header,data);
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




% --- Executes on button press in checkbox_assign_location.
function checkbox_assign_location_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_assign_location (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_assign_location


% --- Executes on button press in checkbox_build_spline.
function checkbox_build_spline_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_build_spline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_build_spline


% --- Executes on button press in checkbox_bio_to_1020.
function checkbox_bio_to_1020_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_bio_to_1020 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_bio_to_1020


% --- Executes on button press in checkbox_1020_to_bio.
function checkbox_1020_to_bio_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_1020_to_bio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_1020_to_bio


% --- Executes on button press in pushbutton_select_location_file.
function pushbutton_select_location_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_location_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles = get(handles.filebox, 'String');
[p,n,e] = fileparts(inputfiles{1});
filterspec = [p,filesep,'*.*'];
location_letswave = which('letswave');
[directory_letswave, n, e] = fileparts(location_letswave);
directory_spherical_location = [directory_letswave '/resources/electrodes/spherical_locations'];
[filename, pathname] = uigetfile(filterspec, '', directory_spherical_location);
set(handles.electrodesfile, 'String', filename);
set(handles.electrodesfile, 'UserData', [pathname, filename]);
%fprintf('%s \n', [pathname, filename]); 



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in checkbox_assign_spline.
function checkbox_assign_spline_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_assign_spline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_assign_spline


% --- Executes on button press in pushbutton_select_spline_file.
function pushbutton_select_spline_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_spline_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles = get(handles.filebox, 'String');
[p,n,e] = fileparts(inputfiles{1});
filterspec = [p,filesep,'*.*'];
location_letswave = which('letswave');
[directory_letswave, n, e] = fileparts(location_letswave);
directory_spherical_location = [directory_letswave '/resources/electrodes/spherical_locations'];
[filename, pathname] = uigetfile(filterspec, '', directory_spherical_location);
set(handles.splinefile, 'String', filename);
set(handles.splinefile, 'UserData', [pathname, filename]);
%fprintf('%s \n', [pathname, filename]); 


% --- Executes during object creation, after setting all properties.
function electrodesfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to electrodesfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
