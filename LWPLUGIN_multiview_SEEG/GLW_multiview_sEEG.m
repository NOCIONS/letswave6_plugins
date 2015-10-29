function varargout = GLW_multiview_sEEG(varargin)
% GLW_MULTIVIEW_SEEG MATLAB code for GLW_multiview_sEEG.fig
%
% Author : 
% Andr? Mouraux
% Institute of Neurosciences (IONS)
% Universit? catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 5
% See http://nocions.webnode.com/letswave for additional information
%





% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_multiview_sEEG_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_multiview_sEEG_OutputFcn, ...
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






function updategraph(handles);
%tpdata(graphs,plots,x)
%userdata
userdata=get(handles.filebox,'UserData');
userdata2=get(handles.chanbox,'UserData');
header=userdata(1).header;
%figure
figure(userdata2.wavefigure);
%list of selected files
files=get(handles.filebox,'Value');
%list of selected channels
channels=get(handles.chanbox,'Value');
%list of selected epochs
epochs=get(handles.epochbox,'Value');
%index,y,z,dy,dz
index=get(handles.indexpopup,'Value');
ypos=str2num(get(handles.yedit,'String'));
zpos=str2num(get(handles.zedit,'String'));
%fetch selections
files=get(handles.filebox,'Value');
epochs=get(handles.epochbox,'Value');
channels=get(handles.chanbox,'Value');
%filestring,epochstring,chanstring (used to display legends)
filestring=get(handles.filebox,'String');
epochstring=get(handles.epochbox,'String');
chanstring=get(handles.chanbox,'String');
%fetch legend options
display_legend_filename=strcmpi(get(handles.menu_legend_filename,'Checked'),'on');
display_legend_epoch=strcmpi(get(handles.menu_legend_epoch,'Checked'),'on');
display_legend_channel=strcmpi(get(handles.menu_legend_channel,'Checked'),'on');
%fetch plot options
display_waves=1;
if strcmpi(get(handles.menu_wave_plot,'Checked'),'on');
    display_waves=1;
end;
if strcmpi(get(handles.menu_wave_stem,'Checked'),'on');
    display_waves=2;
end;
if strcmpi(get(handles.menu_wave_stair,'Checked'),'on');
    display_waves=3;
end;
if strcmpi(get(handles.menu_reverse_yaxis,'Checked'),'on');
    display_reverse_y=1;
else
    display_reverse_y=0;
end;
%fetch data (tpdata(files,epochs,channels))
% (and generate legendindex)
legendindex=zeros(length(files),length(epochs),length(channels),3);
datasizemax=userdata(1).header.datasize(6);
for filepos=1:length(files);
    if userdata(filepos).header.datasize(6)>datasizemax;
        datasizemax=userdata(filepos).header.datasize(6);
    end;
end;
tpdata=zeros(length(files),length(epochs),length(channels),datasizemax);
for filepos=1:length(files);
    header=userdata(files(filepos)).header;
    %dy,dz
    dy=fix((ypos-header.ystart)/header.ystep)+1; %$
    dz=fix((zpos-header.zstart)/header.zstep)+1; %$
    %tpx
    tp=1:1:header.datasize(6); %$
    tp=((tp-1)*header.xstep)+header.xstart; %$  
    for epochpos=1:length(epochs);
        for chanpos=1:length(channels);
            legendindex(filepos,epochpos,chanpos,:)=[files(filepos),epochs(epochpos),channels(chanpos)];
            tpdata(filepos,epochpos,chanpos,1:header.datasize(6))=squeeze(userdata(files(filepos)).data(epochs(epochpos),channels(chanpos),index,dz,dy,:));
            if isreal(tpdata);
            else
                tpdata=abs(tpdata);
            end;
            tpx(filepos,epochpos,chanpos).data=tp;
        end;
    end;
end;

