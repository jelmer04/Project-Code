function varargout = SerialGUI(varargin)
% SERIALGUI MATLAB code for SerialGUI.fig
%      SERIALGUI, by itself, creates a new SERIALGUI or raises the existing
%      singleton*.
%
%      H = SERIALGUI returns the handle to a new SERIALGUI or the handle to
%      the existing singleton*.
%
%      SERIALGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SERIALGUI.M with the given input arguments.
%
%      SERIALGUI('Property','Value',...) creates a new SERIALGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SerialGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SerialGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text1 to modify the response to help SerialGUI

% Last Modified by GUIDE v2.5 05-Feb-2014 13:58:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SerialGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SerialGUI_OutputFcn, ...
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


% --- Executes just before SerialGUI is made visible.
function SerialGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SerialGUI (see VARARGIN)

% Choose default command line output for SerialGUI
handles.output = hObject;


% Data file
fileName = '27Feb.txt';

% Mac
handles.s = serial('/dev/tty.usbmodemfd131');

% Windows
%handles.s = serial('COM1');

set(handles.s,'BaudRate',38400);    % Set baud rate to 38400

set(handles.s,'Terminator','CR/LF');

find = (instrfind({'Port', 'Status'}, {get(handles.s,'Port'), 'open'}));

if ((size(find) == zeros(1,2)))
    
    disp('Serial port available.');
    
    fopen(handles.s);                   % Open serial port
    
    handles.fileID = fopen(fileName,'a');     % Open file for appending
    
    
    handles.serialAvailable = 1;
else
    handles.serialAvailable = 0;
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SerialGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SerialGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% Clean up
if (handles.serialAvailable == 1)
    fclose(handles.s)
    delete(handles.s)
    clear handles.s
    fclose(handles.fileID);
end

delete(hObject);


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1

t=0;

while (get(hObject,'Value') && (handles.serialAvailable == 1))

    pause(0.05)
    
    
    out = fscanf(handles.s);            % Get a line of data
    
    % Split the data at each comma
    [split, matches] = strsplit(out,', ');
    
    [y, x] = size(matches);
    
    
    if ((x==6) && (y==1))
        
        % Convert the data to numeric form
        gx = str2double(split(1));
        gy = str2double(split(2));
        gz = str2double(split(3));
        
        ax = str2double(split(4));
        ay = str2double(split(5));
        az = str2double(split(6));
        
        
        tOld = t;
        t = str2double(split(7));
        dt = t-tOld;
        
        
        if ((gx~=0)||(gy~=0)||(gz~=0)||(gx~=0)||(gy~=0)||(gz~=0)||(t ~= 0))
            
            fprintf(handles.fileID,out,'\n');    % Save the line in the file
            disp(out)
            
            set(handles.text1,'String',t);
            set(handles.text2,'String',dt);
            
        end
    else
        disp('No data available')
    end

end


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
