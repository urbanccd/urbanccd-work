function  [ W ] = epwparser( file1 )
%epwparser reads and parses an epw format weather file and outputs a structure with
%weather data required for the isomodel.m file
%
%W = epwparser(filein) will read in an epw (energy plus weather) format hourly weather
%file and will output a structure with the monthly and 
%
% Inputs:   filein is the full name of the epw file.
%           if no file is given (i.e. input is blank) the program will
%           prompt the user for an input file using the uigetfile GUI
%
% Output:  A structure named W with the following array fields
% W.mdbt = [12 x 1] mean monthly dry bulb temp (C)
% W.mrh = [12 x 1] mean monthly relative humidity (%)
% W.mwind = [12 x 1] mean monthly wind speed; (m/s) 
% W.msolar = [12 x 8] mean monthly total solar radiation (W/m2) on a vertical surface for each of the 8 cardinal directions
% W.mhdbt = [12 x 24] mean monthly dry bulb temp for each of the 24 hours of the day (C)
% W.mhEgh =[12 x 24] mean monthly Global Horizontal Radiation for each of the 24 hours of the day (W/m2)
%

% by Ralph T. Muehleisen
% V0.02 15 - Nov 2013   No changes
% V0.01 05-Nov-2013  Renumbered to be consisent with new isomodel version numbering


% V0.71 29-Oct-2013 Corrected bug in calculation of theta on line 149
% (removed * by pi/180 multiplication in onte term)
% V0.7 06-Mar-2013  Changed version number to match other files
% V0.6 03-Jan-2013 Changed version number to match other files
% V0.5 20-Dec-2012 Changed version number to match other files
% 
% V0.4 19-Nov-2012
% correct column numbers of epw file were obtained from ReadEPW.m, and EPW2Hourly.m
% by Ted Ngai www.tedngai.net 

%% define some constants

% define surface azimuth angles for S, SE, E, NE, N, NW, W, SW from south in a row array
psi=[0, -45, -90, -135, 180, 135, 90, 45]*pi/180;

sigma=pi/2; % surface tilt in radians (pi/2 is vertical, 0 is horizontal);
rhog=0.14;  % ground reflectivity coefficient


%%  check for a file name as input to the function, if no input
% get the user to select a file using the uigetfile GUI interface

if nargin==0
    %select the file with a gui
    [filename,pathname]=uigetfile('.epw','Select EPW to Open');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled file input')
        otherwise
            file1=[pathname,filename]; 
    end % switch filename
end

%% read in the header information and parse the first line of the header

fid=fopen(file1);
inline=fgetl(fid);  % read in the 1st line of the file
inarray=strread(inline,'%s','delimiter',',');  % break the string into a cell array of strings
location=inarray{2};  % name of weather station
StationID=inarray{6}; % weather station ID number
LAT=str2num(inarray{7}); % latitude - convert from a string  type to a number
LON=str2num(inarray{8}); % longitude
TZ=str2num(inarray{9}); % time zone, relative to greenwich.  Chicago is -6

% skip the next 7 lines of the file
for I=1:7
    fgetl(fid);   
end

%% read in the hourly data
dbt=zeros(8760,1);  % create and zero an 8760x1 array to hold hourly dry bulb temps
Egh=dbt;Eb=dbt; Ed=dbt; wspd=dbt; rh=dbt; dpt=dbt;% create similar arrays for the other hourly variables

% read in and parse the next 8760 lines of hourly weather data
for I=1:8760
    inline=fgetl(fid);  % read in columns in the the 9th line of the file into a string
    inarray=strread(inline,'%s','delimiter',',');  % break the string into an array of strings
    dbt(I)=str2num(inarray{7});  % pull out dry bulb temp, the 7th column
    dpt(I)=str2num(inarray{8}); % pull out dew point temp, the 8th column
    rh(I)=str2num(inarray{9});  % pull out the relative humidity, the 9th column
    Egh(I)=str2num(inarray{14}); % pull out global horizontal radiation, the 14th column
    Eb(I)=str2num(inarray{15}); % pull out direct normal radiation, 15th column
    Ed(I)=str2num(inarray{16}); % pull out global diffuse radiation, 16th column
    wspd(I)=str2num(inarray{22}); % pull out the wind speed, the 22nd column
