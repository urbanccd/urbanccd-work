function [ outarray] = xls2ism(file1 )
%xls2ism converts an isomodel XLSX template into a .ism file
% v0.02 19-Nov-2013 RTM   Updated with new variable names

% V0.01 14-Nov-2013 RTM   This version simply reads the ism sheet of the template .xlsx 
% file and copies to a text file


if exist('OCTAVE_VERSION')  % if this is octave and not matlab, load packages
    pkg load io windows
end

Incells='A1:A170';  % Excel spreadsheet cells to extract.   Go to 170 well past the end of inputs just to be sure
Insheet='ismfile';
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


outarray=[Inraw];

% create the output ism file by stripping off the end xls or xlsx and
% adding ism
if file1(end-4)=='.'  % we have an xlsx file if the . is in the end-4 position
    file2=[file1(1:end-4),'ism']; 
else  % we have an xls file so the . is in the end-3 position
    file2=[file1(1:end-3),'ism']; 
end

fid=fopen(file2,'wt');
[Nrows,Ncol]=size(Inraw);
for I=1:Nrows
	fprintf(fid,'%s\n',Inraw{I});
end % I
            
fclose(fid);

return
