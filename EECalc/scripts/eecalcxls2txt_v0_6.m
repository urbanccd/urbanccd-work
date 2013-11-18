function [ outarray] = eecalcxls2txt_v0_6(file1 )
%eecalcxls2txt converts eecalc XLS file into a csv text file for use by
%MATLAB/Octave version of eecalc

% V0.6 03-Jan-2013 RTM changed version number to be consistent with other
% files

% V0.5 20-Dec-2012 RTM made changes so both MATLAB and gnu-octave replace
% blank entries with blanks and not NaN


% V0.4 20-Dec-2012 RTM  first version but uses numbering to be consistent
% with the other eecalc files

if exist('OCTAVE_VERSION')  % if this is octave and not matlab, load packages
    pkg load io windows
end


Incells='B12:N174';  % Excel spreadsheet cells to extract
Insheet='Inputs';
if nargin==0
    %select the file with a gui
    [filename,pathname]=uigetfile('.xlsx','Select Input Spreadsheet to Open');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled script run')
        otherwise
            file1=[pathname,filename]; 
    end % switch filename

end

[~,~,Inraw]=xlsread(file1,Insheet,Incells);  % read in the all the columns

% check to see if we are running MATLAB or Gnu Octave
% Octave handles xlsread differently than MATLAB
% in MATLAB, blank entries are replaced by NaN in the raw output
% in Octave, blank entries are replaced by an empty matrix
% convert the NAN to blank entries

if ~exist('OCTAVE_VERSION')
    
    for I=1:length(Inraw(:))
        if isnan(Inraw{I})
            Inraw{I}=[];
        end
    end
    
    
end



Mainvals=Inraw(:,2);  % extract the 2nd column that has the main values
Validrows=[];

% find all the values in the 2nd column that are NOT empty because those
% are all the rows we want to extract
for I=1:length(Mainvals)
    if ~isempty(Mainvals{I})  % check to make sure the element is NOT a NaN
        Validrows=[Validrows;I];  % make J a column array with the indices of all elements that are strings or numeric
    end
end


outarray=[Inraw(Validrows,1:2),Inraw(Validrows,5:13)];

% create the output text file by stripping off the end xls or xlsx and
% adding txt
if file1(end-4)=='.'  % we have an xlsx file if the . is in the end-4 position
    file2=[file1(1:end-4),'txt']; 
else  % we have an xls file so the . is in the end-3 position
    file2=[file1(1:end-3),'txt']; 
end

fid=fopen(file2,'wt');
for I=1:length(Validrows)
    for J=1:11
        outval=cell2mat(outarray(I,J));
        if isempty(outval)
            fprintf(fid,'%s','-');
        elseif isnumeric(outval)  
            fprintf(fid,'%f',outval);  % if a number, print out as float
        else
            fprintf(fid,'%s',outval);  % if a char array, print out as string
        end
        if J==11
            fprintf(fid,'\n'); % if it is the last column, print an eol
        else
            fprintf(fid,','); % for any other column, print a comma after
        end
    end % J
end % I
            
fclose(fid);

return