%permute dimensions (tpdata(graphrow,graphcol,wave)
tpdata=permute(tpdata,[get(handles.graphrowpopup,'Value'),get(handles.graphcolpopup,'Value'),get(handles.graphwavepopup,'Value'),4]);
legendindex=permute(legendindex,[get(handles.graphrowpopup,'Value'),get(handles.graphcolpopup,'Value'),get(handles.graphwavepopup,'Value'),4]);
tpx=permute(tpx,[get(handles.graphrowpopup,'Value'),get(handles.graphcolpopup,'Value'),get(handles.graphwavepopup,'Value')]);

%update axis edits if set to Auto
if get(handles.yautochk,'Value')==1;
    ymax=max(tpdata(:));
    ymin=min(tpdata(:));
    ymax=ymax+((ymax-ymin)*0.1);
    ymin=ymin-((ymax-ymin)*0.1);
    set(handles.yminedit,'String',num2str(ymin));
    set(handles.ymaxedit,'String',num2str(ymax));
end;
if get(handles.xautochk,'Value')==1;
    set(handles.xminedit,'String',num2str(tpx(1,1,1).data(1)));
    set(handles.xmaxedit,'String',num2str(tpx(1,1,1).data(length(tpx(1,1,1).data))));
end;
%numgraphrows,numgraphcols and numwaves
numgraphrows=size(tpdata,1);
numgraphcols=size(tpdata,2);
numwaves=size(tpdata,3);
%varycolor
lcolors=varycolor(numwaves);
%plot tpdata
for graphcolpos=1:numgraphcols;
    for graphrowpos=1:numgraphrows;
        graphpos=graphcolpos+((graphrowpos-1)*numgraphcols);
        currentaxis(graphrowpos,graphcolpos)=subaxis(numgraphrows,numgraphcols,graphpos,'MarginLeft',0.06,'MarginRight',0.02,'MarginTop',0.04,'MarginBottom',0.08,'SpacingHoriz',0.03,'SpacingVert',0.03);
        hold off;
        legendstring={};
        for wavepos=1:numwaves;
            if display_waves==1;
                plot(tpx(graphrowpos,graphcolpos,wavepos).data,squeeze(tpdata(graphrowpos,graphcolpos,wavepos,1:length(tpx(graphrowpos,graphcolpos,wavepos).data))),'Color',lcolors(wavepos,[1,2,3]));
            end;
            if display_waves==2;
                stem(tpx(graphrowpos,graphcolpos,wavepos).data,squeeze(tpdata(graphrowpos,graphcolpos,wavepos,1:length(tpx(graphrowpos,graphcolpos,wavepos).data))),'Color',lcolors(wavepos,[1,2,3]));
            end;
            if display_waves==3;
                stairs(tpx(graphrowpos,graphcolpos,wavepos).data,squeeze(tpdata(graphrowpos,graphcolpos,wavepos,1:length(tpx(graphrowpos,graphcolpos,wavepos).data))),'Color',lcolors(wavepos,[1,2,3]));
            end;
            hold on;
            st=[];
            if display_legend_filename==1;
                st=filestring{legendindex(graphrowpos,graphcolpos,wavepos,1)};
            end;
            if display_legend_epoch==1;
                st=[st ' [' epochstring{legendindex(graphrowpos,graphcolpos,wavepos,2)} ']'];
            end;
            if display_legend_channel==1;
                st=[st ' [' chanstring{legendindex(graphrowpos,graphcolpos,wavepos,3)} ']'];
            end;
            st(findstr(st,'_'))=' ';
            legendstring{wavepos}=st;
        end;
        %legend
        if max([display_legend_filename display_legend_epoch display_legend_channel])==1;
            legend(legendstring);
        end;
        %xaxis
        xmin=str2num(get(handles.xminedit,'String'));
        xmax=str2num(get(handles.xmaxedit,'String'));
        if xmin>xmax;
            xtp=xmin;
            xmin=xmax;
            xmax=xtp;
        end;     
        if xmin==xmax;
            xmin=-1;
            xmax=1;
        end;
        set(currentaxis(graphrowpos,graphcolpos),'XLim',[xmin xmax]);
        %yaxis
        ymin=str2num(get(handles.yminedit,'String'));
        ymax=str2num(get(handles.ymaxedit,'String'));
        if ymin>ymax;
            ytp=ymin;
            ymin=ymax;
            ymax=ytp;
        end;
        if ymin==ymax;
            ymin=-1;
            ymax=1;
        end;
        set(currentaxis(graphrowpos,graphcolpos),'YLim',[ymin ymax]);
        if display_reverse_y==0;
            set(currentaxis(graphrowpos,graphcolpos),'YDir','normal');
        else
            set(currentaxis(graphrowpos,graphcolpos),'YDir','reverse');
        end;
    end;
end;
%update userdata
userdata2.currentaxis=currentaxis;
set(handles.chanbox,'UserData',userdata2);
%update info for figure
set(userdata2.wavefigure_handles.xtext,'UserData',handles);
%cursors
%userdata=get(handles.chanbox,'UserData');
%userdata.cursor1=str2num(get(handles.int1edit,'String'));
%userdata.cursor2=str2num(get(handles.int2edit,'String'));
%set(handles.chanbox,'UserData',userdata);






% --- Executes just before GLW_multiview_sEEG is made visible.
function GLW_multiview_sEEG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_multiview_sEEG (see VARARGIN)
% Choose default command line output for GLW_multiview_sEEG
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%filebox
st=varargin{2};
set(handles.filebox,'String',st);
st=get(handles.filebox,'String');
for filepos=1:length(st);
    [p,n,e]=fileparts(st{filepos});
    inputfiles{filepos}=[n,e];
end;
set(handles.filebox,'String',inputfiles);
%inputdir
set(handles.inputdir,'String',p);
%UserData
for filepos=1:length(inputfiles);
    %load
    [userdata(filepos).header,userdata(filepos).data]=LW_load(inputfiles{filepos});
end;
header=userdata(1).header;
%check if channel locations can be used to plot scalp maps
chanok=0;
for chanpos=1:length(header.chanlocs);
    if header.chanlocs(chanpos).topo_enabled==1;
        chanok=1;
    end;
end;
%     if chanok==0;
%         set(handles.scalppopup,'Enable','off');
%         set(handles.MRI_view_button,'Enable','off');
%         set(handles.headplotbutton,'Enable','off');
%     end;
%create figure
[userdata2.wavefigure userdata2.wavefigure_handles]=GLW_multiview_figure;
userdata2.mother_handles=handles;
set(gcf,'MenuBar','none');
set(gcf,'ToolBar','none');
%assign userdata
set(handles.filebox,'UserData',userdata);
set(handles.chanbox,'UserData',userdata2);
%set filepos
set(handles.filebox,'Value',1);
%set chanbox
for chanpos=1:header.datasize(2);
    chanstring{chanpos}=header.chanlocs(chanpos).labels;
end;
set(handles.chanbox,'String',chanstring);
set(handles.chanbox,'Value',1);
%set epochbox
for epochpos=1:header.datasize(1);
    epochstring{epochpos}=num2str(epochpos);
end;
set(handles.epochbox,'String',epochstring);
set(handles.epochbox,'Value',1);
%set indexpopup
if isfield(header,'indexlabels');
    for indexpos=1:header.datasize(3);
        indexstring{indexpos}=header.indexlabels{indexpos};
    end;
else
    for indexpos=1:header.datasize(3);
        indexstring{indexpos}=num2str(indexpos);
    end;
end;
set(handles.indexpopup,'String',indexstring);
set(handles.indexpopup,'Value',1);
if length(indexstring)>1;
    set(handles.indexpopup,'Visible','on');
end;
%set yedit and zedit
set(handles.yedit,'String',num2str(header.ystart));
set(handles.zedit,'String',num2str(header.zstart));

%displaydata
if isfield(header,'displaydata');
    disp('displaydata was found');
    displaydata=header.displaydata;
    set(handles.yminedit,'String',displaydata.ymin);
    set(handles.ymaxedit,'String',displaydata.ymax);
    set(handles.yautochk,'Value',displaydata.yauto);
    set(handles.xminedit,'String',displaydata.xmin);
    set(handles.xmaxedit,'String',displaydata.xmax);
    set(handles.xautochk,'Value',displaydata.xauto);
end;


%load display settings
load('multiview_settings.mat');
set(handles.menu_wave_plot,'Checked',multiview_settings.menu_wave_plot);
set(handles.menu_wave_stem,'Checked',multiview_settings.menu_wave_stem);
set(handles.menu_wave_stair,'Checked',multiview_settings.menu_wave_stair);
set(handles.menu_legend_filename,'Checked',multiview_settings.menu_legend_filename);
set(handles.menu_legend_epoch,'Checked',multiview_settings.menu_legend_epoch);
set(handles.menu_legend_channel,'Checked',multiview_settings.menu_legend_channel);
set(handles.menu_reverse_yaxis,'Checked',multiview_settings.menu_reverse_yaxis);

%update graph
updategraph(handles);
figure(handles.figure);




% --- Outputs from this function are returned to the command line.
function varargout = GLW_multiview_sEEG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure




% --- Executes during object creation, after setting all properties.
function figure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);



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


