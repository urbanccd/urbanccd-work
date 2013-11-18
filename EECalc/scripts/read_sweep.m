function [ Mainpraw,Distraw] = read_readsw(file1 )
%read_inputs reads EECalc inputs from a comma delimited text file
% 

% V0.6 03-Jan-2013 RTM changed version number to match other updated files

% V0.5 20-Dec-2012 RTM
% Switched from reading the CSV file directly to using a csv file format
% the CSV can be generated from eecalcxls2csv or direct export from excel
%
% The move away is to make it easier to work with Octave instead of MATLAB
% and to ease conversion to C++ or some other language

% V0.4 12-Dec-2012 RTM  updated to work with the most recent version of the
% spreadsheet that changed the order/location of some of the inputs,
% especially geometry

tic();

if nargin==0
    %select the file with a gui
    [filename,pathname]=uigetfile('*.csv;*.txt','Select Input Text File to Open');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled script run')
        otherwise
            file1=[pathname,filename]; 
    end % switch filename

end


fid=fopen(file1,'r');
printf('opened %10.5f\n',toc());

if fid==-1
     error(sprintf('File %s not found',file1))  % if fid==-1, file not found  so terminate with an error message
end


%% parse the text file 
N=1;
while ~feof(fid)
    Inline=fgetl(fid);  % read in the text line by line into a single string array
    inarray=strread(Inline,'%s','delimiter',',');  % break the string into a cell array of strings

    % add the extracted cell array as the next row of the Inraw array making
    % sure to transpose it as the output of strread is a column not a row
    if N==1
        Inraw=transpose(inarray);  % Initialize Inraw the first time through the loop
    else
        Inraw=[Inraw;transpose(inarray)]; % add the next line to Inraw
    end
    N=N+1;
end

printf('parsed %10.5f\n',toc());

[N,M]=size(Inraw);
% now go through and convert numbers from strings to floats
% take advantage of the fact that Inarray elements can change type on the
% fly
for I=1:N
    for J=1:M
        temp=str2num(cell2mat(Inraw(I,J))); % convert string cell to matrix string to a number
        if ~isempty(temp)  % if temp is not empty, we have a number
            Inraw(I,J)={temp};  % convert number to cell and then save as a number cell
#DB         printf('converted I=%d J=%d\n', I, J);
        end
    end
end

printf('converted %10.5f\n',toc());

Names=Inraw(:,1);  % extract the 1st column (names)
Mainraw=Inraw(:,2);  % extract the 1st data column 
#printf("read_inputs: Mainraw =%s\n", Mainraw(1));
Distraw=Inraw(:,3:end);

fclose (fid); % added by Brendan 2013-10-11
printf('closed %10.5f\n',toc());

return
