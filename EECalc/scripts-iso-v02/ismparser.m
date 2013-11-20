function [ In] = ismparser(ismfile)
%Parses the raw input cell array and assigns values to the input structure

% V0.02 19-Nov-2013  RTM,  Changed to new variable names and added a couple of extra inputs
% see variable_name_changes V0.01 to V0.02.txt for more detail

% V0.01 29-Oct-2013
% started over from parse_inputparsing the current .ism file


if nargin==0
    %select the file with a gui
    [filename,pathname]=uigetfile('*.ism','Select Input .ism file to parse');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled script run')
        otherwise
            ismfile=[pathname,filename]; 
    end % switch filename
end

fid=fopen(ismfile,'r');

if fid==-1
     error('File %s not found',file1)  % if fid==-1, file not found  so terminate with an error message
end

% parse the text file
while ~feof(fid)

    Inline=fgetl(fid);  % read in the text line by line into a single string array
    Inline2 = strtrim(Inline);   % strip off leading and trailing whitespace
    % skip blank lines, lines starting with a comment (#)  a lines with non-characters
    if isempty(Inline2) || strncmp(Inline2,'#',1) || ~ischar(Inline2)
        continue
    end
    % everything left should be of the form " A = B"
    [left,right] = strtok(Inline2,'=');
    left2=lower(strtrim(left)); % get the stuff to the left of the = and convert to lower to avoid case problems
    value=str2num(right(2:end));   % convert everything to the right of the "=" to a number
    switch left2
        case 'weatherfilepath'
            In.weatherpath = right;
        case 'terrainclass'
            In.terrain_class= value;
        case 'buildingheight'
            In.building_height = value;
        case 'floorarea'
            In.cond_flr_area = value;
        case 'peopledensityoccupied'
            In.people_density_occ = value; 
        case 'peopledensityunoccupied'
            In.people_density_unocc = value;
        case 'occupancydaystart'        % day of week that occupancy starts
            In.occ_day_start = value;
        case 'occupancydayend'          % day of week that occupancy ends
            In.occ_day_end = value;
        case 'occupancyhourstart'   % hour of day that occupancy starts
            In.occ_hour_start = value;
        case 'occupancyhourend'     % hour of day that occupancy ends
            In.occ_hour_end = value;
        case 'lightingpowerdensityoccupied'
            In.LPD_occ = value;
        case 'lightingpowerdensityunoccupied'
            In.LPD_unocc = value;
        case 'electricappliancepowerdensityoccupied'
            In.elec_plug_dens_occ = value;
        case 'electricappliancepowerdensityunoccupied'
            In.elec_plug_dens_unocc = value ;
        case 'gasappliancepowerdensityoccupied'
            In.gas_plug_dens_occ = value;
        case 'gasappliancepowerdensityunoccupied'
            In.gas_plug_dens_unocc = value;
        case 'exteriorlightingpower'
            In.E_lt_ext = value;
        case 'heatgainperperson'
            In.htgain_per_person = value;
        case 'heatingsetpointoccupied'
            In.ht_tset_occ = value;
        case 'heatingsetpointunoccupied'
            In.ht_tset_unocc = value;
        case 'coolingsetpointoccupied'
            In.cl_tset_occ = value;
        case 'coolingsetpointunoccupied'
            In.cl_tset_unocc = value;
        case 'hvacwastefactor'
            In.hotcold_waste_factor = value;
        case 'hvacheatinglossfactor'
            In.heat_loss_factor = value;
        case 'hvaccoolinglossfactor'
            In.cool_loss_factor = value;
        case 'daylightsensorsystem'
            In.daylighting_sensor=value;
        case 'lightingoccupancysensorsystem'
            In.lighting_occupancy_sensor=value;
        case 'constantilluminationcontrol'
            In.lighting_constant_illumination=value;
        case 'coolingsystemcop'
            In.COP = value;
        case 'coolingsystemiplvtocopratio'
            In.IPLVtoCOPratio = value;
        case 'heatingfueltype'
            In.heat_energy_type = value;
        case 'heatingsystemefficiency'
             In.heat_sys_eff = value;
        case 'ventilationtype'
            In.vent_type = value;
        case 'ventilationintakerateoccupied'
            In.vent_supply_rate_occ = value;
        case 'ventilationintakerateunoccupied'
            In.vent_supply_rate_unocc = value;
        case 'ventilationexhaustrateoccupied'
          In.vent_exhaust_rate_occ = value;      
        case 'ventilationexhaustrateunoccupied'
          In.vent_exhaust_rate_unocc = value;
        case 'heatrecovery'
            In.vent_heat_recovery = value;
        case 'exhaustairrecirculation'     
            In.vent_recirc_fraction = value;
        case 'infiltrationrateoccupied'
            In.infilt_rate_occ = value;
       case 'infiltrationrateunoccupied'
            In.infilt_rate_unocc = value;         
        case 'dhwdemand'
           In.DHW_demand = value;
        case 'dhwsystemefficiency'
            In.DHW_sys_eff = value;
        case 'dhwdistributionefficiency'
            In.DHW_dist_eff = value;
        case 'dhwfueltype'
            In.DHW_energy_type = value;
        case 'interiorheatcapacity'
            In.heat_capacity_int = value;
        case 'exteriorheatcapacity' 
            In.heat_capacity_env = value;
        case 'bemtype'
            In.BEM_type = value;
        case 'specificfanpower'
            In.fan_specific_power = value;
        case 'fanflowcontrolfactor'
            In.fan_flow_ctrl_factor = value;
        case 'heatingpumpcontrol'
            In.pump_heat_ctrl_factor = value;
        case 'coolingpumpcontrol'
            In.pump_cool_ctrl_factor = value;
            
        % put the wall and window properties into arrays.  9th column of
        % wall array is the roof stuff
        % read in the envelope area information 
% making sure to put it into row arrays with columns being the different
%           directions in the order [S, se, E, ne, N, nw, W, S
        case 'wallareas'
            In.wall_area(1) = value;
        case 'walluvalues'
            In.wall_U(1) = value;
        case 'wallsolarabsorptions'
            In.wall_solar_alpha(1) = value;
        case 'wallthermalemissivitys'
            In.wall_thermal_emiss(1) = value;
        case 'wallarease'
            In.wall_area(2) = value;
        case 'walluvaluese'
            In.wall_U(2) = value;
        case 'wallsolarabsorptionse'
            In.wall_solar_alpha(2) = value;
        case 'wallthermalemissivityse'
            In.wall_thermal_emiss(2) = value;            
        case 'wallareae'
            In.wall_area(3) = value;
        case 'walluvaluee'
            In.wall_U(3) = value;
        case 'wallsolarabsorptione'
            In.wall_solar_alpha(3) = value;
        case 'wallthermalemissivitye'
            In.wall_thermal_emiss(3) = value; 
        case 'wallareane'
            In.wall_area(4) = value;
        case 'walluvaluene'
            In.wall_U(4) = value;
        case 'wallsolarabsorptionne'
            In.wall_solar_alpha(4) = value;
        case 'wallthermalemissivityne'
            In.wall_thermal_emiss(4) = value;     
        case 'wallarean'
            In.wall_area(5) = value;
        case 'walluvaluen'
            In.wall_U(5) = value;
        case 'wallsolarabsorptionn'
            In.wall_solar_alpha(5) = value;
        case 'wallthermalemissivityn'
            In.wall_thermal_emiss(5) = value;             
        case 'wallareanw'
            In.wall_area(6) = value;
        case 'walluvaluenw'
            In.wall_U(6) = value;
        case 'wallsolarabsorptionnw'
            In.wall_solar_alpha(6) = value;
        case 'wallthermalemissivitynw'
            In.wall_thermal_emiss(6) = value; 
        case 'wallareaw'
            In.wall_area(6) = value;
        case 'walluvaluew'
            In.wall_U(7) = value;
        case 'wallsolarabsorptionw'
            In.wall_solar_alpha(7) = value;
        case 'wallthermalemissivityw'
            In.wall_thermal_emiss(7) = value;
        case 'wallareasw'
            In.wall_area(8) = value;
        case 'walluvaluesw'
            In.wall_U(8)= value;
        case 'wallsolarabsorptionsw'
            In.wall_solar_alpha(8) = value;
        case 'wallthermalemissivitysw'
            In.wall_thermal_emiss(8) = value; 
        case 'roofarea'
            In.wall_area(9) = value;
        case 'roofuvalue'
            In.wall_U(9) = value;
        case 'roofsolarabsorption'
            In.wall_solar_alpha(9) = value;
        case 'roofthermalemissivity'
            In.wall_thermal_emiss(9) = value;            
        case 'windowareas'
            In.win_area(1) = value;
        case 'windowuvalues'
            In.win_U(1) = value;
        case 'windowshgcs'
            In.win_SHGC(1) = value;
        case 'windowscfs'
            In.win_SCF(1) = value;
        case 'windowsdfs'
            In.win_SDF(1) = value;    
        case 'windowarease'
            In.win_area(2) = value;
        case 'windowuvaluese'
            In.win_U(2) = value;
        case 'windowshgcse'
            In.win_SHGC(2) = value;
        case 'windowscfse'
            In.win_SCF(2) = value;  
        case 'windowsdfse'
            In.win_SDF(2) = value;           
        case 'windowareae'
            In.win_area(3) = value;
        case 'windowuvaluee'
            In.win_U(3) = value;
        case 'windowshgce'
            In.win_SHGC(3) = value;
        case 'windowscfe'
            In.win_SCF(3) = value; 
        case 'windowsdfe'
            In.win_SDF(3) = value;            
        case 'windowareane'
            In.win_area(4) = value;
        case 'windowuvaluene'
            In.win_U(4) = value;
        case 'windowshgcne'
            In.win_SHGC(4) = value;
        case 'windowscfne'
            In.win_SCF(4) = value;  
        case 'windowsdfne'
            In.win_SDF(4) = value;              
        case 'windowarean'
            In.win_area(5) = value;
        case 'windowuvaluen'
            In.win_U(5) = value;
        case 'windowshgcn'
            In.win_SHGC(5) = value;
        case 'windowscfn'
            In.win_SCF(5) = value;  
        case 'windowsdfn'
            In.win_SDF(5) = value;             
        case 'windowareanw'
            In.win_area(6) = value;
        case 'windowuvaluenw'
            In.win_U(6) = value;
        case 'windowshgcnw'
            In.win_SHGC(6) = value;
        case 'windowscfnw'
            In.win_SCF(6) = value; 
        case 'windowsdfnw'
            In.win_SDF(6) = value;             
        case 'windowareaw'
            In.win_area(7) = value;
        case 'windowuvaluew'
            In.win_U(7) = value;
        case 'windowshgcw'
            In.win_SHGC(7) = value;
        case 'windowscfw'
            In.win_SCF(7) = value;
         case 'windowsdfw'
            In.win_SDF(7) = value;           
        case 'windowareasw'
            In.win_area(8) = value;
        case 'windowuvaluesw'
            In.win_U(8)= value;
        case 'windowshgcsw'
            In.win_SHGC(8) = value;
        case 'windowscfsw'
            In.win_SCF(8) = value;
        case 'windowsdfsw'
            In.win_SDF(8) = value           
        case 'skylightarea'
            In.win_area(9) = value;
        case 'skylightuvalue'
            In.win_U(9) = value;
        case 'skylightshgc'
            In.win_SHGC(9) = value;
        case 'skylightscf'
            In.win_SCF(9) = value;
        case 'skylightsdf'
            In.win_SDF(9) = value;
    end
end
fclose(fid)
return