% --- Executes on selection change in epochbox.
function epochbox_Callback(hObject, eventdata, handles)
% hObject    handle to epochbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function epochbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chanbox.
function chanbox_Callback(hObject, eventdata, handles)
% hObject    handle to chanbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function chanbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chanbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in graphrowpopup.
function graphrowpopup_Callback(hObject, eventdata, handles)
% hObject    handle to graphrowpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graphrowpopup,'Value');
sel2=get(handles.graphcolpopup,'Value');
sel3=get(handles.graphwavepopup,'Value');
tp=[1,2,3];
tp(find(tp==sel1))=[];
tp(find(tp==sel2))=[];
tp(find(tp==sel3))=[];
if isempty(tp);
else
    if sel2==sel1;
        sel2=tp(1);
    end;
    if sel3==sel1;
        sel3=tp(1);
    end;
end;
set(handles.graphrowpopup,'Value',sel1);
set(handles.graphcolpopup,'Value',sel2);
set(handles.graphwavepopup,'Value',sel3);
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function graphrowpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graphrowpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in graphwavepopup.
function graphwavepopup_Callback(hObject, eventdata, handles)
% hObject    handle to graphwavepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graphrowpopup,'Value');
sel2=get(handles.graphcolpopup,'Value');
sel3=get(handles.graphwavepopup,'Value');
tp=[1,2,3];
tp(find(tp==sel1))=[];
tp(find(tp==sel2))=[];
tp(find(tp==sel3))=[];
if isempty(tp);
else
    if sel1==sel3;
        sel1=tp(1);
    end;
    if sel2==sel3;
        sel2=tp(1);
    end;
