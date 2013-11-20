
function [Ebldg]=isomodel(In,W)
% isomodel.m calculates energy use according to the CEN/ISO 13790 standards
%
% isomodel.m implements the CEN/ISO 13790 standards along with information
% from a few other locations where the CEN/ISO standards are unclear or
% inappropriate
%
% isomodel.m inputs two structures: In and W which are model inputs and
% monthly weather inputs as created by the parse_inputs and read_epw
% routines
%
% isomodel.m outpus a structure that has the  monthly energy broken
% into the major categories.
%
% V0.02  19-Nov-2013 RTM
% Added unoccupied supply and exhaust ventilation rates.   Compute a time weighted average of the occupied and unoccupied ventilation rates
% added unoccupied infiltration rate
% added skylight SHGC, SCF, and SDF values


% V0.1   
%Converted older bldgcalc.m to isomodel, this is the version thatwas converted to the first C++ code

%
%% important constants

% create column vectors with monthly information
v_days_ina_mo=[31 28 31 30 31 30 31 31 30 31 30 31]';  
v_hrs_ina_mo=24*v_days_ina_mo;  % number of hours in each month
v_Msec_ina_mo=3600*v_hrs_ina_mo/1E6;  % number of Megaseconds in each month
days_ina_year=sum(v_days_ina_mo); % number of total days in a year
v_mo_frac_of_yr=v_days_ina_mo/days_ina_year; % fraction of a year that each month represents (i.e. about 1/12)

hrs_ina_wk=168;  %hours_total_week
hrs_ina_yr=8760;

%%% CHANGE
% convert kWh to MJ = 3600 sec/hr / 1000 kW/MW
% replaces kWh2MJ = 1/.277;  % convert kWh to MJ on spreadsheet
% 10-Nov-2012 RTM
kWh2MJ=3.6;


%% compute schedule and occupancy
% compute number of occupied hourse
hrs_occ_per_day=In.occ_hour_end-In.occ_hour_start;
if hrs_occ_per_day<0
    hrs_occ_per_day=hrs_occ_per_day+24;
end


days_occ_per_wk=In.occ_day_end-In.occ_day_start +1;
if days_occ_per_wk<0;
    days_occ_per_wk=days_occ_per_wk+7;
end

occ_dens=In.people_density_occ;  % density of people during occupied times m2/person

%%% CHANGE
% added actual unoccupied people density input to sheet for more
% flexibility
% RTM 10-NOV-2012
unocc_dens=In.people_density_unocc; % density of people during unoccupied times m2/person

%occ_count=In.cond_flr_area/occ_dens; % occ_count_total;
%occupant_total=In.cond_flr_area/In.people_density_occ; % occupant_total


%%%%%  DEFINE TERMS week, weekend, day and night
%  the term week refers to the normal operating days (usually M-F or M-Sa)
%  the term weekend refers to days not normally operating (usually Sa-Su)

% occupied weekday hours 
hrs_wk_day=hrs_occ_per_day*days_occ_per_wk; % total hours occupied (i.e. "day") during the regular business period (i.e. "week")
frac_hrs_wk_day=hrs_wk_day/hrs_ina_wk;  % hours_occ_weekday


%weekday night occupancy  = i.e. hours after normal operating hours during
%the days of normal operation
hrs_unocc_per_day=24-hrs_occ_per_day; % number of hours not regularly occupied (i..e "night" )
hrs_wk_nt=(days_occ_per_wk-1)*hrs_unocc_per_day; % total "night" hours during the "week"
frac_hrs_wk_nt=hrs_wk_nt/hrs_ina_wk; % fraction of "night" hours during the "week"

%%% CHANGE
% added an occupancy fraction for unoccupied "weekday" "nights" computed from inputs  
% we can eventually convert to an hourly schedule 
% RTM 10-NOV-2012
%occ_fract_wk_nt= 1/9;
occ_frac_wk_nt = In.people_density_occ/In.people_density_unocc;  % find ratio of occupancy on week nights to week days

%"weekend" total occupancy
hrs_wke_tot=hrs_ina_wk - hrs_wk_day - hrs_wk_nt;  %total number of hours in "weekend"
frac_hrs_wke_tot=hrs_wke_tot/hrs_ina_wk;  % frac_unocc_weekend_total%
occ_frac_wke_tot=occ_frac_wk_nt;  % use same occupancy fraction as weekday nights

%"weekend" "day" occupancy
hrs_wke_day=(7-days_occ_per_wk)*hrs_occ_per_day;  % total number of "day" hours during the "weekend" 
fract_hrs_wke_day=hrs_wke_day/hrs_ina_wk;  % frac of "day" ours during weekend 
occ_frac_wke_day=occ_frac_wk_nt;   % use the same occupancy fraction as weekday nights

%"weekend" "night" occupancy
hrs_wke_nt=hrs_wke_tot-hrs_wke_day;  %hours_unocc_weekend_night
frac_hrs_wke_nt=hrs_wke_nt/hrs_ina_wk;  %frac_unocc_weekend_total
occ_frac_wke_nt=occ_frac_wk_nt;  % use same occupuancy fraction as weekday nights and weekend day

% set overall occupied and unoccpied fraction
frac_hours_occ = frac_hrs_wk_day;   % the total fraction of hours occupied has been computed as frac_hrs_wk_day
frac_hours_unocc = 1- frac_hours_occ;

% compute the number of megaseconds in each of the time periods of the week
v_Msec_wk_day=v_Msec_ina_mo*frac_hrs_wk_day; % number of megaseconds that are  "weekday" "day" i.e. occupied
v_Msec_wk_nt=v_Msec_ina_mo*frac_hrs_wk_nt; % number of megaseconds that are  "weekday" "night"
v_Msec_wke_day=v_Msec_ina_mo*fract_hrs_wke_day; %number of megaseconds that are  "weekend" "day"
v_Msec_wke_nt=v_Msec_ina_mo*frac_hrs_wke_nt; %number of megaseconds that are  "weekend" "night"


%%  Generate a set of binary sequences showing which hours are occupied and which are not
v_nt_hrs_yesno=zeros(24,1);
for I=1:24
    if ( (I-8)>=0 )&&((I-8)<hrs_occ_per_day)
        v_nt_hrs_yesno(I)=0;
    else
        v_nt_hrs_yesno(I)=1;
        
    end
end
v_day_hrs_yesno=1-v_nt_hrs_yesno;  %taking  1-unocc hours will give us the occupied hours.

%%  Break Solar Radiation into occupied and unoccupied times

v_mdbt=W.mdbt;  % copy to a new variable so vector nature is clear
M_mhdbt=W.mhdbt;  % copy to a new variable so matrix nature is clear
M_mhEgh=W.mhEgh; % copy to a new variable so matrix nature is clear

% Note, these are matrix multiplies (matrix*vector) resulting in a vector  
v_Tdbt_day=(M_mhdbt*v_day_hrs_yesno)./sum(v_day_hrs_yesno); %monthly average dry bulb temp (dbt) during the occupied hours of days
v_Tdbt_nt=(M_mhdbt*v_nt_hrs_yesno)./sum(v_nt_hrs_yesno); %monthly avg dbt during the unoccupied hours of days

v_Egh_day=(M_mhEgh*v_day_hrs_yesno)./sum(v_day_hrs_yesno);  %monthly avg global horiz rad power (Egh)  during the "day" hours
v_Egh_nt=(M_mhEgh*v_nt_hrs_yesno)./sum(v_nt_hrs_yesno);  %monthly avg Egh during the "night" hours

