function varargout = GLW_plot_TF_lines(varargin)
% GLW_PLOT_TF_LINES M-file for GLW_plot_TF_lines.fig
%      GLW_PLOT_TF_LINES, by itself, creates a new GLW_PLOT_TF_LINES or raises the existing
%      singleton*.
%
%      H = GLW_PLOT_TF_LINES returns the handle to a new GLW_PLOT_TF_LINES or the handle to
%      the existing singleton*.
%
%      GLW_PLOT_TF_LINES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_PLOT_TF_LINES.M with the given input arguments.
%
%      GLW_PLOT_TF_LINES('Property','Value',...) creates a new GLW_PLOT_TF_LINES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_plot_TF_lines_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_plot_TF_lines_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_plot_TF_lines

% Last Modified by GUIDE v2.5 29-Oct-2015 07:14:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_plot_TF_lines_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_plot_TF_lines_OutputFcn, ...
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


% --- Executes just before GLW_plot_TF_lines is made visible.
function GLW_plot_TF_lines_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_plot_TF_lines (see VARARGIN)

% Choose default command line output for GLW_plot_TF_lines
handles.output = hObject;



% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
inputfiles=varargin{2};
set(handles.filebox,'String',inputfiles);

%load header of first file to populate channel labels popup menu
header = LW_load_header(inputfiles{1});
for chanpos=1:header.datasize(2);
    chanstring{chanpos}=header.chanlocs(chanpos).labels;
end;
set(handles.channel_popupmenu,'Value',1);
set(handles.channel_popupmenu,'string',chanstring);
% Also, adapt the proposed frequency range as a function of existing
% frequencies.

freqax = 1:1:header.datasize(5); %$
freqax = ((freqax-1)*header.ystep)+header.ystart;
set(handles.minFrequency_textbox,'string',freqax(1)); 
set(handles.maxFrequency_textbox,'string',freqax(end));

% UIWAIT makes GLW_plot_TF_lines wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_plot_TF_lines_OutputFcn(hObject, eventdata, handles) 
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
    %load header
    [header,data] = LW_load(inputfiles{filepos});

%x-axis:
xax = 1:1:header.datasize(6); %$
xax = ((xax-1)*header.xstep)+header.xstart;

%X-Lim:
Xwin(1) = str2num(get(handles.Xlim_lo_edit,'string'));
Xwin(2) = str2num(get(handles.Xlim_hi_edit,'string'));
XwinInd = round((Xwin - header.xstart) ./ header.xstep +1);
XwinVect = XwinInd(1):XwinInd(2);

%frequency window and indexes.
freqWin = [];
freqWin(1) = str2num(get(handles.minFrequency_textbox,'string')); 
freqWin(2) = str2num(get(handles.maxFrequency_textbox,'string'));
freqWinInd = round((freqWin - header.ystart) ./ header.ystep +1);
freqWinVect = freqWinInd(1) : freqWinInd(2);
freqVect = 1:1:header.datasize(5); %$
freqVect = ((freqVect-1)*header.ystep)+header.ystart;


%subplots organization
if get(handles.radiobutton_plotAverageLine,'value'); %average across frequencies
    NbSessions = 1;
else
NbSessions = length(freqWinVect);
end
subPlotOrg = [];
NcolPlot = ceil(sqrt(NbSessions));
NliPlot = floor(sqrt(NbSessions));
if NcolPlot*NliPlot<NbSessions;
    NliPlot= NliPlot+1;
end
if NbSessions == 3;
    NcolPlot = 3;
    NliPlot = 1;
end

%channel to plot.
channelInd = get(handles.channel_popupmenu,'Value');
channelLabels = get(handles.channel_popupmenu,'String');

%define figure
[p,n,e]= fileparts(inputfiles{filepos});
figName = [n,' - channel: ',channelLabels{channelInd}];
TFfreqLineFig = figure('color',[1 1 1],'name',figName);

