%%%Script to run MATLAB Version of the ISO Model
%
% to reread the .ism building input file type 'clear building'
% to reread the .epw weather file type 'clear 'weather'

%% this script works for isomodelV02.m



tic
if exist('OCTAVE_VERSION','builtin')  % if this is octave and not matlab, load packages
    pkg load io
end

% check to see if the building input  file has been loaded or not by 
% looking for the variable named building. If it doesn't exist, run the
% get the filename and run the ism parser
if ~exist('building','var')
    %select the file with a gui
    [filename,pathname]=uigetfile('.ism','Select .ism file to open');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled script run')
        otherwise
            inputsfile=[pathname,filename]; 
    end % switch filename
    if ~exist(inputsfile,'file')
        error('File %s not found',inputsfile);
    end
    disp('Reading and parsing .ism file')
    building=ismparser(inputsfile);
end


if ~exist('weatherfile','var')
    %select the file with a gui
    [filename,pathname]=uigetfile('.epw','Select EPW to Open');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled file input')
        otherwise
            weatherfile=[pathname,filename]; 
    end % switch filename
    if ~exist(weatherfile,'file')
        error('File %s not found',weatherfile);
    end   
    
    disp('Reading and parsing .epw file')
    weather=epwparser(weatherfile);
         
end

disp('Done reading .ism and .epw files')

[Ebldg] = isomodel(building,weather);

Etotal=Ebldg.elec+Ebldg.gas;

%%

Emonth=sum(Etotal,2);  % sum over categories to get monte carlo monthly total.  The 3 means to sum down columns
Etot=sum(Emonth,1);  % sum over the months to get a monte carlo yearly total.  The 2 means to sum across rows
Nruns=length(Etot);

Egasmonth = sum(Ebldg.gas,2)
Eelecmonth = sum(Ebldg.elec,2)

% display the total computations
Emonth'
Etot

figure(1)
m=1:12;
plot(m,Emonth,'k-*',m,Egasmonth,'r-',m,Eelecmonth,'b:');
A=axis; A(1:2)=[0.75,12.25];axis(A);

set(gca,'xtick',m);
set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''})
xlabel('Month')
ylabel('EUI (kWh/m^2)')

tstring=sprintf('Monthly Median EUI with Annual EUI=%0.1f kWh/m^2',Etot);
title(tstring)

EmonthBtu = Emonth*3.412/10.76
EgasBtu = Egasmonth*3.412/10.76
EelecBtu = Eelecmonth *3.412/10.76
EtotBtu = Etot*3.412/10.76

figure(2)
m=1:12;
plot(m,EmonthBtu,'k-*',m,EgasBtu,'r-',m,EelecBtu,'b:');
A=axis; A(1:2)=[0.75,12.25];axis(A);

set(gca,'xtick',m);
set(gca,'XTickLabel',{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',''})
xlabel('Month')


ylabel('EUI (kBtu/ft^22)')

tstring=sprintf('Monthly Median EUI with Annual EUI=%0.1f kBtu/ft^2',EtotBtu);
title(tstring)


Ebldg.cols
Ebldg.elec
Ebldg.cols
Ebldg.gas



toc % stop timer and print result