end;
set(handles.graphrowpopup,'Value',sel1);
set(handles.graphcolpopup,'Value',sel2);
set(handles.graphwavepopup,'Value',sel3);
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function graphwavepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graphwavepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in indexpopup.
function indexpopup_Callback(hObject, eventdata, handles)
% hObject    handle to indexpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function indexpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to indexpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function yedit_Callback(hObject, eventdata, handles)
% hObject    handle to yedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function yedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zedit_Callback(hObject, eventdata, handles)
% hObject    handle to zedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function zedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in graphcolpopup.
function graphcolpopup_Callback(hObject, eventdata, handles)
% hObject    handle to graphcolpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graphrowpopup,'Value');
sel2=get(handles.graphcolpopup,'Value');
sel3=get(handles.graphwavepopup,'Value');
tp=[1,2,3];
tp(find(tp==sel1))=[];
tp(find(tp==sel2))=[];
tp(find(tp==sel3))=[];
if isempty(tp);
else
    if sel1==sel2;
        sel1=tp(1);
    end;
    if sel3==sel2;
        sel3=tp(1);
    end;
end;
set(handles.graphrowpopup,'Value',sel1);
set(handles.graphcolpopup,'Value',sel2);
set(handles.graphwavepopup,'Value',sel3);
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function graphcolpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graphcolpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in yautochk.
function yautochk_Callback(hObject, eventdata, handles)
% hObject    handle to yautochk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);




% --- Executes on button press in yminedit.
function yminedit_Callback(hObject, eventdata, handles)
% hObject    handle to yminedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.yautochk,'Value',0);
updategraph(handles);
figure(handles.figure);





% --- Executes during object creation, after setting all properties.
function yminedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yminedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to yminedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yminedit as text
%        str2double(get(hObject,'String')) returns contents of yminedit as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yminedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymaxedit_Callback(hObject, eventdata, handles)
% hObject    handle to ymaxedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.yautochk,'Value',0);
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function ymaxedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymaxedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xautochk.
function xautochk_Callback(hObject, eventdata, handles)
% hObject    handle to xautochk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);




function xmaxedit_Callback(hObject, eventdata, handles)
% hObject    handle to xmaxedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.xautochk,'Value',0);
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function xmaxedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xmaxedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xminedit_Callback(hObject, eventdata, handles)
% hObject    handle to xminedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.xautochk,'Value',0);
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function xminedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xminedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in ydirchk.
function ydirchk_Callback(hObject, eventdata, handles)
% hObject    handle to ydirchk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updategraph(handles);
figure(handles.figure);



% --- Executes on mouse motion over figure - except title and menu.
function figure_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on selection change in scalppopup.
function scalppopup_Callback(hObject, eventdata, handles)
% hObject    handle to scalppopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function scalppopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scalppopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%userdata
userdata=get(handles.filebox,'UserData');
header=userdata(1).header;
%set colnames
colnames{1}='file';
colnames{2}='epoch';
colnames{3}='channel';
colnames{4}='min(x)';
colnames{5}='min(y)';
colnames{6}='max(x)';
colnames{7}='max(y)';
colnames{8}='mean(x)';
colnames{9}='std(y)';
%set tdata
%get list of selected files
files=get(handles.filebox,'Value');
%get list of selected channels
channels=get(handles.chanbox,'Value');
%get list of selected epochs
epochs=get(handles.epochbox,'Value');
%get index
index=get(handles.indexpopup,'Value');
%get y and z position
ypos=str2num(get(handles.yedit,'String'));
zpos=str2num(get(handles.zedit,'String'));
%userdata2
userdata2=get(handles.chanbox,'UserData');
%cursor1 and cursor2
cursor1=userdata2.cursor1;
cursor2=userdata2.cursor2;
disp(['cursor1 : ' num2str(cursor1) ' cursor2 : ' num2str(cursor2)]);
%loop through selected files, epochs and channels
filestring=get(handles.filebox,'String');
epochstring=get(handles.epochbox,'String');
channelstring=get(handles.chanbox,'String');
linepos=1;
for filepos=1:length(files);
    %header
    header=userdata(filepos).header;
    %dy,dz
    dy=((ypos-header.ystart)/header.ystep)+1;
    dz=((zpos-header.zstart)/header.zstep)+1;
    %dcursor (bin positions of cursor1 and cursor2)
    dcursor1=round(((cursor1-header.xstart)/header.xstep)+1);
    dcursor2=round(((cursor2-header.xstart)/header.xstep)+1);
    if dcursor1>dcursor2
        dcursortp=dcursor1;
        dcursor1=dcursor2;
        dcursor2=dcursortp;
    end;
    %check limits
    if dcursor1<1;
        dcursor1=1;
    end;
    if dcursor1>header.datasize(6);
        dcursor1=header.datasize(6);
    end;
    if dcursor2<1;
        dcursor2=1;
    end;
    if dcursor2>header.datasize(6);
        dcursor2=header.datasize(6);
    end;
    disp(['dcursor1 : ' num2str(dcursor1) ' dcursor2 : ' num2str(dcursor2)]);
    for epochpos=1:length(epochs);
        for channelpos=1:length(channels);
            %col1 = file name
            tdata{linepos,1}=filestring{files(filepos)};
            %col1 = epoch name
            tdata{linepos,2}=epochstring{epochs(epochpos)};
            %col2 = channel name
            tdata{linepos,3}=channelstring{channels(channelpos)};
            %fetchdata (min and max)
            tp=squeeze(userdata(files(filepos)).data(epochs(epochpos),channels(channelpos),index,dz,dy,dcursor1:dcursor2));
            [maxy,maxi]=max(tp);
            [miny,mini]=min(tp);
            maxi=maxi+dcursor1-1;
            mini=mini+dcursor1-1;
            maxx=((maxi-1)*header.xstep)+header.xstart;
            minx=((mini-1)*header.xstep)+header.xstart;
            meany=mean(tp);
            stdy=std(tp);
            tdata{linepos,4}=num2str(minx);
            tdata{linepos,5}=num2str(miny);
            tdata{linepos,6}=num2str(maxx);
            tdata{linepos,7}=num2str(maxy);
            tdata{linepos,8}=num2str(meany);
            tdata{linepos,9}=num2str(stdy);
            linepos=linepos+1;
        end;
    end;