if get(handles.radiobutton_plotAverageLine,'value');
    %average over freqWinVect
    hp = stairs(xax(XwinVect),squeeze(mean(data(:,channelInd,:,:,freqWinVect,XwinVect),5)));
    set(hp, 'linewidth', 2);
    
    %set X and Y-scale
    set(gca,'Ylim', ...
        [str2num(get(handles.Ylim_lo_edit,'string'))...
        str2num(get(handles.Ylim_hi_edit,'string'))]);    
    set(gca,'Xlim', ...
        [str2num(get(handles.Xlim_lo_edit,'string'))...
        str2num(get(handles.Xlim_hi_edit,'string'))]); 
    
    
    title(sprintf('Channel: %s - freq avg: %g-%gHz',channelLabels{channelInd},freqWin(1),freqWin(2)));
else
    %plot each frequency line
    for f = 1:length(freqWinVect);
        subplot(NliPlot,NcolPlot,f);
        
        hp = stairs(xax(XwinVect),squeeze(data(:,channelInd,:,:,freqWinVect(f),XwinVect)));
        set(hp, 'linewidth', 1);
        %set X and Y-scale
    set(gca,'Ylim', ...
        [str2num(get(handles.Ylim_lo_edit,'string'))...
        str2num(get(handles.Ylim_hi_edit,'string'))]);    
    set(gca,'Xlim', ...
        [str2num(get(handles.Xlim_lo_edit,'string'))...
        str2num(get(handles.Xlim_hi_edit,'string'))]);        
        
        
        title(sprintf('Channel: %s - freq: %gHz',channelLabels{channelInd},freqVect(f)));
        
    end
    
    %plot as image
   TFfreqLineFigIm = figure('color',[1 1 1],'name',figName);
   imagesc(xax(XwinVect),freqVect(freqWinVect),squeeze(data(:,channelInd,:,:,freqWinVect,XwinVect)),... 
        [str2num(get(handles.Ylim_lo_edit,'string'))...
        str2num(get(handles.Ylim_hi_edit,'string'))]);
    colormap('hot'); colorbar;
    set(gca,'Ydir','normal');
    title(sprintf('Channel: %s',channelLabels{channelInd}));
    set(gca,'Xlim', ...
        [str2num(get(handles.Xlim_lo_edit,'string'))...
        str2num(get(handles.Xlim_hi_edit,'string'))]); 
%     set(gca,'xtick',xax(XwinVect),'xticklabel',xax(XwinVect));
%     set(gca,'ytick',freqWinVect,'yticklabel',freqVect(freqWinVect));
xlabel('FFT frequency (Hz)');
ylabel('TF analysis frequency (Hz)');

end


if get(handles.checkbox_doprint,'Value');
    CCF=TFfreqLineFig;   
    destPath = [pwd, filesep];
    XimPrintsize =str2double(get(handles.printSizeWidth,'String'));
    YimPrintsize =str2double(get(handles.printSizeHeigth,'String'));
    set(CCF,'PaperUnits','centimeters');
    set(CCF,'paperposition',[0 0 XimPrintsize YimPrintsize]);
    resol = str2double(get(handles.printSizeResolution,'String'));
    
    c=clock;
    
    % build save name
   [p,n,e]= fileparts(inputfiles{filepos});
   if get(handles.radiobutton_plotAverageLine,'value');
       figPrintName = sprintf('%s%s_C-%s_freqAvg-%g-%gHz_date_%i-%.2g-%i_%gh%gm%02ds', ...
           destPath,n,channelLabels{channelInd},freqWin(1),freqWin(2),c(3),c(2),c(1),c(4),c(5),round(c(6)));
       eval(sprintf('print(CCF,''-dtiff'',''-r%i'',[figPrintName,''.tiff''])',resol));
   else
       figPrintName = sprintf('%s%s_C-%s_freqIndi-%g-%gHz_date_%i-%.2g-%i_%gh%gm%02ds', ...
           destPath,n,channelLabels{channelInd},freqWin(1),freqWin(2),c(3),c(2),c(1),c(4),c(5),round(c(6)));
        eval(sprintf('print(CCF,''-dtiff'',''-r%i'',[figPrintName,''.tiff''])',resol));
       
       CCF1=TFfreqLineFigIm;
       figPrintNameIm = sprintf('%s%s_C-%s_freqIndiImage-%g-%gHz_date_%i-%.2g-%i_%gh%gm%02ds', ...
           destPath,n,channelLabels{channelInd},freqWin(1),freqWin(2),c(3),c(2),c(1),c(4),c(5),round(c(6)));
       eval(sprintf('print(CCF1,''-dtiff'',''-r%i'',[figPrintNameIm,''.tiff''])',resol));
   end
    
    