v_Wgh_wk_day=v_Egh_day.*v_Msec_wk_day; % monthly avg Egh energy (Wgh) during the week days
v_Wgh_wk_nt=v_Egh_nt.*v_Msec_wk_nt;  %monthly avg Wgh during week nights 
v_Wgh_wke_day=v_Egh_day.*v_Msec_wke_day; %monthly avg Wgh during weekend days
v_Wgh_wke_nt=v_Egh_nt.*v_Msec_wke_nt; %monthly avg Wgh during weekend nights
v_Wgh_tot=v_Wgh_wk_day+v_Wgh_wk_nt+v_Wgh_wke_day+v_Wgh_wke_nt; %Egh_avg_total MJ/m2

%FRAC_PGH_DAYTIME=v_Wgh_wk_day./v_Wgh_tot; %frac_Egh_occ
frac_Pgh_wk_nt=v_Wgh_wk_nt./v_Wgh_tot; %frac_Egh_unocc_weekday_night
frac_Pgh_wke_day=v_Wgh_wke_day./v_Wgh_tot; %frac_Egh_unocc_weekend_day
frac_Pgh_wke_nt=v_Wgh_wke_nt./v_Wgh_tot; %frac_Egh_unocc_weekend_night

%%  find what time the sun comes up and goes down and the fraction of hours sun is up and down

%%% CHANGE
% the following two lines were in the original spreadsheet and the fraction of hours up was fixed.  
% Let's do this properly by looking for the hours the sun is up and down each month
% RTM 10-NOV-2012
%
% v_frac_hrs_sun_down=ones(12,1)*(24-(19-7+1))/24;
% v_hrs_sun_down_mo=b_frac_hrs_sun_down.*v_hrs_ina_mo;

v_frac_hrs_sun_down=zeros(12,1);
v_frac_hrs_sun_up=zeros(12,1);
v_sun_up_time=zeros(12,1);
v_sun_down_time=zeros(12,1);

for  I=1:12
    J=find(W.mhEgh(I,:)~=0);  % find the hours where Egh is nonzero and identify as sun being up
    v_sun_up_time(I)=J(1);  % first element is the sunup hour
    v_sun_down_time(I)=J(end); % last element is sundown hour
    v_frac_hrs_sun_up(I)=length(J)/24;  % fraction of hours in the day the sun is up
    v_frac_hrs_sun_down(I)=1-v_frac_hrs_sun_up(I); % fraction of hours in the day the sun is down
end
v_hrs_sun_down_mo=v_frac_hrs_sun_down.*v_hrs_ina_mo;  


%% compute lighting energy use as per prEN 15193:2006

lpd_occ=In.LPD_occ;
lpd_unocc=In.LPD_unocc;

% assign fractions for daylighting, occupancy sensors, and const illum
% sensors as per prEN 1593:2006.
% Lookup tables are on the spreadsheet

F_D=In.daylighting_sensor; % F_D = daylight sensor dimming fraction
F_O=In.lighting_occupancy_sensor; % F_O = occupancy sensor control fraction
F_C=In.lighting_constant_illumination; %F_c = constant illuminance control fraction

%%% NOTE 
% the following assumes day starts at hour 7 and ends at hour 19
% and 2 weeks per year are considered completely unoccupied for lighting
% This should be converted to a monthly quanitity using the monthly
% average sunup and sundown times

n_day_start=7;
n_day_end=19;
n_weeks=50;
t_lt_D=(min(In.occ_hour_end,n_day_end)-max(In.occ_hour_start,n_day_start))*(In.occ_day_end+1-In.occ_day_start+1)*n_weeks; %lighting_operating_hours during the daytime
t_lt_N=(max(n_day_start-In.occ_hour_start,0)+max(In.occ_hour_end-n_day_end,0))*(In.occ_day_end+1-In.occ_day_start+1)*n_weeks; %lighting_operating_hours during the nighttime

% total lighting energy 
Q_illum_occ=In.cond_flr_area*lpd_occ*F_C*F_O*(t_lt_D*F_D + t_lt_N)/1000;  % find the total lighting energy for occupied times in kWh

%%% CHANGE
% as an alternative to a fixed parasitic lighting energy density use an unoccupied
% number for illumuniation LPD
% RTM 13-NOV-2012
%
% this is the original code from the spreadsheet that fixed the parasitic
% lighting load at 6 kWh/m2/yr as per pren 15193-2006 B12
% Q_lt_par_den=1+5;  % parasitic lighting energy density  is emergency + control lighting kWh/m2/yr
% Q_illum_par=Q_lt_par_den*In.cond_flr_area;
% Q_illum_tot_yr=Q_illum_occ+Q_illum_par;


 t_unocc=hrs_ina_yr - t_lt_D - t_lt_N;  % find the number of unoccupied lighting hours in the year
 Q_illum_unocc = In.cond_flr_area*lpd_unocc*t_unocc/1000;  % find the total annual lighting energy for unoccupied times in kWh
 Q_illum_tot_yr=Q_illum_occ+Q_illum_unocc;  % find the total annual lighting energy in kWh

% split annual lighting energy into monthly lighting energy via the month fraction of year
v_Q_illum_tot=Q_illum_tot_yr.*v_mo_frac_of_yr; %total interior monthly lighting energy in kWh

% exterior lighting
v_Q_illum_ext_tot=v_hrs_sun_down_mo*In.E_lt_ext/1000;  %etotal exterior monthly lighting energy in kWh

%% compute envelope parameters as per ISO 13790 8.3

% convert vectored inputs to vectors for clarification
v_wall_A=In.wall_area;
v_win_A=In.win_area;
v_wall_U=In.wall_U;
v_win_U=In.win_U;

v_env_UA=v_wall_A.*v_wall_U + v_win_A.*v_win_U; %compute total envelope U*A


% compute direct transmission heat transfer coefficient to exterior in W/K as per 8.3.1
% ignore linear and point thermal bridges for now
H_D = sum(v_env_UA);  

% for now, also ignore heat transfer to ground (minmal in big office buildings), unconditioned spaces
% and to adjacent buildings
H_g = 0; % steady state  heat transfer coefficient by transfer to ground - not yet implemented
H_U = 0; % heat transfer coefficient for transmission through unconditioned spaces - not yet implemented
H_A = 0; % heat transfer coefficient for transmission to adjacent buildings  - not yet implemented

H_tr=H_D+H_g+H_U+H_A; %total transmission heat transfer coefficient as per eqn 17 in 8.3.1


% copy the following from input structure to vectors for clarity
v_wall_emiss=In.wall_thermal_emiss; % wall thermal emissivity
v_wall_alpha_sc =In.wall_solar_alpha; %wall solar absorption coefficient

%%  Window Solar Gain

%%% REVISIT THIS SECTION
%%% The solar heat gain could be improved
%%% better understand SCF and SDF and how they map to F_sh
%%% calculate effective sky temp so we can better estimate theta_er and
%%% theta_ss, and hr

% From ISO 13790 11.3.3 Effective solar collecting area of glazed elements,% eqn 44
% A_sol = F_sh,gl* g_gl*(1 ? F_f)*A_w,p
% A_sol = effective solar collecting area of window in m2
% F_sh,gl = shading reduction factor for movable shades as per 11.4.3 % (v_win_SDF *v_win_SDF_frac)
% g_gl = total solar energy transmittance of transparent element as per % 11.4.2
% F_f = Frame area fraction (ratio of projected frame area to overall glazed element area) as per 11.4.5 (v_wind_ff)
% A_w,p = ovaral projected area of glazed element in m2 (v_wind_A)