end
fclose(fid);

%%  create arrays of month day hour and year to date for additional processing
monthlength=[31,28,31,30,31,30,31,31,30,31,30,31];  % set the lengths of each month
Hr=zeros(8760,1);
D=Hr; M=Hr; YTD=Hr;

% create a set of arrays that have the month, day, hour, and year to date
% for each of the 8760 hours in a year.
i=0; j=0;
for I=1:12  % loop for each month
    for J=1:monthlength(I)
        j=j+1;  % j keeps track of the day
        for K=1:24  % loop for each hour
            i=i+1;
            Hr(i)=K; % set the hour
            D(i)=J;  % set the day
            M(i)=I;  % set the month
            YTD(i)=j;
        end % K
    end % J
end % I

%%  compute the monthly average solar radiation incident on the vertical surfaces for the 
% eight primary directions (N, S, E, W, NW, SW, NE, SE)
% these computations come from ASHRAE2007  Fundamentals , chapter 14
% or Duffie and Beckman "Solar engineering of thermal processes, 3rd ed",
% Wiley 2006

%  First compute the solar azimuth for each hour of the year for our
%  location

LSM=15.*TZ;  % compute the local meridian from the time zone.  Negative is W of the prime meridian
LST=Hr;  % the local standard time is just the Hr as generated above - copy this for clarity in the equations below

B=2.*pi.*(YTD -1)./365;  % calculation rotation angle around sun in radians

ET = 2.2918.*(0.0075+0.1868.*cos(B)-3.2077.*sin(B)-1.4615.*cos(2.*B)-4.089.*sin(2.*B));  % Equation of time 
AST=LST+ET./60+(LON-LSM)./15;  % Apparent Solar Time in hours

% dec=23.45*sin((YTD+284)/365*2*pi).*pi/180; % solar declination in radians
% the following is a more accurate formula for declination as taken from
% Duffie and Beckman P. 14
dec=0.006918-0.399913.*cos(B)+0.070257.*sin(B)-0.006758.*cos(2.*B)+0.00907.*sin(2.*B)-0.002679.*cos(3.*B)+0.00148.*sin(3.*B);

lat=LAT.*pi./180;  % convert latitute to radians

H=15.*(AST-12).*pi./180;  % solar hour angle in radians
beta=asin(cos(lat).*cos(dec).*cos(H)+sin(lat).*sin(dec)); % solar altitude angle in radians

sinphi=sin(H).*cos(dec)./cos(beta);  % sin of the solar azimuth
cosphi=(cos(H).*cos(dec).*sin(lat)-sin(dec).*cos(lat))./cos(beta);  % cosine of solar azimuth
phi=atan2(sinphi,cosphi);  % compute solar azimuth in radians

%% compute the hourly radiation on each vertical surface given the solar azimuth for each hour
gamma=zeros(8760,8);  % preallocate for speed increase
theta=gamma; Etb=gamma;  Y=gamma; Etd=gamma; Eglobe=gamma;

for I=1:8
    gamma(:,I)=abs(phi-psi(I));  % surface - solar azimuth in degrees, >pi/2 means surface is in shade
    %costheta=cos(beta).*cos(gamma(:,I)).*sin(sigma)+sin(beta).*cos(sigma);
    theta(:,I)=acos(cos(beta).*cos(gamma(:,I)).*sin(sigma)+sin(beta).*cos(sigma));  % ancle of incidence of sun's rays on surface in rad
    Etb(:,I)=Eb(:).*max(cos(theta(:,I)),0); % Beam component of radiation
    Y(:,I)=max(0.45,0.55+0.437.*cos(theta(:,I))+0.313.*cos(theta(:,I)).^2);  % Diffuse component of radiation
  
    if sigma>pi/2
        Etd(:,I)=Ed(:).*Y(:,I).*sin(sigma);   % diffuse component for sigma> pi/2 meaning it is a wall tilted outward
    else
        Etd(:,I)=Ed(:).*(Y(:,I).*sin(sigma)+cos(sigma)); % diffuse component, for sigma<= pi/2 meaning wall vertical or tilted inward
    end
    
    Etr = (Eb(:).*sin(beta)+Ed(:)).*rhog.*(1-cos(sigma))/2;  % ground reflected component
    Eglobe(:,I)=Etb(:,I)+Etd(:,I)+Etr(:);  % add up all the components