end;
%launch table
GLW_multiview_table(tdata,colnames);


% --- Executes on button press in MRI_view_button.
function MRI_view_button_Callback(hObject, eventdata, handles)
% hObject    handle to MRI_view_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.filebox,'UserData');
header=userdata(1).header;
%set colnames
colnames{1}='file';
colnames{2}='epoch';
colnames{3}='channel';
colnames{4}='min(x)';
colnames{5}='min(y)';
colnames{6}='max(x)';
colnames{7}='max(y)';
colnames{8}='mean(x)';
colnames{9}='std(y)';
%set tdata
%get list of selected files
files=get(handles.filebox,'Value');
%get list of selected channels
channels=get(handles.chanbox,'Value');
%get list of selected epochs
epochs=get(handles.epochbox,'Value');
%get index
index=get(handles.indexpopup,'Value');
%get y and z position
ypos=str2num(get(handles.yedit,'String'));
zpos=str2num(get(handles.zedit,'String'));
%userdata2
userdata2=get(handles.chanbox,'UserData');
%cursor1 and cursor2
cursor1=userdata2.cursor1;
cursor2=userdata2.cursor2;
disp(['cursor1 : ' num2str(cursor1) ' cursor2 : ' num2str(cursor2)]);
%loop through selected files, epochs and channels
filestring=get(handles.filebox,'String');
epochstring=get(handles.epochbox,'String');
channelstring=get(handles.chanbox,'String');
linepos=1;
for filepos=1:length(files);
    %header
    header=userdata(filepos).header;
    %dy,dz
    dy=((ypos-header.ystart)/header.ystep)+1;
    dz=((zpos-header.zstart)/header.zstep)+1;
    %dcursor (bin positions of cursor1 and cursor2)
    dcursor1=round(((cursor1-header.xstart)/header.xstep)+1);
    dcursor2=round(((cursor2-header.xstart)/header.xstep)+1);
    if dcursor1>dcursor2
        dcursortp=dcursor1;
        dcursor1=dcursor2;
        dcursor2=dcursortp;
    end;
    %check limits
    if dcursor1<1;
        dcursor1=1;
    end;
    if dcursor1>header.datasize(6);
        dcursor1=header.datasize(6);
    end;
    if dcursor2<1;
        dcursor2=1;
    end;
    if dcursor2>header.datasize(6);
        dcursor2=header.datasize(6);
    end;
    disp(['dcursor1 : ' num2str(dcursor1) ' dcursor2 : ' num2str(dcursor2)]);
    for epochpos=1:length(epochs);
        for channelpos=1:length(channels);
            %col1 = file name
            tdata{linepos,1}=filestring{files(filepos)};
            %col1 = epoch name
            tdata{linepos,2}=epochstring{epochs(epochpos)};
            %col2 = channel name
            tdata{linepos,3}=channelstring{channels(channelpos)};
            %fetchdata (min and max)
            tp=squeeze(userdata(files(filepos)).data(epochs(epochpos),channels(channelpos),index,dz,dy,dcursor1:dcursor2));
            [maxy,maxi]=max(tp);
            [miny,mini]=min(tp);
            maxi=maxi+dcursor1-1;
            mini=mini+dcursor1-1;
            maxx=((maxi-1)*header.xstep)+header.xstart;
            minx=((mini-1)*header.xstep)+header.xstart;
            meany=mean(tp);
            stdy=std(tp);
            tdata{linepos,4}=num2str(minx);
            tdata{linepos,5}=num2str(miny);
            tdata{linepos,6}=num2str(maxx);
            tdata{linepos,7}=num2str(maxy);
            tdata{linepos,8}=num2str(meany);
            tdata{linepos,9}=num2str(stdy);
            linepos=linepos+1;
        end;
    end;
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% code above is from the function that extracts data to plot in a table.
% Next section is specific to CTMRI_explorer.
%
% Retrieve data from cell array (we used the function that creates a table
% in letswave).
% In case multiple files were selected. Currently not supported.
nbFiles = length(files); 
if nbFiles > 1;
    disp(' ');
    disp('Multiple files selected -> only showing the first file!');
    disp(' ');