%v_win_SHGC=In.win_SHGC; % copy to a new variable with a v_ for clarification
%v_win_SCF=In.win_SCF;  % copy to a new variable with a v_ for clarification


% The frame factor, v_win_ff is found using ISO 10077-1, in absence a national standard
% can be used.  Examples range from 0.2 for heating climates to 0.3 for
% cooling.  Use 0.25 as a compromise
n_win_ff=0.25;
v_win_ff=ones(size(1,9))*n_win_ff; %window frame_factor;

% assign SDF based on pulldown:
%n_win_SDF_table=[0.5,0.35,1.0];% assign SDF based on pulldown value of 1, 2 or 3
%v_win_SDF=n_win_SDF_table(In.win_SDF); %window SDF

%added skylight SDF to ism file and ism parser so these two lines
%are no longer needed
%skylightSDF= 1.0;
%v_win_SDF =[In.win_SDF, skylightSDF];
v_win_SDF =In.win_SDF
% set the SCF and SDF fractions which includes heat transfer - set at 100% for now
%v_win_SCF_frac=ones(size(In.win_SCF)); % SCF fraction to include in HX;
v_win_SDF_frac=ones(size(v_win_SDF)); % SDF fraction to include in HX; Fixed at 100% for now

v_win_F_shgl = v_win_SDF.*v_win_SDF_frac;


v_g_gln = In.win_SHGC ; % normal incidence solar energy transmittance which is SHGC in america
n_win_F_W = 0.9;%  correction factor for non-scattering window as per ISO 13790 11.4.2
v_g_gl = v_g_gln*n_win_F_W; % solar energy transmittance of glazing as per 11.4.2

v_win_A_sol=v_win_F_shgl.*v_g_gl.*(1-v_win_ff).*v_win_A; 

% form factors given in ISO 13790, 11.4.6 as 0.5 for wall, 1.0 for unshaded roof
n_v_env_form_factors=[0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 1]; %formfactor_to_sky.  Walls are all 0.5, roof is 1.0

n_R_sc_ext=0.04;  % vertical wall external convection surface heat resistance as per ISO 6946
v_wall_R_sc=ones(size(1,9))*n_R_sc_ext; %vertical wall external convective surface heat resistances 

% 11.4.6 says use hr=5 as a first approx.
v_win_hr=5*v_wall_emiss; %window external radiative heat xfer coeff.

% effective collecting area of opaque building elements, A_sol EN ISO 13790 11.3.4
% A_sol = ?_S,c × R_se × U_c × A_c
% A_sol = effective solar collecting area
% ?_S,c = dimensionless solar absorption coefficient
% R_se = external surface heat rsistance determined via ISO 6946 in m2*K/W
% U_c = thermal transmittance of opaque part determined via ISO 6946 W/m2K
% A_c = projected area of opaque part in m2

v_wall_A_sol=v_wall_alpha_sc.*v_wall_R_sc.*v_wall_U.*v_wall_A; 

%% Solar Heat Gain
% From EN ISo 13790 11.3.2  eqn 43
% 
% ?sol,k = F_sh,ob,k * A_sol,k *  I_sol,k ? F*r,k ?_r,k
%
% ?_sol,k = solar heat flow gains through building element k
% F_sh,ob,k = shading reduction factor for external obstacles calculated via 11.4.4
% A_sol,k = effective collecting area of surface calculated via 11.3.3 (glazing ) 11.3.4 (opaque)
% I_sol,k = solar irradiance, mean energy of solar irradiation per square meter calculated using Annex F
% F_r,k form factor between building and sky determined using 11.4.6
% ?_r,k extra heat flow from thermal radiation to sky determined using 11.3.5


%%% REVISIT THIS SECTION
%%% The solar heat gain could be improved
%%%  better understand SCF and SDF and how they map to F_SH
%%% calculate effective sky temp so we can better estimate theta_er and
%%% theta_ss

%added skylight SCF to ism file and ism parser so these two lines
%are no longer needed
%skylightSCF=1.0;
%v_win_SCF = [In.win_SCF,skylightSCF];

v_win_SCF =In.win_SCF

v_win_SCF_frac=ones(size(v_win_SCF)); % SCF fraction to include in HX;  Fixed at 100% for now

v_I_sol=[W.msolar W.mEgh];  % create a new solar irradiance vector with the horizontal included as the last column

% compute the total solar heat gain for the glazing area
% note that the stuff in the sum is a 1x9 row vector for each surface since
% the .* multiplies element by element not a vector multiply.
v_win_phi_sol=zeros(12,1);


for I=1:12
    temp=v_win_SCF.*v_win_SCF_frac.*v_win_A_sol.*v_I_sol(I,:);
   v_win_phi_sol(I)=sum(temp);
end

% compute opaque area thermal radiation to the sky from EN ISO 13790 11.3.5
% ?_r,k = Rse×Uc×Ac×hr×??er (46)
% ?_r,k = thermal radiation to sky in W
% R_se = external heat resistance as defined above m2K/W
% U_c = U value of element as defined above W/m2K
% A_c = area of element  defined above m2
% ??er = is the average difference between the external air temperature and the apparent sky temperature,
% determined in accordance with 11.4.6, expressed in degrees centigrade.

% 11.4.6 says take ?er=9k in sub polar zones, 13 K in tropical or 11 K in intermediate
theta_er=ones(size(1,9))*11;  % average difference between air temp and sky temp = 11K as per 11.4.6

v_wall_phi_r = v_wall_R_sc.*v_wall_U.*v_wall_A.*v_win_hr.*theta_er;

% compute the total solar heat gain for the opaque area
v_wall_phi_sol=zeros(12,1);
for I=1:12
    temp=(v_wall_A_sol.*v_I_sol(I,:)-v_wall_phi_r.*n_v_env_form_factors);
   v_wall_phi_sol(I)=sum(temp);
end

v_phi_sol=v_win_phi_sol+v_wall_phi_sol;  % total envelope solar heat gain in W
v_E_sol= v_phi_sol.* v_Msec_ina_mo(I); % total envelope heat gain in MJ



%% Compute heat gains and losses

% heat gain from occupants
%%% from Table G-9 of ISO 13790

% 
phi_int_occ=In.htgain_per_person/In.people_density_occ;  % get the heat gain in W/m2 from people during occupied times
phi_int_unocc=In.htgain_per_person/In.people_density_unocc;  % get the heat gain in W/m2 from people during unoccupied times
phi_int_avg=frac_hrs_wk_day*phi_int_occ +(1-frac_hrs_wk_day)*phi_int_unocc;  %get the average heat gain from people in W/m2

phi_plug_occ=In.elec_plug_dens_occ + In.gas_plug_dens_occ; %get the heat again in W/m2 from appliances during occupied times
phi_plug_unocc=In.elec_plug_dens_unocc + In.gas_plug_dens_unocc; %get the heat again in W/m2 from appliances during unoccupied times
phi_plug_avg=phi_plug_occ*frac_hrs_wk_day + phi_plug_unocc*(1-frac_hrs_wk_day); % get the average heat gain from appliances in W/m2