end

% LW_save(inputfiles{filepos},get(handles.prefixtext,'String'),header,data);
    
    
    
end

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


% --- Executes on button press in radiobutton_plotEachLine.
function radiobutton_plotEachLine_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_plotEachLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_plotEachLine
set(handles.radiobutton_plotEachLine,'Value',1);
set(handles.radiobutton_plotAverageLine,'Value',0);

% --- Executes on button press in radiobutton_plotAverageLine.
function radiobutton_plotAverageLine_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_plotAverageLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_plotAverageLine
set(handles.radiobutton_plotEachLine,'Value',0);
set(handles.radiobutton_plotAverageLine,'Value',1);


function minFrequency_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to minFrequency_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minFrequency_textbox as text
%        str2double(get(hObject,'String')) returns contents of minFrequency_textbox as a double


% --- Executes during object creation, after setting all properties.
function minFrequency_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minFrequency_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxFrequency_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to maxFrequency_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxFrequency_textbox as text
%        str2double(get(hObject,'String')) returns contents of maxFrequency_textbox as a double


% --- Executes during object creation, after setting all properties.
function maxFrequency_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxFrequency_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xlim_lo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Xlim_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xlim_lo_edit as text
%        str2double(get(hObject,'String')) returns contents of Xlim_lo_edit as a double


% --- Executes during object creation, after setting all properties.
function Xlim_lo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xlim_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xlim_hi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Xlim_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xlim_hi_edit as text
%        str2double(get(hObject,'String')) returns contents of Xlim_hi_edit as a double


% --- Executes during object creation, after setting all properties.
function Xlim_hi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xlim_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ylim_lo_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ylim_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ylim_lo_edit as text
%        str2double(get(hObject,'String')) returns contents of Ylim_lo_edit as a double


% --- Executes during object creation, after setting all properties.
function Ylim_lo_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ylim_lo_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Ylim_hi_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Ylim_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Ylim_hi_edit as text
%        str2double(get(hObject,'String')) returns contents of Ylim_hi_edit as a double


% --- Executes during object creation, after setting all properties.
function Ylim_hi_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Ylim_hi_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_popupmenu.
function channel_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to channel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns channel_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_popupmenu


% --- Executes during object creation, after setting all properties.
function channel_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function printSizeHeigth_Callback(hObject, eventdata, handles)
% hObject    handle to printSizeHeigth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of printSizeHeigth as text
%        str2double(get(hObject,'String')) returns contents of printSizeHeigth as a double


% --- Executes during object creation, after setting all properties.
function printSizeHeigth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to printSizeHeigth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function printSizeWidth_Callback(hObject, eventdata, handles)
% hObject    handle to printSizeWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of printSizeWidth as text
%        str2double(get(hObject,'String')) returns contents of printSizeWidth as a double


% --- Executes during object creation, after setting all properties.
function printSizeWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to printSizeWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function printSizeResolution_Callback(hObject, eventdata, handles)
% hObject    handle to printSizeResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of printSizeResolution as text
%        str2double(get(hObject,'String')) returns contents of printSizeResolution as a double


% --- Executes during object creation, after setting all properties.
function printSizeResolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to printSizeResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_doprint.
function checkbox_doprint_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_doprint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_doprint