end

nbData = size(tdata,1);
elec_data = cellfun(@str2num,tdata(1:nbData/nbFiles,7));
elec_label_seeg = tdata(1:nbData/nbFiles,3);%channels

%We need to do something different if the gui is already open , so lets
%check if it is the case.
% check all open figures
allFigH = findobj('type','figure');
isopen = 0;
for ii = 1:numel(allFigH);
    if findstr('CTMRI_explorer - ',get(allFigH(ii),'Name')) == 1;
        isopen = 1;
        break;
    end
end

if ~isopen; %CTMRI gui not open
    
    %find the location of CTMRI_explorer in the pluggin folder.
    addedCTMRIpath = 0;
    if ~exist('CTMRI_explorer.m','file');
        plugDir = mfilename('fullpath');
        [plugDir,n,e] = fileparts(plugDir);        
        if exist(fullfile(plugDir,'CTRMI_explorer'),'dir');
            addpath(genpath(fullfile(plugDir,'CTRMI_explorer')));
            addedCTMRIpath = 1;
        else
            errordlg('Cannot locate the CTMRI_explorer program in the search path or plugin directory!');
            return;
        end        
    end
    
    %start CTMRI gui, get its handle    
    CTMRI_explorer;
    
    %rm path if we added just for the purpose of loading the GUI.
    if addedCTMRIpath;
        rmpath(genpath(fullfile(plugDir,'CTRMI_explorer')));
    end
    hCTMRI_explorer = getappdata(0,'hCTMRI_explorer');
    handlesCT = getappdata(hCTMRI_explorer,'handles');
    
    % get function handles
    fhload_MRI_button = getappdata(hCTMRI_explorer,'fhload_MRI_button');
    fhLoad_elec_coord = getappdata(hCTMRI_explorer,'fhLoad_elec_coord'); 
    
    % evaluate functions:
    %1. load MRI    
    feval(fhload_MRI_button,0,0,handlesCT);    
    %2. load electrode coordinates (also updates plot)
    feval(fhLoad_elec_coord,0,0,handlesCT);   
else %gui is already open
    hCTMRI_explorer = getappdata(0,'hCTMRI_explorer');
    handlesCT = getappdata(hCTMRI_explorer,'handles');
end
 
%function handles from CTMRI_explorer
 fhupdate_elec_color = getappdata(hCTMRI_explorer,'fhupdate_elec_color');
 fhupdate_plot = getappdata(hCTMRI_explorer,'fhupdate_plot');
 fhupdate_crosshair = getappdata(hCTMRI_explorer,'fhupdate_crosshair');
 fmatchElecLabels =  getappdata(hCTMRI_explorer,'fmatchElecLabels');
 %store data and electrode labels
 setappdata(hCTMRI_explorer,'session_elec_data',elec_data);
 setappdata(hCTMRI_explorer,'session_elec_label_seeg',elec_label_seeg);
  
 %run a function to only keep electrode matching across seeg_labels and 3D
 %coordinates lables in CTMRI_explorer.
 feval(fmatchElecLabels); 
 
 %updata plots
 [pathstr, name, ext] = fileparts(tdata{1,1});
 set(handlesCT.text_load_data,'string',name);
 feval(fhupdate_elec_color,0,handlesCT);
 feval(fhupdate_plot,handlesCT);
 feval(fhupdate_crosshair,handlesCT);

%%%%%%%%%%%%%%%%%%%%%%%%%%