phi_illum_occ = Q_illum_occ/In.cond_flr_area/hrs_ina_yr/frac_hrs_wk_day*1000; % convert occ illum energy from kWh to W/m2
phi_illum_unocc = Q_illum_unocc/In.cond_flr_area/hrs_ina_yr/(1-frac_hrs_wk_day)*1000; % convert unocc illum engergy from kWh to W/m2
phi_illum_avg = Q_illum_tot_yr/In.cond_flr_area/hrs_ina_yr*1000; % % convert avg E_illum from kWh per year to average W/m2

%%% CHANGED
% modified code to read average people density during unoccupied times
% rathter than assuming it is 1/9 of occupied times.
%

% original spreadsheet computed the approximate internal heat gain for week nights, weekend days, and weekend nights
% assuming they scale as the occ. fractions.  These are used for finding temp and not for directly calculating energy 
% use total so approximations are more acceptable
% phi_int_wk_nt=(phi_int_occ+phi_plug_occ+phi_illum_occ)*occ_frac_wk_nt;
% phi_int_wke_day=(phi_int_occ+phi_plug_occ+phi_illum_occ)*occ_frac_wke_day;
% phi_int_wke_nt=(phi_int_occ+phi_plug_occ+phi_illum_occ)*occ_frac_wke_nt;

% the following is a more accuate internal heat gain for week nights,
% weekend days and weekend nights as it uses the unoccupied values rather
% than just scaling occupied versions with the occupancy fraction
% RTM 13-Nov-2012
phi_int_wk_nt=(phi_int_unocc+phi_plug_unocc+phi_illum_unocc);
phi_int_wke_day=(phi_int_unocc+phi_plug_unocc+phi_illum_unocc);
phi_int_wke_nt=(phi_int_unocc+phi_plug_unocc+phi_illum_unocc);



%% Internal Heat Gain in MJ

phi_I_occ = phi_int_avg*In.cond_flr_area; %phi_I_occ  - total occupant internal heat gain per year
phi_I_app = phi_plug_avg*In.cond_flr_area; %phi_I_app - total appliance internal heat gain per year
phi_I_lt = phi_illum_avg*In.cond_flr_area; %phi_I_lg - total lighting internal heat gain per year
phi_I_tot = phi_I_occ + phi_I_app + phi_I_lt;

%% Unoccupied time heat gains in MJ
v_W_int_wk_nt=In.cond_flr_area.*phi_int_wk_nt.*v_Msec_wk_nt;  %internal heat gain for "week" "night"
v_W_int_wke_day=In.cond_flr_area.*phi_int_wke_day.*v_Msec_wke_day; %internal heat gain "weekend" "day"
v_W_int_wke_nt=In.cond_flr_area.*phi_int_wke_nt.*v_Msec_wke_nt; %internal heat gain "weekend" "night"

v_W_sol_wk_nt = v_E_sol.*frac_Pgh_wk_nt;  %solar heat gain "week" "night" in MJ
v_W_sol_wke_day = v_E_sol.*frac_Pgh_wke_day; % solar heat gain "weekend" "day" in MJ
v_W_sol_wke_nt = v_E_sol.*frac_Pgh_wke_nt; % solar heat gain "weekend" "night" in MJ

v_P_tot_wk_nt = (v_W_int_wk_nt+v_W_sol_wk_nt)./v_Msec_wk_nt;  % total heat gain "week" "night" W/m2
v_P_tot_wke_day = (v_W_int_wke_day+v_W_sol_wke_day)./v_Msec_wke_day;% total heat gain "weekend" "day W/m2
v_P_tot_wke_nt = (v_W_int_wke_nt+v_W_sol_wke_nt)./v_Msec_wke_nt; % total heat gain "weekend" "night" W/m2


%%  Interior Temp  (occ, weekday unocc, weekend day, weekend night)

% det the temp differential from the interior heating./cooling setpoint
% based on the BEM type.
% an advanced BEM has the effect of reducing the effective heating temp and
% raising the effective cooling temp during times of control (i.e. during
% occupancy).  
% 
switch In.BEM_type
    case 1
        T_adj=0;
    case 2
        T_adj=0.5;
    case 3
        T_adj=1;
end

ht_tset_ctrl = In.ht_tset_occ - T_adj;  % 
cl_tset_ctrl = In.cl_tset_occ + T_adj;

% during unoccupied times, we use a setback temp and even if we have a BEM
% it has no effect
ht_tset_unocc = In.ht_tset_unocc;
cl_tset_unocc = In.cl_tset_unocc;

v_ht_tset_ctrl = ones(12,1).*ht_tset_ctrl;  % create a column vector of the interior heating temp set point for each month
v_cl_tset_ctrl = ones(12,1).*cl_tset_ctrl;

% flags to signify if we have heating and controls turned on or off
% and cooling and controls turned off.  We might turn off if we are
% unoccupied for an extended period of time, say a school in summer
T_ht_ctrl_flag=1;  
T_cl_ctrl_flag=1;

%%% NOTE heat capacity description had an error on input sheet before.  It asked for
% envelope heat capacity but used floor area for Cm calc so this should ask
% for heat capacity of interior construction.
% We should really should separate this into envelope and interior terms
% and add them together
%  RTM 13-NOV-2012


% set the heat capacity given the  building interior heat capacity per unit
% area J/K/m2 from input spreadsheet
Cm_int=In.heat_capacity_int*In.cond_flr_area;  % set the interior heat capacity

%%% CHANGE
% add in the heat capacity of the wall to the heat capacity of interior
% based on floor area.   Assume same J/K/m2 for walls as interior for now
% do not add in window areas
Cm_env=In.heat_capacity_env.*(sum(v_wall_A));

%Cm_env=0;  % use this to match old spreadsheet Cm calc;
Cm=Cm_int+Cm_env;

% H_ve is overall heat transfer coefficient by ventilation as per ISO 13790 9.3  
H_ve=0;  % not implemented, set to 0 for now (its small so a good approx anyhow)
H_tot=H_tr+H_ve;  %total overall heat transfer coefficient as per 12.2.1.3

tau=Cm./H_tot/3600;  % time constant of building in *hours* as per eqn 62 in 12.2.1.3 of 13790