end


%% now compute the monthly averages for the solar radiation
mdbt=zeros(12,1);  % create an empty  12x1 column vector for monthly avg dry bulb temp
mdpt=mdbt; mrh=mdbt; mwind=mdbt; mEgh=mdbt;  % create similar things for relative humidity, wind speed and global horiz rad
msolar=zeros(12,8); % create a 12x8 array for the average solar radiation in each direction
mhdbt=zeros(12,24); % create a 12x24 matrix for monthly avg dry bulb temp for each hour of the day
mhdpt=zeros(12,24); % create a 12x24 matrix for monthly avg dew point temp for each hour of the day
mhEgh=zeros(12,24); % create a 12x24 matrix for monthly avg glob horiz radiation for each hour of the day


% find means and make use of the fact that MATLAB's mean function will work
% on an array or on a matrix and on the matrix it will average down the
% columns but not across rows.  i.e. if M is 12x24 mean(M) will average
% down columns and result ins a 1x24 array.
for I=1:12
    J=find(M==I);  % get the indices of elements where the month is equal to the month given by the loop I
    mdbt(I)=mean(dbt(J)); % compute the monthly average dry bulb temp for elements. 
    mdpt(I)=mean(dpt(J)); % compute the monthly average dew point temp
    mrh(I)= mean(rh(J)); % compute the monthly average relative humdity
    mwind(I)=mean(wspd(J)); % compute the monthly average wind wspeed 
    msolar(I,:)=mean(Eglobe(J,:));  % compute the monthly average solar radiation.  
    mEgh(I,:)=mean(Egh(J)); % get the monthly average for global horizontal radiation
    % Note that mean function above only goes down the column so solar will be an array of monthly averages for each direction
    
    % now get the hourly average dry bulb temp and Egh for each month
    for K=1:24
        L=find(Hr(J)==K);  % get the indices of each hour for each month
        mhdbt(I,K)=mean(dbt(J(L)));  % get the hour by hour monthly averages of dry bulb temp
        mhdpt(I,K)=mean(dpt(J(L)));  % get the hour by hour monthly avg dew pt temp
        mhEgh(I,K)=mean(Egh(J(L)));  % get the hour by hour monthly avg global horz rad
    end
end

%% now put the  averages in a structure for ease of transfer to other routines

W.mdbt=mdbt; % column vector of mean dry bulb temp for each month
W.mdpt=mdpt; % column vector of mean dew point temp for each month
W.mrh=mrh; % column vector of mean relative humidity for each month
W.mwind=mwind; % column vector of mean wind speed for each month
W.msolar=msolar; % column vector of mean solar radiation (direct+diffuse+reflected) for each month
W.mEgh = mEgh; % column vector of mean Egh (global horizontal) for each month
W.mhdbt=mhdbt; % matrix with hourly dry bulb temp (columns) for each month (rows)
W.mhdpt=mhdpt; % matrix with hourly dew point temp (columns) for each month (rows)
W.mhEgh=mhEgh;  % matrix with hourly Egh (columns) for each month (rows)
W.location=location; % string with the weather station location name
W.stationid=StationID; % string with the weather station ID
W.lat = LAT; % weather station latitude in degrees
W.lon = LON; % weather station longitude in degrees
W.tz = TZ; % weather station time zone relative to GMT

end % function