% --- Executes on button press in headplotbutton.
function headplotbutton_Callback(hObject, eventdata, handles)
% hObject    handle to headplotbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set headplot (LW_headplot(header,data,epoch,index,x,y,z,varargin))
%set headplot (LW_headplot(header,data,epoch,index,x,y,z,varargin)
%userdata
userdata=get(handles.filebox,'UserData');
userdata2=get(handles.chanbox,'UserData');
header=userdata(1).header;
%get list of selected files
files=get(handles.filebox,'Value');
%get list of selected epochs
epochs=get(handles.epochbox,'Value');
%get list of selected channels
channels=get(handles.chanbox,'Value');
%get index
index=get(handles.indexpopup,'Value');
%get y and z position
ypos=str2num(get(handles.yedit,'String'));
zpos=str2num(get(handles.zedit,'String'));
dy=((ypos-header.ystart)/header.ystep)+1;
dz=((zpos-header.zstart)/header.zstep)+1;
%cursor1, cursor2
cursor1=userdata2.cursor1;
cursor2=userdata2.cursor2;
%dcursor (bin positions of cursor1 and cursor2)
dcursor1=round((cursor1-header.xstart)/header.xstep)+1;
dcursor2=round((cursor2-header.xstart)/header.xstep)+1;
if dcursor1>dcursor2
    dcursortp=dcursor1;
    dcursor1=dcursor2;
    dcursor2=dcursortp;
end;
%filestring,epochstring;
filestring=get(handles.filebox,'String');
epochstring=get(handles.epochbox,'String');
%ymin,ymax
ycmin=str2num(get(handles.yminedit,'String'))
ycmax=str2num(get(handles.ymaxedit,'String'))
%launch figure;
topofigure=figure;
set(topofigure,'ToolBar','none');
%loop through selected files (will plot one scalp map per selected file, in separate columns)
for filepos=1:length(files);
    header=userdata(files(filepos)).header;
    %loop through selected epochs (will plot one scalp map per selected epoch, in separate rows)
    for epochpos=1:length(epochs);
        %find maximum and minimum
        tp=squeeze(userdata(files(filepos)).data(epochs(epochpos),channels(1),index,dz,dy,dcursor1:dcursor2));
        [all_maxy,all_maxi]=max(tp);
        [all_miny,all_mini]=min(tp);
        if length(channels)>1
            for channelpos=2:length(channels);
                tp=squeeze(userdata(files(filepos)).data(epochs(epochpos),channels(channelpos),index,dz,dy,dcursor1:dcursor2));
                [maxy,maxi]=max(tp);
                [miny,mini]=min(tp);
                if maxy>all_maxy;
                    all_maxy=maxy;
                    all_maxi=maxi;
                end;
                if miny<all_miny;
                    all_miny=miny;
                    all_mini=mini;
                end;
            end;
        end;
        all_maxi=all_maxi+dcursor1-1;
        all_mini=all_mini+dcursor1-1;
        all_maxx=((all_maxi-1)*header.xstep)+header.xstart;
        all_minx=((all_mini-1)*header.xstep)+header.xstart;
        %graphpos
        graphpos=filepos+((epochpos-1)*length(files));
        %subplot
        tpaxis=subaxis(length(epochs),length(files),graphpos,'MarginLeft',0.01,'MarginRight',0.01,'MarginTop',0.05,'MarginBottom',0.01);
        if get(handles.scalppopup,'Value')==1
            dx=all_maxi;
        else
            dx=all_mini;
        end;
        tpaxis=LW_headplot(header,userdata(files(filepos)).data,epochs(epochpos),index,dx,dy,dz,'maplimits',[ycmin ycmax]);
        [p,n,e]=fileparts(filestring{files(filepos)});
        st=[n,' - E:',epochstring{epochs(epochpos)}];
        st(findstr(st,'_'))=' ';
        title(gca,st);
        set(gca,'View',[0 90]);
        headplotaxis(filepos,epochpos)=gca;
    end;
end;
userdata2=get(handles.chanbox,'UserData');
userdata2.tpaxis=headplotaxis;
set(handles.chanbox,'UserData',userdata2);


% --- Executes on slider movement.
function azimuthslider_Callback(hObject, eventdata, handles)
% hObject    handle to azimuthslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%userdata2
userdata2=get(handles.chanbox,'UserData');
azimuth=get(handles.azimuthslider,'Value');
headplotaxis=userdata2.tpaxis;
for filepos=1:size(headplotaxis,1);
    for epochpos=1:size(headplotaxis,2);
        view=get(headplotaxis(filepos,epochpos),'View');
        view(1)=azimuth;
        set(headplotaxis(filepos,epochpos),'View',view);
    end;
end;




% --- Executes during object creation, after setting all properties.
function azimuthslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to azimuthslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over azimuthslider.
function azimuthslider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to azimuthslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on slider movement.
function elevationslider_Callback(hObject, eventdata, handles)
% hObject    handle to elevationslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata2=get(handles.chanbox,'UserData');
elevation=get(handles.elevationslider,'Value');
headplotaxis=userdata2.tpaxis;
for filepos=1:size(headplotaxis,1);
    for epochpos=1:size(headplotaxis,2);
        view=get(headplotaxis(filepos,epochpos),'View');
        view(2)=elevation;
        set(headplotaxis(filepos,epochpos),'View',view);
    end;
end;




% --- Executes during object creation, after setting all properties.
function elevationslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elevationslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% --- Executes when user attempts to close figure.
function figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save display data
try
    displaydata.ymin=get(handles.yminedit,'String');
    displaydata.ymax=get(handles.ymaxedit,'String');
    displaydata.yauto=get(handles.yautochk,'Value');
    displaydata.xmin=get(handles.xminedit,'String');
    displaydata.xmax=get(handles.xmaxedit,'String');
    displaydata.xauto=get(handles.xautochk,'Value');
    inputfiles=get(handles.filebox,'String');
    for filepos=1:length(inputfiles);
        %load header
        [p,n,e]=fileparts(inputfiles{filepos});
        st=[get(handles.inputdir,'String'),filesep,n,'.lw5'];
        load(st,'-MAT');
        header.displaydata=displaydata;
        %save header
        save(st,'header','-MAT');
    end;
end;
%close gracefully
userdata2=get(handles.chanbox,'UserData');
delete(userdata2.wavefigure);
delete(hObject);





function int1edit_Callback(hObject, eventdata, handles)
% hObject    handle to int1edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.chanbox,'UserData');
userdata.cursor1=str2num(get(handles.int1edit,'String'));
set(handles.chanbox,'UserData',userdata);
updategraph(handles);
figure(handles.figure);