% The following code computes the average weekend room temp using exponential rise and
% decays as we switch between day and night temp settings.  It assumes that
% the weekend is two days (we'll call them sat and sun)
%
% we do this wierd breakdown breakdown because want to separate day with
% solar loading from night without.  We can then use the average temp
% in each time frame rather than the overall monthly average.  right now
% wk_nt stuff is the same as wke_nt, but wke_day is much different because
% the solar gain increases the heat gain considerably, even on the weekend
% when occupant, lighting, and plugload gains are small


%%% NOTE 
% The following code is not a direct translation of the excel spreadsheet
% but makes use of both loops and matricies for clarity but computes the same results

% create a vector of lengths of the periods of times between possible temperature resets during
% the weekend
v_ti=[hrs_unocc_per_day, hrs_occ_per_day,  hrs_unocc_per_day, hrs_occ_per_day, hrs_unocc_per_day];

% generate an effective delta T matrix from ratio of total interior gains to heat
% transfer coefficient for each time period
% Note this is a matrix where the columns are the vectors v_P_tot_wk_nt/H_tot, and so on
% this is for a week night, weekend day, weekend night, weekend day,weekend night sequence
M_dT=[v_P_tot_wk_nt, v_P_tot_wke_day, v_P_tot_wke_nt, v_P_tot_wke_day, v_P_tot_wke_nt]./H_tot;
M_Te=[v_Tdbt_nt, v_Tdbt_day, v_Tdbt_nt, v_Tdbt_day, v_Tdbt_nt]; % create a matrix of the  average dry bulb temps


% compute the change in temp from setback to another heating temp in unoccupied times 
if T_ht_ctrl_flag ==1  % if the HVAC heating controls are turned on.
    
  % find the exponential Temp decay after any changes in heating temp setpoint and put
  % in the matrix M_Ta with columns being the different time segments 
  
    M_Ta=zeros(12,4);
    v_Tstart=v_ht_tset_ctrl;
    for I=1:4
        M_Ta(:,I)=(v_Tstart - M_Te(:,I) - M_dT(:,I)).*exp(-v_ti(I)./tau)+M_Te(:,I)+M_dT(:,I);
        v_Tstart=M_Ta(:,I);
    end
    
    % the temp will only decay to the new lower setpoint, so find which is
    % higher the setpoint or the decay and select that as the start point for
    % the average integration to follow
   M_Taa=zeros(12,5);
   M_Taa(:,1)=v_ht_tset_ctrl;
    for I=2:5 % loop wke day to wke nt to wke day to wke nt
        M_Taa(:,I)=max(M_Ta(:,I-1),ht_tset_unocc);
        %v_Tstart=M_Ta(:,I);
    end
   M_Tb=zeros(12,5);
    % for each time period, find the average temp given the start and
    % ending temp and assuming exponential decay of temps
    %v_t_start=M_Taa(:,1);
    for I=1:5 % loop through wk nt to wke day to wke nt to wke day to wke nt
        v_T_avg=tau./v_ti(I).*(M_Taa(:,I) - M_Te(:,I) -M_dT(:,I)).*(1-exp(-v_ti(I)/tau)) + M_Te(:,I) +M_dT(:,I);       
        M_Tb(:,I) = max(v_T_avg,ht_tset_unocc);
    end
    
    v_Th_wke_avg=zeros(12,1);
    for I=1:12 % for each month
        v_Th_wke_avg(I)=mean(M_Tb(I,:));  % get the average for each month
    end
    v_Th_wk_day = v_ht_tset_ctrl;
    v_Th_wk_nt=M_Tb(:,1);
    
else % if the HVAC heating controls are turned off there is no setback so temp is constant
    v_Th_wk_day=v_ht_tset_ctrl;
    v_Th_wk_nt=v_ht_tset_ctrl;
    v_Th_wke_avg=v_ht_tset_ctrl;
end
    
if T_cl_ctrl_flag ==1  % if the HVAC cooling controls are on
    % find the Temp decay after any changes in cooling temp setpoint
    M_Tc=zeros(12,4);
    v_Tstart=v_cl_tset_ctrl;
    for I=1:4    
        M_Tc(:,I)=(v_Tstart - M_Te(:,I) - M_dT(:,I)).*exp(-v_ti(I)/tau)+M_Te(:,I)+M_dT(:,I);
        v_Tstart=M_Tc(:,I);
    end
    % Check to see if the decay temp is lower than the temp setpoint.  If so, the space will cool
    % to that level.  If the cooling setpoint is lower the cooling system will kick in and lower the 
    % temp to the cold temp setpoint 
    M_Tcc=zeros(12,5);
    M_Tcc(:,1)=min(v_cl_tset_ctrl,cl_tset_unocc);
    for I=2:5
        M_Tcc(:,I)=min(M_Tc(:,I-1),cl_tset_unocc);
    end
      
    % for each time period, find the average temp given the exponential
    % decay
    %v_t_start=M_Tcc(:,1);
    M_Td=zeros(12,5);
    for I=1:5
        v_T_avg=tau./v_ti(I).*(M_Tcc(:,I) - M_Te(:,I) -M_dT(:,I)).*(1-exp(-v_ti(I)/tau)) + M_Te(:,I) +M_dT(:,I);       
        M_Td(:,I) = min(v_T_avg,cl_tset_unocc);
    end
    
    v_Tc_wke_avg=zeros(12,1);
    for I=1:12
        v_Tc_wke_avg(I)=mean(M_Td(I,:));  % get the average for each month
    end
    v_Tc_wk_day = v_cl_tset_ctrl;
    v_Tc_wk_nt=M_Td(:,1); % T_i_unocc_weekday_night  
    
else  % if cooling controls are turned off, temp will be constant at the control set temp with no setback
   v_Tc_wk_day=v_cl_tset_ctrl; 
   v_Tc_wk_nt=v_cl_tset_ctrl;
   v_Tc_wke_avg=v_cl_tset_ctrl;
end

%find the average temp for the whole week from the fractions of each period
v_Th_wk_avg = v_Th_wk_day*frac_hrs_wk_day+v_Th_wk_nt*frac_hrs_wk_nt+v_Th_wke_avg*frac_hrs_wke_tot; % T_i_average
v_Tc_wk_avg = v_Tc_wk_day*frac_hrs_wk_day+v_Tc_wk_nt*frac_hrs_wk_nt+v_Tc_wke_avg*frac_hrs_wke_tot; % T_i_average

% the final avg for monthly energy computations is the lesser of the avg
% computed above and the heating set control
v_Th_avg = min(v_Th_wk_avg,ht_tset_ctrl) ;% T_i_heat_average_cal
v_Tc_avg = max(v_Tc_wk_avg,cl_tset_ctrl); % T_i_cool_average_cal


%%  Ventilation
% required energy for mechanical ventilation based on  source EN ISO 13789
% C.3, C.5 and EN 15242:2007 6.7 and EN ISO 13790 Sec 9.2

%vent_zone_height=max(0.1, In.stories*In.ftof);  % Ventilztion Zone Height (m) with a minimum of 0.1 m

vent_zone_height=max(0.1, In.building_height);  % Ventilztion Zone Height (m) with a minimum of 0.1 m

% compute the time averaged ventilation supply and exhaust rates by
% combining the occupied and unoccupied rates
vent_supply_rate = In.vent_supply_rate_occ*frac_hours_occ + In.vent_supply_rate_unocc*frac_hours_unocc
vent_exhaust_rate = In.vent_exhaust_rate_unocc*frac_hours_occ + In.vent_exhaust_rate_unocc*frac_hours_unocc

qv_supp=vent_supply_rate./In.cond_flr_area./3.6;   %vent_supply_rate m3/h/m2 (input is in in L/s)
qv_ext=-vent_exhaust_rate./In.cond_flr_area./3.6;   %vent exhaust rate m3/h/m2, negative indicates out of building

qv_comb = 0 ; % combustion appliance ventilation rate  - not implemented yet but will be impt for restaurants
qv_diff=qv_supp + qv_ext + qv_comb;  % difference between air intake and air exhaust including combustion exhaust

vent_ht_recov=In.vent_heat_recovery; %vent_heat_recovery_eff 
vent_outdoor_frac=1-In.vent_recirc_fraction; % fctrl_vent_recirculation

% infilatration source EN 15242:2007 Sec 6.7 direct method
tot_env_A=sum(In.wall_area)+sum(In.win_area);


% infiltration data from
% Tamura, (1976), Studies on exterior wall air tightness and air infiltration of tall buildings, ASHRAE Transactions, 82(1), 122-134.
% Orm (1998), AIVC TN44: Numerical data for air infiltration and natural ventilation calculations, Air Infiltration and Ventilation Centre.
% Emmerich, (2005), Investigation of the Impact of Commercial Building Envelope Airtightness on HVAC Energy Use.
% create a different table for different building types
%n_highrise_inf_table=[4 6 10 15 20];  % infiltration table for high rise buildings as per Tamura, Orm and Emmerich
n_p_exp=0.65; % assumed flow exponent for infiltration pressure conversion

% find time averaged infiltration rate from occupied and unoccupied rates
infilt_rate = In.infilt_rate_occ*frac_hours_occ + In.infilt_rate_unocc*frac_hours_unocc

v_Q75pa=infilt_rate; % infiltration rate in m3/h/m2 @ 75 Pa based on wall area
v_Q4pa = v_Q75pa.*tot_env_A./In.cond_flr_area*( (4/75).^n_p_exp);  % convert infiltration to Q@4Pa in m3/h /m2 based on floor area

n_zone_frac = 0.7; %fraction that h_stack/zone height.  assume 0.7 as per en 15242

h_stack=n_zone_frac.*vent_zone_height;  % get the effective stack height for infiltration calcs
% calculate the infiltration from stack effect pressure difference from EN 15242: sec 6.7.1
n_stack_exp=0.667;  % reset the pressure exponent to 0.667 for this part of the calc
n_stack_coeff=0.0146;
v_qv_stack_ht=max(n_stack_coeff.*v_Q4pa*(h_stack.*abs(W.mdbt-v_Th_avg)).^n_stack_exp,0.001); %qv_stack_heating m3/h/m2
v_qv_stack_cl=max(n_stack_coeff.*v_Q4pa*(h_stack.*abs(W.mdbt-v_Tc_avg)).^n_stack_exp,0.001); %qv_stack_cooling

% calculate infiltration from wind
% note:  terrain_class [1 = open, 0.9 = country, 0.8 =urban]
n_wind_exp=0.667;
n_wind_coeff=0.0769;
n_dCp = 0.75; % conventional value for cp difference between windward and leeward sides for low rise buildings as per 15242

v_qv_wind_ht=n_wind_coeff.*v_Q4pa.*(n_dCp.*In.terrain_class.*W.mwind.^2).^n_wind_exp; % qv_wind_heating
v_qv_wind_cl=n_wind_coeff.*v_Q4pa.*(n_dCp.*In.terrain_class.*W.mwind.^2).^n_wind_exp; % qv_wind_cooling

n_sw_coeff=0.14;
v_qv_sw_ht = max(v_qv_stack_ht,v_qv_wind_ht)+n_sw_coeff.*v_qv_stack_ht.*v_qv_wind_ht./v_Q4pa; %qv_sw_heat m3/h/m2
v_qv_sw_cl = max(v_qv_stack_cl,v_qv_wind_cl)+n_sw_coeff.*v_qv_stack_cl.*v_qv_wind_cl./v_Q4pa; %qv_sw_cool m3/h/m2

v_qv_inf_ht = max(0,-qv_diff)+v_qv_sw_ht; %q_inf_heat m3/h/m2
v_qv_inf_cl = max(0,-qv_diff)+v_qv_sw_cl; %q_inf_cool m3/h/m2


% source EN ISO 13789 C.5  There they use Vdot instead of Q 
% Vdot = Vdot_f (1??_v) +Vdot_x
% Vdot_f is the design airflow rate due to mechanical ventilation;
% Vdot_x is the additional airflow rate with fans on, due to wind effects;
% ?_v is the global heat recovery efficiency, taking account of the differences between supply and extract
% airflow rates. Heat in air leaving the building through leakage cannot be recovered.

 % set vent_rate_flag=0 if ventilation rate is constant, 1 if we assume vent off in unoccopied times or 
 % 2 if we assume ventilation rate is dropped proportionally to population
 %
 % set to 1 to mimic the behavior of the original spreadsheet
vent_rate_flag=1; 

% set the operation fraction for the ventilation rate
if vent_rate_flag==0
    vent_op_frac=1;
elseif vent_rate_flag==1
    vent_op_frac=frac_hrs_wk_day;
else
    vent_op_frac=frac_hrs_wk_day+(1-frac_hrs_wk_day)*occ_dens/unocc_dens;
end

if In.vent_type==3
    v_qv_mve_ht=zeros(12,1); %qv_me_heating for calc
else
    v_qv_mve_ht=ones(12,1)*vent_op_frac*qv_supp*vent_outdoor_frac*(1-vent_ht_recov);
end
    
%qv_f_cl=ones(12,1)*qv_supp*vent_outdoor_frac; %qv_me_cooling
if In.vent_type==3
    v_qv_mve_cl=zeros(12,1); %qv_me_cooling for calc
else
    v_qv_mve_cl=ones(12,1)*vent_op_frac*qv_supp*vent_outdoor_frac*(1-vent_ht_recov);
end

v_qve_ht = v_qv_inf_ht+v_qv_mve_ht; %total air flow in m3/s when heating
v_qve_cl = v_qv_inf_cl+v_qv_mve_cl; %total air flow in m3/s when cooling

n_rhoc_air = 1200;  % heat capacity of air per unit volume in J/(m3 K)
v_Hve_ht = n_rhoc_air*v_qve_ht/3600;  % Hve (W/K/m2)  heating
v_Hve_cl = n_rhoc_air*v_qve_cl/3600; % Hve (W/K/m2)  cooling

%% Heating and Cooling Needs

%total monthly heat gains (MJ)

v_tot_mo_ht_gain = phi_I_tot*v_Msec_ina_mo + v_E_sol;  % total_heat_gain = total internal + total solar in MJ/m2.

% compute the heating need including thermal mass effects
% NOTE: the building heat thermal time constant, tau, was calculated in the section
% on interior temperature 
a_H0=1; % a_H_0 = reference dimensionless parameter
tau_H0=15; % tau_H_0 = reference time constant
a_H = a_H0+tau/tau_H0;  %a_H_building heating dimensionless constant

v_QT_ht = H_tr.*(v_Th_avg-v_mdbt).*v_Msec_ina_mo;  %QT = transmission loss (MJ)
v_QV_ht = v_Hve_ht*In.cond_flr_area.*(v_Th_avg-v_mdbt).*v_Msec_ina_mo; % QV in MJ
v_Qtot_ht = v_QT_ht+v_QV_ht ; %QL_total total heat loss in MJ

% compute the ratio of heat gain to heating loss, gamma_H
v_gamma_H_ht = v_tot_mo_ht_gain./(v_Qtot_ht+eps);  %gamma_H = QG/QL  - eps added to avoid divide by zero problem

% for each month, check the heat gain ratio and set the heating gain
% utilization factor, eta_g_H accordingly
v_eta_g_H=zeros(12,1);
for I=1:12
    if v_gamma_H_ht(I)>0
        v_eta_g_H(I) = (1-v_gamma_H_ht(I).^a_H)./(1-v_gamma_H_ht(I).^(a_H+1));  % eta_g_H heating gain utilization factor
    else
        v_eta_g_H(I) = 1./(v_gamma_H_ht(I)+eps);
    end
end
   
v_Qneed_ht = v_Qtot_ht - v_eta_g_H.*v_tot_mo_ht_gain; %QNH = QL,H - eta_G_H.*Q_G_H

Qneed_ht_yr = sum(v_Qneed_ht);


% n_a_C0 = 1; %a_C_0 building cooling reference constant
% n_tau_C0 = 15;%tau_C_0 building cooling reference time constant
% C366 = n_a_C0+tau/n_tau_C0; % a_C = building cooling constant

v_QT_cl = H_tr*(v_Tc_avg - v_mdbt).*v_Msec_ina_mo; % QT for cooling in MJ
v_QV_cl = v_Hve_cl*In.cond_flr_area.*(v_Tc_avg - v_mdbt).*v_Msec_ina_mo; % QT for coolin in MJ
v_Qtot_cl = v_QT_cl+v_QV_cl; % QL = QT + QV for cooling = total cooling heat loss in MJ

v_gamma_H_cl = v_Qtot_cl./(v_tot_mo_ht_gain+eps);  %gamma_C = heat loss ratio Qloss/Qgain 

% compute the cooling gain utilization factor eta_g_cl
v_eta_g_CL=zeros(12,1);
for I=1:12 % for each month
    if v_gamma_H_cl(I)>0
        v_eta_g_CL(I) = (1-v_gamma_H_cl(I).^a_H)./(1-v_gamma_H_cl(I).^(a_H+1));  % eta_g_H cooling gain utilization factor
    else
        v_eta_g_CL(I) = 1;
    end
end

v_Qneed_cl = v_tot_mo_ht_gain - v_eta_g_CL.*v_Qtot_cl; % QNC = Q_G_C - eta*Q_L_C = total cooling need
Qneed_cl_yr=sum(v_Qneed_cl);


%% Fan Energy

n_dT_supp_ht=7;  % set heating temp diff between supply air and room air
n_dT_supp_cl=7; %set cooling temp diff between supply air and room air
T_sup_ht = In.ht_tset_occ+n_dT_supp_ht;  %hot air supply temp  - assume supply air is 7C hotter than room
T_sup_cl = In.cl_tset_occ-n_dT_supp_cl;  %cool air supply temp - assume 7C lower than room

n_rhoC_a = 1.22521.*0.001012; % rho*Cp for air (MJ/m3/K)

v_Vair_ht = v_Qneed_ht./(n_rhoC_a.*(T_sup_ht -v_Th_avg)+eps);  %compute volume of air moved for heating
v_Vair_cl = v_Qneed_cl./(n_rhoC_a.*(v_Tc_avg - T_sup_cl)+eps); % compute volume of air moved for cooling

v_Vair_tot=max((v_Vair_ht+v_Vair_cl),vent_supply_rate*v_Msec_ina_mo./1000); % compute air flow in m3
v_Qfan_tot = v_Vair_tot.*In.fan_specific_power.*In.fan_flow_ctrl_factor./In.cond_flr_area./3600;  % compute fan energy in kWh/m2

%% District H/C info

DH_YesNo =0;  % building connected to DH (0=no, 1=yes.  Assume DH is powered by natural gas)
n_eta_DH_network = 0.9; % efficiency of DH network.  Typical value 0l75-0l9 EN 15316-4-5
n_eta_DH_sys = 0.87; % efficiency of DH heating system
n_frac_DH_free = 0.000; % fraction of free heat source to DH (0 to 1)

DC_YesNo = 0;  % building connected to DC (0=no, 1=yes)
n_eta_DC_network = 0.9;  % efficiency of DC network. 
n_eta_DC_COP = 5.5;  % COP of DC elec Chillers
n_eta_DC_frac_abs = 0;  % fraction of DC chillers that are absorption
n_eta_DC_COP_abs = 1;  % COP of DC absorption chillers
n_frac_DC_free = 0;  % fraction of free heat source to absorption DC chillers (0 to 1)

%% HVAC System  
%
% From EN 15243-2007 Annex E.
% HVAC system info table from EN 15243:2007 Table E1.  columns are

% SEER = COP *mPLV  or maybe more properly , IEER = COP * IPLV
%IEER = In.COP*In.PLV ; % compute IEER the effective average COP for the cooling system
IEER = In.COP*In.IPLVtoCOPratio ;
% copy over the HVAC loss/waste factors into local variables with names
% that match the equations better
f_waste=In.hotcold_waste_factor;
a_ht_loss=In.heat_loss_factor;
a_cl_loss=In.cool_loss_factor;


f_dem_ht=max(Qneed_ht_yr/(Qneed_cl_yr+Qneed_ht_yr),0.1); %fraction of yearly heating demand with regard to total heating + cooling demand
f_dem_cl=max((1-f_dem_ht),0.1); %fraction of yearly cooling demand
eta_dist_ht  =1.0/(1.0+a_ht_loss+f_waste/f_dem_ht); % overall distribution efficiency for heating
eta_dist_cl = 1.0/(1.0+a_cl_loss+f_waste/f_dem_cl); %overall distrubtion efficiency for cooling

v_Qloss_ht_dist=v_Qneed_ht*(1-eta_dist_ht)/eta_dist_ht;  %losses from HVAC heat distribution
v_Qloss_cl_dist = v_Qneed_cl*(1-eta_dist_cl)/eta_dist_cl;  %losses from HVAC cooling distribution

if DH_YesNo==1
    v_Qht_sys = zeros(12,1);  % if we have district heating our heating energy needs from our system are zero
    v_Qht_DH = v_Qneed_ht+v_Qloss_ht_dist;  %Q_heat_nd for DH
else
    v_Qht_sys =(v_Qloss_ht_dist+v_Qneed_ht)/(In.heat_sys_eff+eps);  % total heating energy need from our system including losses
    v_Qht_DH = zeros(12,1);
end

if DC_YesNo==1
    v_Qcl_sys = zeros(12,1);  % if we have district cooling our cooling energy needs from our system are zero
    v_Qcool_DC = v_Qloss_cl_dist+v_Qneed_cl;  % if we have DC the cooling needs are the dist losses + the cooling needs themselves
else
    v_Qcl_sys =(v_Qloss_cl_dist+v_Qneed_cl)/(IEER+eps);  % if no DC compute our total system cooling energy needs including losses 
    v_Qcool_DC=zeros(12,1); % if no DC, DC cooling needs are zero
end

v_Qcl_DC_elec = v_Qcool_DC*(1-n_eta_DC_frac_abs)/(n_eta_DC_COP*n_eta_DC_network);  % Energy used for cooling by district electric chillers
v_Qcl_DC_abs = v_Qcool_DC*(1-n_frac_DC_free)/n_eta_DC_COP_abs; %Energy used for cooling by district absorption chillers
   
v_Qht_DH_total = v_Qht_DH*(1-n_frac_DH_free)/(n_eta_DH_sys*n_eta_DH_network);
v_Qcl_elec_tot = v_Qcl_sys +v_Qcl_DC_elec; %total electric cooling energy (MJ)
v_Qcl_gas_tot = v_Qcl_DC_abs; % total gas cooliing energy

 if In.heat_energy_type==1  %check if fuel type is electric
     v_Qelec_ht=v_Qht_sys;  % total electric heating energy (MJ)
     v_Qgas_ht=v_Qht_DH_total; % total gas heating energy is DH if fuel type is electric
 else
     v_Qelec_ht = zeros(12,1);  % if we get here, fuel was gas to total electric heating energy is 0
     v_Qgas_ht=v_Qht_sys+v_Qht_DH_total;  % total gas heating energy is building + any DH
 end
 

 %% Pump Energy
 
%%% NOTE original GIT spreadsheet had this hardwired
%Q_pumps_yr = 8;  %  set pump energy density 8 MJ/m2/yr
%  
%
%  new GIT model following EPA NR 2007 6.9.7.1 and 6.9.7.2
% European Performance Assessment - Non Residential
 
 
 n_E_pumps = 0.25;  % specific power of systems pumps + control systems in W/m2
 v_Q_pumps=n_E_pumps*v_Msec_ina_mo;  % energy per month for pumps + control if running continuously in MJ/m2/mo
 
Q_pumps_yr=sum(v_Q_pumps);% total annual energy for pumps+ctrl if running continuously MJ/m2/yr


 v_frac_ht_mode = v_Qneed_ht./(v_Qneed_ht+v_Qneed_cl);  %fraction of time system is in in heating mode each month
 frac_ht_total=sum(v_frac_ht_mode);  % total heating pump energy fraction
 Q_pumps_ht=Q_pumps_yr*In.pump_heat_ctrl_factor*In.cond_flr_area; % total heating pump energy;
 v_Q_pumps_ht = Q_pumps_ht*v_frac_ht_mode/frac_ht_total;  % break down total according to fractional operation and monthly fraction
 
%v_frac_pump_ht = v_Qneed_ht./(v_Qneed_ht+v_Qneed_cl);  %heating pump operation fraction for each month.
%v_Q_pump_mo=Q_pumps_yr*In.pump_heat_ctrl_factor*In.cond_flr_area.*v_frac_ht_mode;
 
 
v_frac_cl_mode = v_Qneed_cl./(v_Qneed_ht+v_Qneed_cl);% fraction of time system is in cooling mode
frac_cl_total=sum(v_frac_cl_mode); % total cooling pump energy fraction
Q_pumps_cl=Q_pumps_yr*In.pump_cool_ctrl_factor*In.cond_flr_area; % total cooling pump energy fraction
v_Q_pumps_cl = Q_pumps_cl*v_frac_cl_mode/frac_cl_total; % break down total into monthly fractional parts
 
%v_frac_pump_cl = v_Qneed_cl./(v_Qneed_ht+v_Qneed_cl);% cooling pump operation factor

 
 v_frac_tot = (v_Qneed_ht+v_Qneed_cl)/(Qneed_ht_yr+Qneed_cl_yr); % total pump operational factor
 frac_total = sum(v_frac_tot);
 Q_pumps_tot = Q_pumps_ht + Q_pumps_cl;
 
 if (Q_pumps_ht==0 || Q_pumps_cl==0)
    v_Q_pump_tot = v_Q_pumps_ht+v_Q_pumps_cl;
 else
     v_Q_pump_tot = Q_pumps_tot*v_frac_tot/frac_total;
 end

 %Q_pump_tot_yr=sum(v_Q_pump_tot);
 
 
 
 %% Energy Generation
 
%%% NOT INCLUDED YET

 
 
 %% DHW and Solar Water Heating
 %
 % Qdhw= ((Qdem;DWH/?sys;DHW) - Qses;DHW)/?gen;DHW
 % Source: NEN 2916 12.2  
 
n_dhw_tset = 60; % water temperature set point (C)
n_dhw_tsupply = 20; % water initial temp (C)
n_CP_h20=4.18;  % specific heat of water in MJ/m3/K

%solar hot water heating contribution
%D738 =0; % solar collector surface area
v_Q_dhw_solar =zeros(12,1);  % Q from solar energy hot water collectors - not included yet


Q_dhw_yr = In.DHW_demand*(n_dhw_tset-n_dhw_tsupply).*n_CP_h20; % total annual energy required for heating DHW MJ/yr
 
% n_dhw_dist_eff_table=[1 0.8 0.6]; % all taps < 3m from gen = 1, taps> 3m = 0.8, circulation or unknown =0.6
% %eta_dhw_dist = n_dhw_dist_eff_table(In.DHW_dist_sys_type); % set the distribution efficiency from table
% 
% eta_dhw_dist = In.DHW_dist_eff; % DHW distribtuion efficiency
% eta_dhw_sys = In.DHW_sys_eff; % DHW system efficiency

v_Q_dhw_demand = Q_dhw_yr.*v_days_ina_mo./days_ina_year./In.DHW_dist_eff/kWh2MJ; % monthly DHW energy demand including distribution inefficiency
v_Q_dhw_need = max((v_Q_dhw_demand-v_Q_dhw_solar)./In.DHW_sys_eff,0); % total monthly supply need is (demand - solar)/system efficiency

Z=zeros(size(v_Q_dhw_need));
if(In.DHW_energy_type)==1
    v_Q_dhw_elec = v_Q_dhw_need;
    v_Q_dhw_gas = Z;
else
    v_Q_dhw_gas = v_Q_dhw_need;
    v_Q_dhw_elec = Z;
end


%% Plugload 

E_plug_elec =( In.elec_plug_dens_occ*frac_hrs_wk_day + In.elec_plug_dens_unocc*(1-frac_hrs_wk_day)); % average electric plugloads in W/m2
E_plug_gas = (In.gas_plug_dens_occ*frac_hrs_wk_day + In.gas_plug_dens_unocc*(1-frac_hrs_wk_day)); % averaged gas plugloads in W/m2

v_Q_plug_elec = E_plug_elec*v_hrs_ina_mo/1000; % Electric plugload kWh/m2
v_Q_plug_gas = E_plug_gas*v_hrs_ina_mo/1000; % gas plugload kWh/m2


%% Generating output table

Eelec_ht = v_Qelec_ht./In.cond_flr_area./kWh2MJ; % Total monthly electric usage for heating
Eelec_cl = v_Qcl_elec_tot./In.cond_flr_area./kWh2MJ; % Total monthly electric usage for cooling
Eelec_int_lt = v_Q_illum_tot./In.cond_flr_area; % Total monthly electric usage density for interior lighting
Eelec_ext_lt = v_Q_illum_ext_tot./In.cond_flr_area; % Total monthly electric usage for exterior lights
Eelec_fan = v_Qfan_tot; %Total monthly elec usage for fans
Eelec_pump = v_Q_pump_tot./In.cond_flr_area./kWh2MJ; % Total monthly elec usage for pumps
Eelec_plug = v_Q_plug_elec; % Total monthly elec usage for elec plugloads
Eelec_dhw  = v_Q_dhw_elec/In.cond_flr_area;


%Etotal_elec=Eelec_ht + Eelec_cl+Eelec_int_lt+Eelec_ext_lt+Eelec_fan+Eelec_pump+Eelec_plug;

Egas_ht = v_Qgas_ht./In.cond_flr_area./kWh2MJ; % total monthly gas usage for heating
Egas_cl = v_Qcl_gas_tot./In.cond_flr_area./kWh2MJ; % total monthly gas usage for cooling
Egas_plug = v_Q_plug_gas; % total monthly gas plugloads
Egas_dhw = v_Q_dhw_gas./In.cond_flr_area; % total monthly dhw gas plugloads

Z=zeros(size(Eelec_ht));

Ebldg.elec=[Eelec_ht,Eelec_cl,Eelec_int_lt,Eelec_ext_lt,Eelec_fan,Eelec_pump,Eelec_plug,Eelec_dhw];
Ebldg.gas=[Egas_ht,Egas_cl,Z,Z,Z,Z,Egas_plug,Egas_dhw];
Ebldg.total=Ebldg.elec+Ebldg.gas;
Ebldg.cols={'Heat','Cool','Int Lt','Ext Lt','Fans','Pump','Plug','DHW'};
Ebldg.rows=['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];

% Find the totals for each month by summing across the columns
Ebldg.mon=sum(Ebldg.total,2);  % sum normally works down columns but by putting in the ,2 we sum across rows instead
Ebldg.yr=sum(Ebldg.mon);
return

