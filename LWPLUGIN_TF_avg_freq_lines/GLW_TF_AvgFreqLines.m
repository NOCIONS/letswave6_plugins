function varargout = GLW_TF_AvgFreqLines(varargin)
% GLW_TF_AVGFREQLINES M-file for GLW_TF_AvgFreqLines.fig
%      GLW_TF_AVGFREQLINES, by itself, creates a new GLW_TF_AVGFREQLINES or raises the existing
%      singleton*.
%
%      H = GLW_TF_AVGFREQLINES returns the handle to a new GLW_TF_AVGFREQLINES or the handle to
%      the existing singleton*.
%
%      GLW_TF_AVGFREQLINES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_TF_AVGFREQLINES.M with the given input arguments.
%
%      GLW_TF_AVGFREQLINES('Property','Value',...) creates a new GLW_TF_AVGFREQLINES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_TF_AvgFreqLines_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_TF_AvgFreqLines_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_TF_AvgFreqLines

% Last Modified by GUIDE v2.5 29-Oct-2015 09:28:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_TF_AvgFreqLines_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_TF_AvgFreqLines_OutputFcn, ...
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


% --- Executes just before GLW_TF_AvgFreqLines is made visible.
function GLW_TF_AvgFreqLines_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_TF_AvgFreqLines (see VARARGIN)

% Choose default command line output for GLW_TF_AvgFreqLines
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
inputfiles=varargin{2};
set(handles.filebox,'String',inputfiles);

%load header of first file to adapt the proposed frequency range as a function of existing
% frequencies.
header = LW_load_header(inputfiles{1});
freqax = 1:1:header.datasize(5);
freqax = ((freqax-1)*header.ystep)+header.ystart;
freqText = sprintf('[%.3f %.3f]',floor(freqax(1)),ceil(freqax(end)));
set(handles.Frequency_textbox,'string',freqText); 

% UIWAIT makes GLW_TF_AvgFreqLines wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_TF_AvgFreqLines_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on button press in process_button.
function process_button_Callback(hObject, eventdata, handles)
% hObject    handle to process_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get filenames to process
inputfiles=get(handles.filebox,'String');


for filepos=1:length(inputfiles);
    
    %load header and data
    [header,data] = LW_load(inputfiles{filepos});
      
    %frequency window and indexes.
    freqWin = eval(sprintf('[%s]',get(handles.Frequency_textbox,'String')));
    
    for F = 1:size(freqWin,1);
        %find array indices for frequencies.
        freqWinInd = round((freqWin(F,:) - header.ystart) ./ header.ystep +1);
        
        %make sure no indices are outside the existing bounds.
        freqWinInd = max(freqWinInd,1);
        freqWinInd = min(freqWinInd,size(data,5));
        
        %build frequency indices vector.
        freqWinVect = freqWinInd(1) : freqWinInd(2);
        
        %WHat is the 'real' frequency window
        freqVect = 1:1:header.datasize(5); %$
        freqVect = ((freqVect-1)*header.ystep)+header.ystart;
        realFreqWin = freqVect(freqWinInd);
        
        outdata = zeros(size(data,1),size(data,2),size(data,3),size(data,4),1,size(data,6));
        outdata = mean(data(:,:,:,:,freqWinVect,:),5);
               
        %deal with output header
        %add history
        outheader = header;
        i=length(outheader.history)+1;
        outheader.history(i).description='GLW_TF_AvgFreqLines';
        outheader.history(i).date=date;
        outheader.datasize = size(outdata);
        outheader.ystart = 0;
        outheader.ystep = 1;
        
        % save files          
        freqWinSaveText = '';
        if get(handles.checkbox_addFreqBandName,'Value')==1;
            freqWinSaveText = sprintf('%.1f-%.1fHz',realFreqWin(1),realFreqWin(2));
        end        
        
        prefixx = sprintf('%s %s',get(handles.prefixtext,'String'),freqWinSaveText);
        
        LW_save(inputfiles{filepos},prefixx,outheader,outdata);
        
    end
    
    
end
disp('*** Finished');

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


function Frequency_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to Frequency_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Frequency_textbox as text
%        str2double(get(hObject,'String')) returns contents of Frequency_textbox as a double


% --- Executes during object creation, after setting all properties.
function Frequency_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frequency_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefixtext as text
%        str2double(get(hObject,'String')) returns contents of prefixtext as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_addFreqBandName.
function checkbox_addFreqBandName_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_addFreqBandName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_addFreqBandName