% --- Executes during object creation, after setting all properties.
function int1edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int1edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function int2edit_Callback(hObject, eventdata, handles)
% hObject    handle to int2edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.chanbox,'UserData');
userdata.cursor2=str2num(get(handles.int2edit,'String'));
set(handles.chanbox,'UserData',userdata);
updategraph(handles);
figure(handles.figure);




% --- Executes during object creation, after setting all properties.
function int2edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to int2edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_legend_filename_Callback(hObject, eventdata, handles)
% hObject    handle to menu_legend_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_legend_filename,'Checked'),'on');
    set(handles.menu_legend_filename,'Checked','off');
else
    set(handles.menu_legend_filename,'Checked','on');
end;    
updategraph(handles);
figure(handles.figure);






% --------------------------------------------------------------------
function menu_legend_epoch_Callback(hObject, eventdata, handles)
% hObject    handle to menu_legend_epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_legend_epoch,'Checked'),'on');
    set(handles.menu_legend_epoch,'Checked','off');
else
    set(handles.menu_legend_epoch,'Checked','on');
end;    
updategraph(handles);
figure(handles.figure);






% --------------------------------------------------------------------
function menu_legend_channel_Callback(hObject, eventdata, handles)
% hObject    handle to menu_legend_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_legend_channel,'Checked'),'on');
    set(handles.menu_legend_channel,'Checked','off');
else
    set(handles.menu_legend_channel,'Checked','on');
end;  
updategraph(handles);
figure(handles.figure);






% --------------------------------------------------------------------
function menu_wave_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_plot,'Checked','on');
set(handles.menu_wave_stem,'Checked','off');
set(handles.menu_wave_stair,'Checked','off');
updategraph(handles);
figure(handles.figure);




% --------------------------------------------------------------------
function menu_wave_stem_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_stem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_plot,'Checked','off');
set(handles.menu_wave_stem,'Checked','on');
set(handles.menu_wave_stair,'Checked','off');
updategraph(handles);
figure(handles.figure);




% --------------------------------------------------------------------
function menu_wave_stair_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_stair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_plot,'Checked','off');
set(handles.menu_wave_stem,'Checked','off');
set(handles.menu_wave_stair,'Checked','on');
updategraph(handles);
figure(handles.figure);


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_reverse_yaxis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reverse_yaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_reverse_yaxis,'Checked'),'on');
    set(handles.menu_reverse_yaxis,'Checked','off');
else
    set(handles.menu_reverse_yaxis,'Checked','on');
end;  
updategraph(handles);
figure(handles.figure);


% --------------------------------------------------------------------
function menu_default_Callback(hObject, eventdata, handles)
% hObject    handle to menu_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%waveforms
multiview_settings.menu_wave_plot=get(handles.menu_wave_plot,'Checked');
multiview_settings.menu_wave_stem=get(handles.menu_wave_stem,'Checked');
multiview_settings.menu_wave_stair=get(handles.menu_wave_stair,'Checked');
multiview_settings.menu_legend_filename=get(handles.menu_legend_filename,'Checked');
multiview_settings.menu_legend_epoch=get(handles.menu_legend_epoch,'Checked');
multiview_settings.menu_legend_channel=get(handles.menu_legend_channel,'Checked');
multiview_settings.menu_reverse_yaxis=get(handles.menu_reverse_yaxis,'Checked');
tp=which('letswave.m');
[p,n,e]=fileparts(tp);
localtarget=[p filesep 'settings' filesep 'multiview_settings.mat']
save(localtarget,'multiview_settings');
