%   /Users/Jon/Documents/Lecture Notes/Third Year/Project/Code/Project Code/MATLAB

% Data file
fileName = 'data.txt';

% Mac
s = serial('/dev/tty.usbmodemfd131');

% Windows
%s = serial('COM1');

set(s,'BaudRate',38400);    % Set baud rate to 38400

set(s,'Terminator','CR/LF');

find = (instrfind({'Port', 'Status'}, {get(s,'Port'), 'open'}));

if ((size(find) == zeros(1,2)))
    
    disp('Serial port available.');
    
    fopen(s);                   % Open serial port
    
    fileID = fopen(fileName,'a');     % Open file for appending
    
    out = fscanf(s);            % Get a line of data
    
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
        
        t = str2double(split(7));
        
        if ((gx~=0)||(gy~=0)||(gz~=0)||(gx~=0)||(gy~=0)||(gz~=0)||(t ~= 0))
            
            fprintf(fileID,out,'\n');    % Save the line in the file
            disp(out)
            
        end
    else
        disp('No data available.')
        disp(out)
    end
    
    % Clean up
    fclose(fileID);
    fclose(s)
else
    disp('Serial port Unavaliable!')
end
%delete(s)
%clear s
